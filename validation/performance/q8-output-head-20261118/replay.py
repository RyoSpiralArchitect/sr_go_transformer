#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Compare paired and reference Q8 heads from committed FP16 prefixes."""

import argparse
import json
import math
from pathlib import Path
import platform
from statistics import median
import subprocess

from run import HEAD, RECORD, ROOT, isolated_go_environment, replace_once, run_measured, sha
from measure_context_sweep import read_journal, validate_completed


def replay_summary(replays, schedule, sessions, steps):
    if [row["mode"] for row in replays] != [mode for group in schedule for mode in group]:
        raise ValueError("replay schedule mismatch")
    grouped = {stage: [] for stage in ("head", "decode")}
    for round_index, order in enumerate(schedule):
        head, total = {}, {}
        for row in replays[round_index * len(order):(round_index + 1) * len(order)]:
            mode = row["mode"]
            times = row["decode"]["decode_step_seconds"]
            head_ns = row["head_ns"]
            dispatches = steps if sessions == 2 and mode in ("candidate", "repeat") else 0
            if (len(times) != steps or len(head_ns) != steps or not row["exact"] or row["dispatches"] != dispatches
                    or any(not math.isfinite(s) or s <= 0 for s in times)
                    or any(h <= 0 or h > s * 1e9 + 1 for h, s in zip(head_ns, times))):
                raise ValueError("replay identity, dispatch count or timing mismatch")
            total[mode] = sum(times) * 1e3 / steps
            head[mode] = sum(head_ns) / 1e6 / steps
        grouped["head"].append(head)
        grouped["decode"].append(total)
    result = {}
    for stage, rounds in grouped.items():
        ratios = {f"{a}/{b}": [row[a] / row[b] for row in rounds] for a, b in (
            ("candidate", "reference"), ("repeat", "control"), ("control", "reference"), ("repeat", "candidate"))}
        result[stage] = dict(
            median_ms={mode: median(row[mode] for row in rounds) for mode in rounds[0]},
            ratios=ratios, ratio_medians={pair: median(values) for pair, values in ratios.items()})
    return result


