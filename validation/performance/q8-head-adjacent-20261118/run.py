#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Pair Q8 head calls using frozen real activations and a shared decoder prefix."""

import argparse
import hashlib
import json
from pathlib import Path
import platform
import statistics
import subprocess
import sys

RECORD = Path(__file__).resolve().parent
ROOT = RECORD.parents[2]
PREVIOUS = RECORD.with_name("q8-output-head-20261118")
RUNTIME = "cmd/monolith/monolith.go"
sys.path.insert(0, str(ROOT / "scripts"))
from compare_inference import isolated_go_environment
from measure_context_sweep import read_journal, validate_completed
from quant_quality import run_measured, sha


def replace_once(source, old, new):
    if source.count(old) != 1:
        raise ValueError(f"expected one occurrence of {old!r}")
    return source.replace(old, new, 1)


def staged_runtime(protocol, patch, build, env):
    index_env = dict(env, GIT_INDEX_FILE=str(build / "index"))
    subprocess.run(["git", "read-tree", protocol["baseline"]], cwd=ROOT, env=index_env, check=True, timeout=30)
    subprocess.run(["git", "apply", "--cached", "--unidiff-zero", "--include=" + RUNTIME, patch],
                   cwd=ROOT, env=index_env, check=True, timeout=30)
    known_pair = subprocess.check_output(["git", "show", ":" + RUNTIME], cwd=ROOT, env=index_env, timeout=30)
    (build / "index").unlink()
    if hashlib.sha256(known_pair).hexdigest() != protocol["archived_pair_runtime_sha256"]:
        raise ValueError("archived output-pair code differs")
    source = replace_once(known_pair.decode(), "linearOutputHeadInto(executor, w.Logits[:heads*c.Vocab], w.N[:heads*d], head, heads)",
                          "adjacentHeadProject(ctx, executor, w.Logits[:heads*c.Vocab], w.N[:heads*d], head, heads)")
    return replace_once(source, "\t\tlinearQ8OutputPairInto(e, y, x, w)\n",
                        "\t\tlinearQ8OutputPairInto(e, y, x, w)\n\t\tadjacentTiledCalls++\n")


def triple_kernel():
    # Keep the four sums and their reduction order for each input/output pair.
    # Two activation values from each row are in scope across all three outputs.
    accumulators = [(row, out) for row in range(2) for out in range(3)]
    lines = ["package main", "",
             "func dotQ8TripleTrial64(x0, x1 *[64]float32, w0, w1, w2 *[64]int8)"
             " (float32, float32, float32, float32, float32, float32) {"]
    for row, out in accumulators:
        lines.append("var " + ", ".join(f"{s}{row}{out}" for s in "abcd") + " float32")
    for col in range(0, 64, 2):
        a, b = "ab" if col % 4 == 0 else "cd"
        lines.append("{")
        for row in range(2):
            lines.append(f"x{row}a, x{row}b := x{row}[{col}], x{row}[{col+1}]")
        for out in range(3):
            lines.append(f"v{out}a, v{out}b := float32(w{out}[{col}]), float32(w{out}[{col+1}])")
            for row in range(2):
                lines.extend([f"{a}{row}{out} += x{row}a * v{out}a", f"{b}{row}{out} += x{row}b * v{out}b"])
        lines.append("}")
    lines += ["return " + ", ".join(f"(a{r}{o}+b{r}{o})+(c{r}{o}+d{r}{o})" for r, o in accumulators), "}"]
    lines.append("""
func linearQ8TripleTrial(e *kernelExecutor, y, x []float32, w *Param) {
    const tile = 96 // A multiple of three shares the same worker boundaries on this head.
    in, out := w.Cols, w.Rows
    groups := in / q8Block
    x0, x1 := x[:in], x[in:2*in]
    e.parallel((out+tile-1)/tile, 2*in*out, func(lo, hi int) {
        for task := lo; task < hi; task++ {
            o, end := task*tile, min(out, (task+1)*tile)
            for ; o+2 < end; o += 3 {
                w0 := w.Q8.Values[o*in:(o+1)*in]
                w1 := w.Q8.Values[(o+1)*in:(o+2)*in]
                w2 := w.Q8.Values[(o+2)*in:(o+3)*in]
                s0 := w.Q8.Scales[o*groups:(o+1)*groups]
                s1 := w.Q8.Scales[(o+1)*groups:(o+2)*groups]
                s2 := w.Q8.Scales[(o+2)*groups:(o+3)*groups]
                var a00, a01, a02, a10, a11, a12 float32
                for g := 0; g < groups; g++ {
                    j := g*q8Block
                    p00, p01, p02, p10, p11, p12 := dotQ8TripleTrial64(
                        (*[64]float32)(x0[j:j+64]), (*[64]float32)(x1[j:j+64]),
                        (*[64]int8)(w0[j:j+64]), (*[64]int8)(w1[j:j+64]), (*[64]int8)(w2[j:j+64]))
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
            for ; o < end; o++ {
                weights := w.Q8.Values[o*in:(o+1)*in]
                scales := w.Q8.Scales[o*groups:(o+1)*groups]
                var a0, a1 float32
                for g, scale := range scales {
                    j := g*q8Block
                    p0, p1 := dotQ8PairBlock64((*[64]float32)(x0[j:j+64]), (*[64]float32)(x1[j:j+64]),
                                             (*[64]int8)(weights[j:j+64]))
                    a0 += p0 * scale
                    a1 += p1 * scale
                }
                y[o], y[out+o] = a0, a1
            }
        }
    })
}
""")
    return "\n".join(lines)


