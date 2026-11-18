#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Compare Q4 tile widths and block traversal on model-shaped fixtures."""

import argparse
import json
from pathlib import Path
from statistics import median, quantiles
import subprocess

from measure import RECORD, ROOT, RUNTIME, generate_triple, isolated_go_environment, replace_once, run_measured, sha, trajectory_code, instrument_runtime, PREVIOUS


def advance_range(source):
    name = "func linearQ4TwoRowOutputPairRange("
    start = source.index(name)
    end = source.index("\n}\n", start) + 3
    code = replace_once(source[start:end], name, "func linearQ4AdvanceBlockRange(")
    loop_start = code.index("\t\t\tfor g := 0; g < groups; g++ {")
    accumulation = code.index("\t\t\t\ta00 +=", loop_start)
    return code[:loop_start] + """			left, right := x0, x1
			for g, scale := range s0 {
				p00, p01, p10, p11 := dotQ4TwoRowOutputPair64(
					(*[64]float32)(left), (*[64]float32)(right), (*[32]byte)(w0), (*[32]byte)(w1))
				left, right = left[64:], right[64:]
				w0, w1 = w0[32:], w1[32:]
""" + code[accumulation:].replace("s0[g]", "scale")


def declarations(protocol):
    pairs = ",\n".join("{" + ", ".join(map(json.dumps, pair)) + "}" for pair in protocol["comparisons"])
    shapes = ", ".join("{" + ", ".join(map(str, shape)) + "}" for shape in protocol["shapes"])
    return ("\nvar q4MatrixPairs = [][2]string{\n" + pairs + ",\n}\n"
            f"var q4MatrixShapes = [][2]int{{{shapes}}}\n"
            f"const q4MatrixRounds = {protocol['rounds']}\n"
            f"const q4MatrixIterations = {protocol['iterations_per_arm']}\n")


def summarize(rows, protocol):
    expected = []
    pairs = protocol["comparisons"]
    for shape in protocol["shapes"]:
        for r in range(protocol["rounds"]):
            for slot in range(len(pairs)):
                i = (slot + r) % len(pairs)
                expected.append((shape, r, i, pairs[i][::-1] if r % 2 else pairs[i]))
    if [(s["shape"], s["round"], s["comparison"], s["order"]) for s in rows] != expected:
        raise ValueError("unexpected timing order")
    results = {}
    for shape in protocol["shapes"]:
        summary = {}
        for i, (a, b) in enumerate(pairs):
            samples = []
            for row in rows:
                if row["shape"] != shape or row["comparison"] != i:
                    continue
                values = row["elapsed_ns"]
                if len(values) != 2 or any(value <= 0 for value in values):
                    raise ValueError("invalid timing")
                samples.append(values[::-1] if a != b and row["round"] % 2 else values)
            ratios = [y/x for x, y in samples]
            summary[f"{b}/{a}"] = dict(ratios=ratios, median_ratio=median(ratios),
                quartiles=quantiles(ratios, method="inclusive"), faster=sum(r < 1 for r in ratios),
                median_ms=[median(values)/protocol["iterations_per_arm"]/1e6 for values in zip(*samples)])
        results[f"{shape[0]}x{shape[1]}"] = summary
    return results


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    protocol_path = RECORD/"matrix-protocol.json"
    protocol = json.loads(protocol_path.read_text())
    if (protocol["rows"], protocol["workers"]) != (2, 4):
        parser.error("the matrix fixture requires two rows and four workers")
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    build = output/"build"
    build.mkdir()
    base_protocol = RECORD/"protocol.json"
    probe = RECORD/"probe_test.go.txt"
    matrix = RECORD/"matrix_test.go.txt"
    trajectory = PREVIOUS/"trajectory_test.go.txt"
    sources = [ROOT/path for path in ("go.mod", "go.sum", "cmd/monolith/inference_perf_test.go",
                                      "cmd/monolith/context_sweep_perf_test.go")]
    materials = [RUNTIME, protocol_path, base_protocol, probe, matrix, trajectory, RECORD/"measure.py",
                 Path(__file__).resolve(), PREVIOUS/"run.py", PREVIOUS/"trajectory.py", *sources]
    inputs = {p: sha(p) for p in materials}
    if inputs[RUNTIME] != protocol["runtime_sha256"]:
        raise ValueError("unexpected runtime")
    text = RUNTIME.read_text()
    (build/"monolith.go").write_text(instrument_runtime(text))
    (build/"triple_test.go").write_text(generate_triple(text))
    (build/"matrix_test.go").write_text(matrix.read_text() + declarations(protocol) + "\n" + advance_range(text))
    (build/"trajectory_test.go").write_text(trajectory_code(trajectory.read_text(), json.loads(base_protocol.read_text())))
    (build/"probe_test.go").write_bytes(probe.read_bytes())
    for p in sources:
        (build/p.name).write_bytes(p.read_bytes())
    staged = {p: sha(p) for p in build.iterdir()}
    env = isolated_go_environment()
    binary = build/"matrix.test"
    subprocess.run(["go", "test", "-c", "-trimpath", "-o", binary, "."], cwd=build, env=env, check=True, timeout=300)
    raw = output/"samples.json"
    with (output/"test.log").open("x") as log:
        usage = run_measured([binary, "-test.run=^TestQ4MatrixComparisons$", "-test.v"],
                             cwd=build, env=dict(env, MONOLITH_Q4_MATRIX_OUTPUT=str(raw)),
                             stdout=log, stderr=subprocess.STDOUT, timeout=240)
    if any(sha(p) != digest for p, digest in (inputs | staged).items()):
        raise ValueError("probe inputs changed")
    result = dict(go=subprocess.check_output(["go", "version"], env=env, text=True).strip(),
                  binary_sha256=sha(binary), samples_sha256=sha(raw), resources=usage,
                  inputs_sha256={str(p.relative_to(ROOT)): value for p, value in inputs.items()},
                  build_sources_sha256={p.name: value for p, value in staged.items()},
                  metrics=summarize(json.loads(raw.read_text()), protocol))
    (output/"receipt.json").write_text(json.dumps(result, indent=2, allow_nan=False)+"\n")


if __name__ == "__main__":
    main()
