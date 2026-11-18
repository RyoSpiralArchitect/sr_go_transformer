#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Measure three-output Q4 projections against the current Apple Silicon path."""

import argparse
import json
from pathlib import Path
import platform
import statistics
import subprocess
import sys

RECORD = Path(__file__).resolve().parent
ROOT = RECORD.parents[2]
PREVIOUS = RECORD.with_name("q8-head-adjacent-20261118")
RUNTIME = ROOT / "cmd/monolith/monolith.go"
sys.path.insert(0, str(PREVIOUS))
from run import isolated_go_environment, read_journal, replace_once, run_measured, sha, validate_completed
from trajectory import constants


def generate_triple(source):
    pair = "func linearQ4TwoRowOutputPairRange("
    start = source.index(pair)
    end = source.index("\n}\n", start) + 3
    loop = replace_once(source[start:end], pair, "func linearQ4TwoRowOutputTripleRange(")
    loop = replace_once(loop, "\t\tfor ; o+1 < end; o += 2 {", """		for ; o+2 < end; o += 3 {
			w0 := w.Q4.Values[o*stride : (o+1)*stride]
			w1 := w.Q4.Values[(o+1)*stride : (o+2)*stride]
			w2 := w.Q4.Values[(o+2)*stride : (o+3)*stride]
			s0 := w.Q4.Scales[o*groups : (o+1)*groups]
			s1 := w.Q4.Scales[(o+1)*groups : (o+2)*groups]
			s2 := w.Q4.Scales[(o+2)*groups : (o+3)*groups]
			var a00, a01, a02, a10, a11, a12 float32
			for g := 0; g < groups; g++ {
				column, packed := g*64, g*32
				p00, p01, p02, p10, p11, p12 := dotQ4TwoRowOutputTriple64(
					(*[64]float32)(x0[column:column+64]), (*[64]float32)(x1[column:column+64]),
					(*[32]byte)(w0[packed:packed+32]), (*[32]byte)(w1[packed:packed+32]), (*[32]byte)(w2[packed:packed+32]))
				a00 += p00 * s0[g]
				a01 += p01 * s1[g]
				a02 += p02 * s2[g]
				a10 += p10 * s0[g]
				a11 += p11 * s1[g]
				a12 += p12 * s2[g]
			}
			y[o], y[o+1], y[o+2] = a00, a01, a02
			y[out+o], y[out+o+1], y[out+o+2] = a10, a11, a12
		}
		for ; o+1 < end; o += 2 {""")
    block = ["func dotQ4TwoRowOutputTriple64(x0, x1 *[64]float32, w0, w1, w2 *[32]byte)"
             " (float32, float32, float32, float32, float32, float32) {"]
    order = [(row, out) for row in range(2) for out in range(3)]
    for row, out in order:
        block.append("var " + ", ".join(f"{lane}{row}{out}" for lane in "abcd") + " float32")
    for index in range(32):
        a, b = "ab" if index % 2 == 0 else "cd"
        block.append("{")
        for row in range(2):
            block.append(f"v{row}0, v{row}1 := x{row}[{2*index}], x{row}[{2*index+1}]")
        for out in range(3):
            block.append(f"p{out} := &q4Pairs[w{out}[{index}]]")
            for row in range(2):
                block.extend([f"{a}{row}{out} += v{row}0 * p{out}[0]", f"{b}{row}{out} += v{row}1 * p{out}[1]"])
        block.append("}")
    block += ["return " + ", ".join(f"(a{r}{o}+b{r}{o})+(c{r}{o}+d{r}{o})" for r, o in order), "}"]
    return "package main\n\n" + loop + "\n" + "\n".join(block) + "\n"


def instrument_runtime(source):
    source = replace_once(source, "\t\tlinearQ4TwoRowOutputPairRange(job, lo, hi)\n", """		if q4TrialActive {
			if lo == 0 {
				q4TrialDispatches++
			}
			linearQ4TwoRowOutputTripleRange(job, lo, hi)
			return
		}
		linearQ4TwoRowOutputPairRange(job, lo, hi)
""")
    start = source.index("func (m *Model) prefillSelected(")
    end = source.index("\nfunc (m *Model) Step(", start)
    body = replace_once(source[start:end], "\tfor l, b := range m.Blocks {",
                        "\tq4TrialSelect(ctx)\n\tfor l, b := range m.Blocks {")
    for dst, inp, param in (("Q", "N", "Q"), ("K", "N", "K"), ("V", "N", "V"), ("Q", "A", "O"),
                            ("G", "N", "Gate"), ("U", "N", "Up"), ("Q", "G", "Down")):
        args = f"executor, w.{dst}, w.{inp}, b.{param}, n)"
        body = replace_once(body, f"linearIntoWithExecutor({args}", f"q4TrialProjection(ctx, {args}")
    return source[:start] + body + source[end:]