def adoption(runs):
    results = {run["sessions"]: run["summary"] for run in runs}
    arms = ("candidate/reference", "repeat/control")
    controls = ("control/reference", "repeat/candidate")
    return {
        "same_path": all(0.95 <= stage["ratio_medians"][pair] <= 1.05
                         for model in results.values() for stage in model.values() for pair in controls),
        "single_session": all(stage["ratio_medians"][pair] <= 1.05
                              for stage in results[1].values() for pair in arms),
        "two_session_head": all(results[2]["head"]["ratio_medians"][pair] <= 0.90 and
                                sum(x < 1 for x in results[2]["head"]["ratios"][pair]) >= 3 for pair in arms),
        "two_session_decode": all(results[2]["decode"]["ratio_medians"][pair] <= 0.99 for pair in arms),
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    build = output / "build"
    build.mkdir()
    protocol_file = RECORD / "replay-protocol.json"
    protocol = json.loads(protocol_file.read_text())
    env = isolated_go_environment()
    runtime = ROOT / "cmd/monolith/monolith.go"
    corpus = ROOT / "validation/quality/corpus.json"
    catalog = ROOT / "validation/hf/model-profiles.json"
    sources = [ROOT / p for p in ("cmd/monolith/inference_perf_test.go", "cmd/monolith/context_sweep_perf_test.go",
                                 "go.mod", "go.sum")]
    replay = RECORD / "replay_test.go.txt"
    identities = {p: sha(p) for p in [runtime, corpus, catalog, protocol_file, replay, Path(__file__).resolve(),
                                     RECORD / "run.py", ROOT / "scripts/compare_inference.py",
                                     ROOT / "scripts/measure_context_sweep.py", ROOT / "scripts/quant_quality.py",
                                     ROOT / "scripts/context_sweep_timing.py", *sources]}
    if identities[runtime] != protocol["candidate_runtime_sha256"]:
        raise ValueError("runtime does not match the frozen candidate")
    model = next(p for p in json.loads(catalog.read_text())["models"] if p["id"] == "llama32-3b")
    if model["revision"] != protocol["model_revision"]:
        raise ValueError("model revision mismatch")
    assets = {args.model.resolve() / name: digest for name, digest in model["files"].items()}
    if any(sha(path) != digest for path, digest in assets.items()):
        raise ValueError("model file hash mismatch")
    code = runtime.read_text()
    mark = HEAD.replace("linearIntoWithExecutor", "linearOutputHeadInto")
    code = replace_once(code, mark, mark.replace("linearOutputHeadInto(", "q8ReplayProject(ctx, "))
    code = replace_once(code, "\t\tlinearQ8OutputPairInto(e, y, x, w)\n",
                        "\t\tlinearQ8OutputPairInto(e, y, x, w)\n\t\tq8OutputPairDispatches++\n")
    (build / "monolith.go").write_text(code)
    modes = [mode for group in protocol["schedule"] for mode in group]
    (build / "replay_test.go").write_text(replay.read_text() +
        "\nvar q8ReplayOrder = []string{" + ", ".join(map(json.dumps, modes)) + "}\n")
    for path in sources:
        (build / path.name).write_bytes(path.read_bytes())
    build_identities = {p: sha(p) for p in build.iterdir()}
    binary = build / "probe.test"
    with (output / "build.log").open("x") as log:
        subprocess.run(["go", "test", "-c", "-trimpath", "-o", binary, "."], cwd=build, env=env,
                       stdout=log, stderr=subprocess.STDOUT, check=True, timeout=300)
    binary_hash = sha(binary)
    runs = []
    for n in protocol["sessions"]:
        directory = output / f"s{n}"
        directory.mkdir()
        run_env = dict(env, MONOLITH_SWEEP_MODEL=str(args.model.resolve()), MONOLITH_SWEEP_CORPUS=str(corpus),
                       MONOLITH_SWEEP_OUTPUT=str(directory), MONOLITH_SWEEP_FORMAT=protocol["kv"],
                       MONOLITH_SWEEP_SESSIONS=str(n), MONOLITH_SWEEP_LENGTHS=str(protocol["prefix"]))
        print(f"{n} sessions: replaying committed prefix", flush=True)
        with (directory / "probe.log").open("x") as log:
            resources = run_measured([binary, "-test.run=^TestHFContextSweep$", "-test.v", "-test.timeout=10m"],
                                     cwd=build, env=run_env, stdout=log, stderr=subprocess.STDOUT, timeout=630)
        journal = directory / "cases.jsonl"
        events, error = read_journal(journal)
        if error:
            raise ValueError(error)
        validate_completed(events, protocol["kv"], n, [protocol["prefix"]], True)
        summary = replay_summary(events[-2]["replays"], protocol["schedule"], n, protocol["decode_calls"])
        runs.append(dict(sessions=n, resources=resources, journal_sha256=sha(journal), events=events, summary=summary))
        print(f"{n} sessions: complete", flush=True)
    if any(sha(p) != digest for p, digest in (identities | build_identities | assets).items()) or sha(binary) != binary_hash:
        raise ValueError("replay inputs changed during measurement")
    decision = adoption(runs)
    receipt = {
        "go": subprocess.check_output(["go", "version"], env=env, text=True).strip(),
        "host": platform.platform(),
        "model_files": model["files"],
        "inputs_sha256": {str(p.relative_to(ROOT)): digest for p, digest in identities.items()},
        "build_sources_sha256": {p.name: digest for p, digest in build_identities.items()},
        "binary_sha256": binary_hash, "runs": runs, "criteria": decision, "passed": all(decision.values()),
    }
    (output / "receipt.json").write_text(json.dumps(receipt, indent=2, allow_nan=False) + "\n")
    print(json.dumps(decision), flush=True)


if __name__ == "__main__":
    main()