def schedule_constants(protocol):
    pairs = ",\n".join("{" + ", ".join(map(json.dumps, pair)) + "}" for pair in protocol["comparisons"])
    offsets = ", ".join(map(str, protocol["comparison_order_seed"]))
    return (f"\nconst adjacentRounds = {protocol['rounds']}\n"
            f"var adjacentComparisons = [][2]string{{\n{pairs},\n}}\n"
            f"var adjacentOrderSeed = []int{{{offsets}}}\n")


def expected_samples(protocol, captures):
    pairs = protocol["comparisons"]
    for round_id in range(protocol["rounds"]):
        for offset in range(captures):
            capture = (offset + round_id) % captures
            for slot in protocol["comparison_order_seed"]:
                comparison = (slot + round_id + capture) % len(pairs)
                order = pairs[comparison][::-1] if round_id % 2 else pairs[comparison]
                yield round_id, capture, comparison, order


def summarize_samples(rows, protocol, captures, field):
    expected = list(expected_samples(protocol, captures))
    observed = [(row["round"], row["capture"], row["comparison"], row["order"]) for row in rows]
    if observed != expected:
        raise ValueError("observed schedule differs")
    result = {}
    for i, (left, right) in enumerate(protocol["comparisons"]):
        ratios, before, after, elapsed_left, elapsed_right = [], [], [], [], []
        for row in rows:
            if row["comparison"] != i:
                continue
            values = row[field]
            if (len(values) != 2 or any(value <= 0 for value in values)
                    or row["tiled_dispatches"] != [int(mode != "reference") for mode in row["order"]]):
                raise ValueError("invalid timing or dispatch count")
            if field == "head_ns" and any(h > total for h, total in zip(values, row["elapsed_ns"])):
                raise ValueError("head elapsed time exceeds total")
            reverse = row["round"] % 2 and left != right
            a, b = values[::-1] if reverse else values
            ratio = b / a
            ratios.append(ratio)
            (after if reverse else before).append(ratio)
            elapsed_left.append(a)
            elapsed_right.append(b)
        result[f"{right}/{left}"] = dict(
            count=len(ratios), median_ratio=statistics.median(ratios),
            quartiles=statistics.quantiles(ratios, method="inclusive"),
            min_ratio=min(ratios), max_ratio=max(ratios),
            median_first_order=statistics.median(before),
            median_reverse_order=statistics.median(after) if after else None,
            faster=sum(ratio < 1 for ratio in ratios),
            median_ms=[statistics.median(values) / 1e6 for values in (elapsed_left, elapsed_right)])
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    build = output / "build"
    build.mkdir()
    protocol_file = RECORD / "protocol.json"
    protocol = json.loads(protocol_file.read_text())
    env = isolated_go_environment()
    catalog = ROOT / "validation/hf/model-profiles.json"
    corpus = ROOT / "validation/quality/corpus.json"
    sources = [ROOT / name for name in ("cmd/monolith/context_sweep_perf_test.go", "cmd/monolith/inference_perf_test.go",
                                        "go.mod", "go.sum")]
    probe = RECORD / "probe_test.go.txt"
    patch = PREVIOUS / "candidate.patch"
    inputs = {p: sha(p) for p in [ROOT / RUNTIME, catalog, corpus, probe, patch, protocol_file, Path(__file__).resolve(),
                                ROOT / "scripts/compare_inference.py", ROOT / "scripts/measure_context_sweep.py",
                                ROOT / "scripts/quant_quality.py", ROOT / "scripts/context_sweep_timing.py", *sources]}
    if inputs[ROOT / RUNTIME] != protocol["runtime_sha256"]:
        raise ValueError("use the frozen reference worktree")
    model = next(m for m in json.loads(catalog.read_text())["models"] if m["id"] == "llama32-3b")
    if (model["repo"], model["revision"]) != (protocol["model"], protocol["model_revision"]):
        raise ValueError("unexpected model revision")
    assets = {args.model.resolve() / name: digest for name, digest in model["files"].items()}
    if any(sha(path) != digest for path, digest in assets.items()):
        raise ValueError("model file hash mismatch")
    (build / "monolith.go").write_text(staged_runtime(protocol, patch, build, env))
    (build / "adjacent_test.go").write_text(probe.read_text() + schedule_constants(protocol))
    (build / "triple_test.go").write_text(triple_kernel())
    for path in sources:
        (build / path.name).write_bytes(path.read_bytes())
    staged = {p: sha(p) for p in build.iterdir()}
    binary = build / "probe.test"
    subprocess.run(["go", "test", "-c", "-trimpath", "-o", binary, "."], cwd=build, env=env, check=True, timeout=300)
    binary_sha = sha(binary)
    run_env = dict(env, MONOLITH_SWEEP_MODEL=str(args.model.resolve()), MONOLITH_SWEEP_CORPUS=str(corpus),
                   MONOLITH_SWEEP_OUTPUT=str(output), MONOLITH_SWEEP_FORMAT=protocol["kv"],
                   MONOLITH_SWEEP_SESSIONS=str(protocol["sessions"]), MONOLITH_SWEEP_LENGTHS=str(protocol["prefix"]))
    print("Running the captured-head and one-step pairs", flush=True)
    with (output / "probe.log").open("x") as log:
        resources = run_measured([binary, "-test.run=^TestHFContextSweep$", "-test.v", "-test.timeout=10m"],
                                 cwd=build, env=run_env, stdout=log, stderr=subprocess.STDOUT, timeout=630)
    journal = output / "cases.jsonl"
    events, error = read_journal(journal)
    if error:
        raise ValueError(error)
    validate_completed(events, protocol["kv"], protocol["sessions"], [protocol["prefix"]], True)
    result = events[-2]["replays"]
    steps = protocol["activation_steps"]
    if len(result["activation_sha256"]) != steps or len(result["logits_sha256"]) != steps:
        raise ValueError("incomplete captures")
    metrics = {
        "head_only": summarize_samples(result["head_samples"], protocol, steps, "elapsed_ns"),
        "one_step_head": summarize_samples(result["one_step_samples"], protocol, 1, "head_ns"),
        "one_step_total": summarize_samples(result["one_step_samples"], protocol, 1, "elapsed_ns"),
    }
    if any(sha(p) != digest for p, digest in (inputs | staged | assets).items()) or sha(binary) != binary_sha:
        raise ValueError("probe inputs changed during measurement")
    receipt = dict(architecture=platform.platform(), go=subprocess.check_output(["go", "version"], env=env, text=True).strip(),
                   model_files=model["files"], binary_sha256=binary_sha, journal_sha256=sha(journal),
                   inputs_sha256={str(p.relative_to(ROOT)): digest for p, digest in inputs.items()},
                   build_sources_sha256={p.name: digest for p, digest in staged.items()},
                   resources=resources, metrics=metrics, events=events)
    (output / "receipt.json").write_text(json.dumps(receipt, indent=2, allow_nan=False) + "\n")
    print("Complete", flush=True)


if __name__ == "__main__":
    main()