def trajectory_code(source, protocol):
    source = replace_once(source, """if len(prefixes) != 2 || prefixes[0].format != "f16" || prefixes[1].format != "f16" {
		return nil, fmt.Errorf("expected two FP16 sessions")
	}""", """if len(prefixes) < 1 || len(prefixes) > 2 {
		return nil, fmt.Errorf("expected one or two sessions")
	}
	for _, cache := range prefixes {
		if cache.format != "f16" {
			return nil, fmt.Errorf("expected FP16 KV")
		}
	}""")
    source = replace_once(source, '[]string{"reference", "pair", "triple"}', '[]string{"reference", "triple"}')
    source = replace_once(source, "timing[j].calls != 1", "timing[j].calls != 7*len(m.Blocks)")
    source = replace_once(source, "head count or workspace changed", "Q4 projection count or workspace changed")
    for old, new in (("measureHeadTrajectories", "measureQ4Trajectories"), ("headTrajectory", "q4Trajectory"),
                     ("adjacentHeadContext", "q4TrialTiming"), ("adjacentHeadKey", "q4TrialKey"),
                     ("adjacentTiledCalls", "q4TrialDispatches"), ("headNS", "projectionNS"),
                     ("head_ns", "projection_ns"), ("sample.Head[j]", "sample.Projection[j]")):
        source = source.replace(old, new)
    source = replace_once(source, "\n\tHead       ", "\n\tProjection ")
    return source + constants(protocol)


