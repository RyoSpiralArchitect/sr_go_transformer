#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Build a temporary projection probe, preserving the tracked runtime."""

import argparse
import json
import platform
from pathlib import Path
import subprocess
import sys

RECORD = Path(__file__).resolve().parent
ROOT = RECORD.parents[2]
sys.path.insert(0, str(ROOT / "scripts"))
from compare_inference import isolated_go_environment
from quant_quality import run_measured, sha


def replace_once(text, old, new):
    if text.count(old) != 1:
        raise ValueError("probe could not locate exactly one instance of " + old)
    return text.replace(old, new, 1)


def prepare_runtime(text):
    start = text.index("func (m *Model) prefillSelected(")
    end = text.index("\nfunc (m *Model) Step(", start)
    section = text[start:end]
    mark = '\tif err := ctx.Err(); err != nil {'
    at = section.index(mark)
    section = section[:at] + "\ttiming, _ := ctx.Value(q4ProjectionKey{}).(*q4ProjectionSpans)\n" + section[at:]
    for i, (dst, src, weight) in enumerate((("G", "N", "Gate"), ("U", "N", "Up"), ("Q", "G", "Down"))):
        args = f"executor, w.{dst}, w.{src}, b.{weight}, n)"
        section = replace_once(section, f"linearIntoWithExecutor({args}", f"q4Projection(timing, {i}, {args}")
    return text[:start] + section + text[end:]


def prepare_harness(text):
    text = replace_once(text, "type inferencePerfTrial struct {", """type inferencePerfTrial struct {
	Mode string `json:"mode"`
	PrefillRoles q4ProjectionSpans `json:"prefill_roles"`
	DecodeRoles q4ProjectionSpans `json:"decode_roles"`""")
    old_order = '''order, err := perfCaseOrder(os.Getenv("MONOLITH_PERF_CASE_ORDER"))
	if err != nil {
		t.Fatal(err)
	}'''
    text = replace_once(text, old_order, "order := []int{1, 2, 2, 1, 2, 1, 1, 2}")
    text = replace_once(text, "for _, sessions := range order {", "for index, sessions := range order {")
    text = replace_once(text, "run := func() inferencePerfTrial {", """run := func(mode string) inferencePerfTrial {
			e.q4Fn = func(lo, hi int) { q4ProbeRange(mode, &e.linear, lo, hi) }""")
    text = replace_once(text, "inferencePerfTrial{TokenIDs:", "inferencePerfTrial{Mode: mode, TokenIDs:")
    text = replace_once(text, """started := time.Now()
				logits, err := m.prefillBorrowed(ctx,""", """spans := &result.DecodeRoles
				if step == 0 {
					spans = &result.PrefillRoles
				}
				timedCtx := context.WithValue(ctx, q4ProjectionKey{}, spans)
				started := time.Now()
				logits, err := m.prefillBorrowed(timedCtx,""")
    text = replace_once(text, "warmup := run()", 'warmup := run("reference")')
    text = replace_once(text, "for trial := 0; trial < 3; trial++ {\n\t\t\tr := run()",
                        "for _, mode := range q4ProbeOrders[index/2] {\n\t\t\tr := run(mode)")
    return text


