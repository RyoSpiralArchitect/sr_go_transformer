#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Interleave two independently committed decode trajectories at each token."""

import argparse
import json
from pathlib import Path
import platform
import statistics
import subprocess

from run import (PREVIOUS, RECORD, ROOT, RUNTIME, isolated_go_environment, read_journal, replace_once,
                 run_measured, schedule_constants, sha, staged_runtime, triple_kernel, validate_completed)


def constants(protocol):
    pairs = ",\n".join("{" + ", ".join(map(json.dumps, pair)) + "}" for pair in protocol["comparisons"])
    offsets = ", ".join(map(str, protocol["order_seed"]))
    return (f"\nconst trajectoryRounds = {protocol['rounds']}\n"
            f"var trajectoryComparisons = [][2]string{{\n{pairs},\n}}\n"
            f"var trajectoryOrderSeed = []int{{{offsets}}}\n")


def analyze(rows, protocol, reference):
    modes = protocol["comparisons"]
    steps = protocol["steps"]
    expected = []
    for round_id in range(protocol["rounds"]):
        for offset in protocol["order_seed"]:
            comparison = (offset + round_id) % len(modes)
            first = [(round_id + step + comparison) % 2 for step in range(steps)]
            expected.append((round_id, comparison, modes[comparison], first))
    actual = [(s["round"], s["comparison"], s["modes"], s["first_arm"]) for s in rows]
    if actual != expected:
        raise ValueError("trajectory order differs")
    for row in rows:
        if (row["logits_sha256"] != [reference["logits_sha256"]] * 2
                or row["kv_sha256"] != [reference["kv_sha256"]] * 2
                or row["tiled_dispatches"] != [steps if mode != "reference" else 0 for mode in row["modes"]]):
            raise ValueError("invalid trajectory or dispatch count")
        if len(row["elapsed_ns"]) != 2 or len(row["head_ns"]) != 2:
            raise ValueError("missing trajectory arms")
        for forward, head in zip(row["elapsed_ns"], row["head_ns"]):
            if len(forward) != steps or len(head) != steps or any(not 0 < h <= t for t, h in zip(forward, head)):
                raise ValueError("invalid trajectory timing")
    result = {}
    for stage in ("head_ns", "elapsed_ns"):
        summaries = {}
        for i, (left, right) in enumerate(modes):
            pairs = [[sum(arm) for arm in row[stage]] for row in rows if row["comparison"] == i]
            ratios = [b / a for a, b in pairs]
            summaries[f"{right}/{left}"] = dict(ratios=ratios, median_ratio=statistics.median(ratios),
                quartiles=statistics.quantiles(ratios, method="inclusive"), faster=sum(r < 1 for r in ratios),
                median_ms_per_step=[statistics.median(values) / steps / 1e6 for values in zip(*pairs)])
        result[stage] = summaries
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
    shared_protocol = RECORD / "protocol.json"
    protocol_file = RECORD / "trajectory-protocol.json"
    base = json.loads(shared_protocol.read_text())
    protocol = json.loads(protocol_file.read_text())
    env = isolated_go_environment()
    catalog = ROOT / "validation/hf/model-profiles.json"
    corpus = ROOT / "validation/quality/corpus.json"
    sources = [ROOT / name for name in ("cmd/monolith/context_sweep_perf_test.go", "cmd/monolith/inference_perf_test.go",
                                        "go.mod", "go.sum")]
    probe = RECORD / "probe_test.go.txt"
    trajectory = RECORD / "trajectory_test.go.txt"
    patch = PREVIOUS / "candidate.patch"
    inputs = {p: sha(p) for p in [ROOT / RUNTIME, catalog, corpus, probe, trajectory, patch, shared_protocol,
                                protocol_file, Path(__file__).resolve(), RECORD / "run.py",
                                ROOT / "scripts/compare_inference.py", ROOT / "scripts/measure_context_sweep.py",
                                ROOT / "scripts/context_sweep_timing.py", ROOT / "scripts/quant_quality.py", *sources]}
    if inputs[ROOT / RUNTIME] != base["runtime_sha256"]:
        raise ValueError("use the frozen reference worktree")
    model = next(m for m in json.loads(catalog.read_text())["models"] if m["id"] == "llama32-3b")
    if (model["repo"], model["revision"]) != (base["model"], base["model_revision"]):
        raise ValueError("unexpected model revision")
    assets = {args.model.resolve() / name: digest for name, digest in model["files"].items()}
    if any(sha(path) != digest for path, digest in assets.items()):
        raise ValueError("model file hash mismatch")
    (build / "monolith.go").write_text(staged_runtime(base, patch, build, env))
    (build / "adjacent_test.go").write_text(replace_once(probe.read_text(),
        "contextSweepStageProbe = measureAdjacentHeads", "contextSweepStageProbe = measureHeadTrajectories") + schedule_constants(base))
    (build / "trajectory_test.go").write_text(trajectory.read_text() + constants(protocol))
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
    print("Running alternating seven-token trajectories", flush=True)
    with (output / "probe.log").open("x") as log:
        resources = run_measured([binary, "-test.run=^TestHFContextSweep$", "-test.v", "-test.timeout=10m"],
                                 cwd=build, env=run_env, stdout=log, stderr=subprocess.STDOUT, timeout=630)
    journal = output / "cases.jsonl"
    events, error = read_journal(journal)
    if error:
        raise ValueError(error)
    validate_completed(events, protocol["kv"], protocol["sessions"], [protocol["prefix"]], True)
    metrics = analyze(events[-2]["replays"], protocol, events[1]["decode"])
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