def analyze(rows, protocol, reference, sessions, layers):
    modes = protocol["comparisons"]
    steps = protocol["steps"]
    expected = []
    for round_id in range(protocol["rounds"]):
        for offset in protocol["order_seed"]:
            i = (offset + round_id) % len(modes)
            expected.append((round_id, i, modes[i], [(round_id + step + i) % 2 for step in range(steps)]))
    if [(r["round"], r["comparison"], r["modes"], r["first_arm"]) for r in rows] != expected:
        raise ValueError("trajectory schedule mismatch")
    for row in rows:
        expected_counts = [steps*7*layers if mode == "triple" and sessions == 2 else 0 for mode in row["modes"]]
        if (row["tiled_dispatches"] != expected_counts or row["kv_sha256"] != [reference["kv_sha256"]] * 2
                or row["logits_sha256"] != [reference["logits_sha256"]] * 2):
            raise ValueError("trajectory or dispatch count mismatch")
        for total, projections in zip(row["elapsed_ns"], row["projection_ns"], strict=True):
            if len(total) != steps or len(projections) != steps or any(not 0 < q <= t for t, q in zip(total, projections)):
                raise ValueError("invalid per-step intervals")
    result = {}
    for stage in ("projection_ns", "elapsed_ns"):
        groups = {}
        for i, (left, right) in enumerate(modes):
            durations = [[sum(a) for a in r[stage]] for r in rows if r["comparison"] == i]
            ratios = [b/a for a, b in durations]
            groups[f"{right}/{left}"] = dict(ratios=ratios, median_ratio=statistics.median(ratios),
                quartiles=statistics.quantiles(ratios, method="inclusive"), faster=sum(r < 1 for r in ratios),
                median_ms_per_step=[statistics.median(v)/steps/1e6 for v in zip(*durations)])
        result[stage] = groups
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    build = output/"build"
    build.mkdir()
    env = isolated_go_environment()
    protocol_path = RECORD/"protocol.json"
    protocol = json.loads(protocol_path.read_text())
    corpus = ROOT/"validation/quality/corpus.json"
    catalog = ROOT/"validation/hf/model-profiles.json"
    probe = RECORD/"probe_test.go.txt"
    trajectory = PREVIOUS/"trajectory_test.go.txt"
    sources = [ROOT/path for path in ("go.mod", "go.sum", "cmd/monolith/inference_perf_test.go",
                                      "cmd/monolith/context_sweep_perf_test.go")]
    hashes = {p: sha(p) for p in (RUNTIME, corpus, catalog, probe, trajectory, protocol_path, Path(__file__).resolve(),
                                 PREVIOUS/"run.py", PREVIOUS/"trajectory.py", ROOT/"scripts/compare_inference.py",
                                 ROOT/"scripts/measure_context_sweep.py", ROOT/"scripts/context_sweep_timing.py",
                                 ROOT/"scripts/quant_quality.py", *sources)}
    if hashes[RUNTIME] != protocol["runtime_sha256"]:
        raise ValueError("use the frozen reference runtime")
    model = next(m for m in json.loads(catalog.read_text())["models"] if m["id"] == "llama32-3b")
    if (model["repo"], model["revision"]) != (protocol["model"], protocol["model_revision"]):
        raise ValueError("unexpected model")
    assets = {args.model.resolve()/filename: value for filename, value in model["files"].items()}
    if any(sha(p) != digest for p, digest in assets.items()):
        raise ValueError("model file hash mismatch")
    source = RUNTIME.read_text()
    (build/"monolith.go").write_text(instrument_runtime(source))
    (build/"triple_test.go").write_text(generate_triple(source))
    (build/"trajectory_test.go").write_text(trajectory_code(trajectory.read_text(), protocol))
    (build/"q4_trial_test.go").write_bytes(probe.read_bytes())
    for path in sources:
        (build/path.name).write_bytes(path.read_bytes())
    staged = {p: sha(p) for p in build.iterdir()}
    with (output/"race.log").open("x") as log:
        run_measured(["go", "test", "-race", "-count=1", "-run", "^TestQ4ThreeOutputTrialExact$", "."],
                     cwd=build, env=dict(env, CGO_ENABLED="1"), stdout=log, stderr=subprocess.STDOUT, timeout=300)
    binary = build/"probe.test"
    subprocess.run(["go", "test", "-c", "-trimpath", "-o", binary, "."], cwd=build, env=env, check=True, timeout=300)
    binary_hash = sha(binary)
    runs = []
    for n in protocol["sessions"]:
        directory = output/f"s{n}"
        directory.mkdir()
        run_env = dict(env, MONOLITH_SWEEP_MODEL=str(args.model.resolve()), MONOLITH_SWEEP_CORPUS=str(corpus),
                       MONOLITH_SWEEP_OUTPUT=str(directory), MONOLITH_SWEEP_FORMAT=protocol["kv"],
                       MONOLITH_SWEEP_SESSIONS=str(n), MONOLITH_SWEEP_LENGTHS=str(protocol["prefix"]))
        print(f"{n} sessions: measuring Q4 and total forward time", flush=True)
        with (directory/"probe.log").open("x") as log:
            resources = run_measured([binary, "-test.run=^TestHFContextSweep$", "-test.v", "-test.timeout=10m"],
                                     cwd=build, env=run_env, stdout=log, stderr=subprocess.STDOUT, timeout=630)
        journal = directory/"cases.jsonl"
        events, error = read_journal(journal)
        if error:
            raise ValueError(error)
        validate_completed(events, protocol["kv"], n, [protocol["prefix"]], True)
        plan = events[0]["plan"]
        if plan["weight_format"] != protocol["weights"] or events[0]["workers"] != protocol["workers"]:
            raise ValueError("unexpected weights or executor size")
        metrics = analyze(events[-2]["replays"], protocol, events[1]["decode"], n, plan["config"]["layers"])
        runs.append(dict(sessions=n, resources=resources, journal_sha256=sha(journal), events=events, metrics=metrics))
    if any(sha(p) != digest for p, digest in (hashes | staged | assets).items()) or sha(binary) != binary_hash:
        raise ValueError("probe inputs changed")
    receipt = dict(architecture=platform.platform(), go=subprocess.check_output(["go", "version"], env=env, text=True).strip(),
                   model_files=model["files"], binary_sha256=binary_hash, race_log_sha256=sha(output/"race.log"),
                   inputs_sha256={str(p.relative_to(ROOT)): digest for p, digest in hashes.items()},
                   build_sources_sha256={p.name: digest for p, digest in staged.items()}, runs=runs)
    (output/"receipt.json").write_text(json.dumps(receipt, indent=2, allow_nan=False) + "\n")
    print("Complete", flush=True)


if __name__ == "__main__":
    main()