def generated_kernels(source):
    start = source.index("func linearQ4Range(")
    end = source.index("\n// A full single-row tile", start)
    direct_range = replace_once(source[start:end], "func linearQ4Range(", "func q4ProbeDirectRange(")
    direct_range = replace_once(direct_range, "dotQ4PairBlock64(", "q4ProbeDirectBlock(")
    start = source.index("func dotQ4PairBlock64(")
    end = source.index("\n// dotQ4Block64", start)
    direct_block = replace_once(source[start:end], "func dotQ4PairBlock64(", "func q4ProbeDirectBlock(")
    if direct_block.count("q4Pairs[w[") != 32:
        raise ValueError("unexpected two-row block shape")
    direct_block = direct_block.replace("q4Pairs[w[", "&q4Pairs[w[")

    tile_block = ["func q4ProbeTileBlock(x0, x1 *[64]float32, w0, w1 *[32]byte) (float32, float32, float32, float32) {"]
    for row in range(2):
        for out in range(2):
            tile_block.append("var " + ", ".join(f"{a}{row}{out}" for a in "abcd") + " float32")
    for pair in range(32):
        a, b = ("ab" if pair % 2 == 0 else "cd")
        tile_block.append("{")
        for row in range(2):
            tile_block.append(f"v{row}0, v{row}1 := x{row}[{2*pair}], x{row}[{2*pair+1}]")
        for out in range(2):
            tile_block.append(f"p{out} := &q4Pairs[w{out}[{pair}]]")
            for row in range(2):
                tile_block.append(f"{a}{row}{out} += v{row}0 * p{out}[0]")
                tile_block.append(f"{b}{row}{out} += v{row}1 * p{out}[1]")
        tile_block.append("}")
    sums = [f"(a{i}{j}+b{i}{j})+(c{i}{j}+d{i}{j})" for i in range(2) for j in range(2)]
    tile_block += ["return " + ", ".join(sums), "}"]
    return 'package main\n\nimport "runtime"\n\n' + direct_range + "\n" + direct_block + "\n" + "\n".join(tile_block) + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    build = output / "build"
    build.mkdir()
    env = isolated_go_environment()
    catalog = ROOT / "validation/hf/model-profiles.json"
    corpus = ROOT / "validation/quality/corpus.json"
    model = next(entry for entry in json.loads(catalog.read_text())["models"] if entry["id"] == "llama32-3b")
    assets = {args.model.resolve() / name: digest for name, digest in model["files"].items()}
    inputs = [ROOT / name for name in ("go.mod", "go.sum", "cmd/monolith/monolith.go", "cmd/monolith/inference_perf_test.go")]
    inputs += [RECORD / "probe_test.go.txt", RECORD / "protocol.json", Path(__file__).resolve(), catalog, corpus,
               ROOT / "scripts/compare_inference.py", ROOT / "scripts/quant_quality.py"]
    identities = {path: sha(path) for path in inputs}
    if any(sha(path) != digest for path, digest in assets.items()):
        raise RuntimeError("pinned model hash mismatch")
    source = inputs[2].read_text()
    (build / "monolith.go").write_text(prepare_runtime(source))
    (build / "inference_perf_test.go").write_text(prepare_harness(inputs[3].read_text()))
    (build / "q4_projection_test.go").write_bytes((RECORD / "probe_test.go.txt").read_bytes())
    (build / "q4_kernels_test.go").write_text(generated_kernels(source))
    for path in inputs[:2]:
        (build / path.name).write_bytes(path.read_bytes())
    build_sources = {path.name: sha(path) for path in build.iterdir()}
    binary = build / "probe.test"

    def call(cmd, log, timeout, run_env=env):
        with (output / log).open("x") as handle:
            return run_measured(cmd, cwd=build, env=run_env, stdout=handle, stderr=subprocess.STDOUT, timeout=timeout)

    call(["go", "test", "-race", "-count=1", "-run", "^TestQ4ProjectionVariants$"], "exact.log", 300,
         dict(env, CGO_ENABLED="1"))
    call(["go", "test", "-c", "-trimpath", "-o", str(binary), "."], "build.log", 300)
    binary_hash = sha(binary)
    print("Exactness passed. Measuring projection fixtures.", flush=True)
    call([binary, "-test.run=^$", "-test.bench=^BenchmarkQ4ProjectionRoles$", "-test.benchtime=100x",
          "-test.count=1"], "kernels.txt", 240)
    print("Fixtures complete. Measuring pinned model.", flush=True)
    run_env = dict(env, MONOLITH_PERF_MODEL=str(args.model.resolve()), MONOLITH_PERF_CORPUS=str(corpus),
                   MONOLITH_PERF_FORMAT="q4-mixed", MONOLITH_PERF_OUTPUT=str(output / "model.json"))
    resources = call([binary, "-test.run=^TestHFInferencePerformance$", "-test.v", "-test.timeout=12m"],
                     "model.log", 750, run_env)
    if (any(sha(path) != digest for path, digest in (identities | assets).items())
            or sha(binary) != binary_hash or any(sha(build / name) != digest for name, digest in build_sources.items())):
        raise RuntimeError("probe inputs changed during measurement")
    receipt = {
        "baseline": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip(),
        "source_sha256": {str(path.relative_to(ROOT)): digest for path, digest in identities.items()},
        "build_sources_sha256": build_sources,
        "binary_sha256": binary_hash,
        "host": platform.platform(),
        "go": subprocess.check_output(["go", "version"], env=env, text=True).strip(),
        "model": model["repo"],
        "revision": model["revision"],
        "model_files": model["files"],
        "model_resources": resources,
        "exactness_log_sha256": sha(output / "exact.log"),
        "kernel_log_sha256": sha(output / "kernels.txt"),
        "model_report_sha256": sha(output / "model.json"),
    }
    (output / "receipt.json").write_text(json.dumps(receipt, indent=2, allow_nan=False) + "\n")
    print("Complete. Raw timings and source identities recorded.", flush=True)


if __name__ == "__main__":
    main()
