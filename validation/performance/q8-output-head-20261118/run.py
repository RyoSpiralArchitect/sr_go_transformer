#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Run the isolated Q8 output-head experiment against the frozen runtime."""

import argparse
import json
import math
from pathlib import Path
import platform
import re
from statistics import median
import subprocess
import sys

RECORD = Path(__file__).resolve().parent
ROOT = RECORD.parents[2]
sys.path.insert(0, str(ROOT / "scripts"))
from compare_inference import isolated_go_environment
from quant_quality import run_measured, sha

HEAD = "linearIntoWithExecutor(executor, w.Logits[:heads*c.Vocab], w.N[:heads*d], head, heads)"


def replace_once(text, old, new):
    if text.count(old) != 1:
        raise ValueError("unexpected probe source: " + old)
    return text.replace(old, new, 1)


def mode_orders(protocol):
    modes = protocol["modes"]
    return [[modes[(i + j) % len(modes)] for j in protocol["mode_order_seed"]]
            for i in range(len(modes))]


def unroll_output_pair(name, lookup):
    lines = [f"func {name}(x0, x1 *[64]float32, w0, w1 *[64]int8) (float32, float32, float32, float32) {{"]
    for row, out in ((0, 0), (0, 1), (1, 0), (1, 1)):
        lines.append("var " + ", ".join(f"{s}{row}{out}" for s in "abcd") + " float32")
    for column in range(0, 64, 2):
        a, b = "ab" if column % 4 == 0 else "cd"
        lines.append("{")
        for row in range(2):
            lines.append(f"x{row}a, x{row}b := x{row}[{column}], x{row}[{column+1}]")
        for out in range(2):
            codes = [f"w{out}[{i}]" for i in (column, column+1)]
            values = [f"q8ProbeFloats[uint8({code})]" if lookup else f"float32({code})" for code in codes]
            lines.append(f"v{out}a, v{out}b := {values[0]}, {values[1]}")
            for row in range(2):
                lines.append(f"{a}{row}{out} += x{row}a * v{out}a")
                lines.append(f"{b}{row}{out} += x{row}b * v{out}b")
        lines.append("}")
    sums = [f"(a{i}{j}+b{i}{j})+(c{i}{j}+d{i}{j})" for i in range(2) for j in range(2)]
    lines.extend(["return " + ", ".join(sums), "}"])
    return "\n".join(lines)


def generate_range(name, block, pair_block=None):
    # Both one-output arms also serve as the inner loop for odd tails.
    pair = ""
    if pair_block:
        pair = f"""
            for ; o+1 < end; o += 2 {{
                w0, w1 := w.Q8.Values[o*in:(o+1)*in], w.Q8.Values[(o+1)*in:(o+2)*in]
                s0, s1 := w.Q8.Scales[o*groups:(o+1)*groups], w.Q8.Scales[(o+1)*groups:(o+2)*groups]
                var a00, a01, a10, a11 float32
                for g := 0; g < groups; g++ {{
                    j := g*64
                    p00, p01, p10, p11 := {pair_block}((*[64]float32)(x0[j:j+64]), (*[64]float32)(x1[j:j+64]),
                        (*[64]int8)(w0[j:j+64]), (*[64]int8)(w1[j:j+64]))
                    a00 += p00 * s0[g]
                    a01 += p01 * s1[g]
                    a10 += p10 * s0[g]
                    a11 += p11 * s1[g]
                }}
                y[o], y[o+1], y[out+o], y[out+o+1] = a00, a01, a10, a11
            }}"""
    return f"""
func {name}(e *kernelExecutor, y, x []float32, w *Param) {{
    in, out := w.Cols, w.Rows
    groups := in/64
    x0, x1 := x[:in], x[in:2*in]
    e.parallel((out+31)/32, 2*in*out, func(lo, hi int) {{
        for tile := lo; tile < hi; tile++ {{
            o, end := tile*32, min(out, (tile+1)*32){pair}
            for ; o < end; o++ {{
                weights := w.Q8.Values[o*in:(o+1)*in]
                scales := w.Q8.Scales[o*groups:(o+1)*groups]
                var a0, a1 float32
                for g, scale := range scales {{
                    j := g*64
                    p0, p1 := {block}((*[64]float32)(x0[j:j+64]), (*[64]float32)(x1[j:j+64]),
                        (*[64]int8)(weights[j:j+64]))
                    a0 += p0 * scale
                    a1 += p1 * scale
                }}
                y[o], y[out+o] = a0, a1
            }}
        }}
    }})
}}
"""


def generate_kernels(source, orders):
    dot = source[source.index("func dotQ8PairBlock64("):source.index("func q8NeedsWideSum(")]
    dot = dot[:dot.index("\n}\n")+3]
    lookup = replace_once(dot, "func dotQ8PairBlock64(", "func q8ProbeLookupBlock(")
    lookup, n = re.subn(r"float32\(w\[(\d+)\]\)", r"q8ProbeFloats[uint8(w[\1])]", lookup)
    if n != 64:
        raise ValueError("unexpected Q8 block shape")
    schedule = ",\n".join("{" + ", ".join(map(json.dumps, row)) + "}" for row in orders)
    return "\n".join([
        "package main", "var q8ProbeOrders = [][]string{\n" + schedule + ",\n}", lookup,
        unroll_output_pair("q8ProbePairedBlock", False), unroll_output_pair("q8ProbePairedLookupBlock", True),
        generate_range("q8ProbeAligned", "dotQ8PairBlock64"),
        generate_range("q8ProbeLookup", "q8ProbeLookupBlock"),
        generate_range("q8ProbePaired", "dotQ8PairBlock64", "q8ProbePairedBlock"),
        generate_range("q8ProbePairedLookup", "q8ProbeLookupBlock", "q8ProbePairedLookupBlock"),
    ])


def prepare_model_probe(text, protocol):
    text = replace_once(text, "type inferencePerfTrial struct {", """type inferencePerfTrial struct {
	Mode string `json:"mode"`
	HeadNS []int64 `json:"head_ns"`""")
    start = text.index('order, err := perfCaseOrder(os.Getenv("MONOLITH_PERF_CASE_ORDER"))')
    end = text.index("\n\tctx, cancel", start)
    order = ", ".join(map(str, protocol["model_cases"]["session_order"]))
    text = text[:start] + f"order := []int{{{order}}}" + text[end:]
    text = replace_once(text, "for _, sessions := range order {", "for index, sessions := range order {")
    text = replace_once(text, "run := func() inferencePerfTrial {", """run := func(mode string) inferencePerfTrial {
			probe := &q8HeadProbe{mode: mode, ns: make([]int64, 0, 8)}
			trialCtx := context.WithValue(ctx, q8HeadProbeKey{}, probe)""")
    text = replace_once(text, "m.prefillBorrowed(ctx, caches,", "m.prefillBorrowed(trialCtx, caches,")
    text = replace_once(text, "return result", "result.Mode, result.HeadNS = mode, probe.ns\n\t\t\treturn result")
    text = replace_once(text, "warmup := run()", 'warmup := run("reference")')
    return replace_once(text, "for trial := 0; trial < 3; trial++ {\n\t\t\tr := run()",
                        "for _, mode := range q8ProbeOrders[index/2] {\n\t\t\tr := run(mode)")


def paired(rounds, reference="reference"):
    return {
        mode: {
            "median_ms": median(row[mode] for row in rounds),
            "ratio_median": median(row[mode] / row[reference] for row in rounds),
            "ratios": [row[mode] / row[reference] for row in rounds],
        }
        for mode in rounds[0]
    }


def kernel_samples(path, protocol, orders):
    samples = {}
    pattern = re.compile(r"BenchmarkQ8HeadProbe/outputs(\d+)/round(\d+)/([a-z-]+)-4\s+"
                         r"(\d+)\s+(\d+(?:\.\d+)?) ns/op\s+\d+ B/op\s+\d+ allocs/op")
    for line in path.read_text().splitlines():
        if match := pattern.fullmatch(line.strip()):
            out, round_id, mode, count, ns = match.groups()
            if int(count) != protocol["kernel"]["iterations"] or float(ns) <= 0:
                raise ValueError("invalid kernel timing")
            samples.setdefault(int(out), []).append((int(round_id), mode, float(ns) / 1e6))
    if sorted(samples) != protocol["kernel"]["outputs"]:
        raise ValueError("kernel output shapes differ")
    expected = [(i, m) for i, order in enumerate(orders) for m in order]
    result = {}
    for out, rows in samples.items():
        if [(i, m) for i, m, _ in rows] != expected:
            raise ValueError("kernel timing order differs")
        rounds = [{mode: ms for i, mode, ms in rows if i == j} for j in range(len(orders))]
        result[str(out)] = {
            "versus_reference": paired(rounds),
            "conversion_effect": paired(rounds, "aligned")["lookup"],
            "tiling_effect": paired(rounds, "aligned")["paired"],
            "conversion_with_tiling": paired(rounds, "paired")["paired-lookup"],
        }
    return result


def model_samples(report, protocol, orders):
    cases = protocol["model_cases"]
    session_order = cases["session_order"]
    plan = report["plan"]
    config = plan["config"]
    kv_bytes = 2 * 4 * config["layers"] * config["kv_heads"] * (config["dim"] // config["heads"])
    if (report["case_order"] != session_order or [c["sessions"] for c in report["cases"]] != session_order
            or report["prefill_tokens_per_session"] != cases["prefill_tokens_per_session"]
            or report["decode_steps"] != cases["decode_calls"] or report["kernel_workers"] != protocol["workers"]
            or plan["weight_format"] != cases["weights"] or plan["kv_bytes_per_token"] != kv_bytes
            or config["dim"] != protocol["kernel"]["inputs"] or config["vocab"] != protocol["kernel"]["outputs"][-1]):
        raise ValueError("model protocol changed")
    steps = cases["decode_calls"]
    identities, samples = {}, {1: [], 2: []}
    for i, case in enumerate(report["cases"]):
        n = case["sessions"]
        trials = case["trials"]
        if [row["mode"] for row in trials] != orders[i // 2]:
            raise ValueError("model mode order changed")
        if len(case["prompt_ids"]) != n or any(len(ids) != cases["prefill_tokens_per_session"] for ids in case["prompt_ids"]):
            raise ValueError("incomplete prompt")
        values = {key: {} for key in ("prefill", "prefill_head", "decode", "decode_head")}
        for row in trials:
            signature = (case["prompt_ids"], row["token_ids"], row["logits_sha256"],
                         row["kv_sha256"], row["workspace_bytes"])
            if identities.setdefault(n, signature) != signature:
                raise ValueError("numerical or workspace mismatch")
            head = row["head_ns"]
            seconds = [row["prefill_seconds"], *row["decode_step_seconds"]]
            if (len(head) != steps + 1 or len(seconds) != steps + 1 or len(row["token_ids"]) != n
                    or any(len(ids) != steps + 1 for ids in row["token_ids"])
                    or any(not math.isfinite(v) or v <= 0 for v in seconds)
                    or any(h <= 0 or h > s * 1e9 + 1 for h, s in zip(head, seconds))
                    or not math.isclose(sum(seconds[1:]), row["decode_seconds"])):
                raise ValueError("incomplete or invalid timing interval")
            mode = row["mode"]
            values["prefill"][mode] = seconds[0] * 1e3
            values["prefill_head"][mode] = head[0] / 1e6
            values["decode"][mode] = sum(seconds[1:]) * 1e3 / steps
            values["decode_head"][mode] = sum(head[1:]) / 1e6 / steps
        samples[n].append(values)
    return {str(n): dict(workspace_bytes=identities[n][-1], **{
        key: paired([row[key] for row in rounds]) for key in rounds[0]
    }) for n, rounds in samples.items()}


def decision(kernels, model):
    used = (model["1"]["prefill"], model["1"]["decode"], model["1"]["decode_head"],
            model["2"]["prefill"], model["2"]["decode"], model["2"]["decode_head"])
    controls = all(0.95 <= row["control"]["ratio_median"] <= 1.05 for row in used)
    eligible = {}
    for mode in ("aligned", "lookup", "paired", "paired-lookup"):
        head = model["2"]["decode_head"][mode]
        eligible[mode] = (
            controls and kernels["128256"]["versus_reference"][mode]["ratio_median"] <= 0.95
            and head["ratio_median"] <= 0.90 and sum(r < 1 for r in head["ratios"]) >= 5
            and model["2"]["decode"][mode]["ratio_median"] <= 0.99
            and all(row[mode]["ratio_median"] <= 1.05 for row in used[:4])
        )
    return dict(same_path_controls_pass=controls, advance=eligible)


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
    orders = mode_orders(protocol)
    env = isolated_go_environment()
    runtime = ROOT / "cmd/monolith/monolith.go"
    model_probe = ROOT / "cmd/monolith/inference_perf_test.go"
    kernel_probe = RECORD / "probe_test.go.txt"
    catalog = ROOT / "validation/hf/model-profiles.json"
    corpus = ROOT / "validation/quality/corpus.json"
    modules = [ROOT / name for name in ("go.mod", "go.sum")]
    inputs = {p: sha(p) for p in [runtime, model_probe, kernel_probe, catalog, corpus, protocol_file,
                                Path(__file__).resolve(), ROOT / "scripts/compare_inference.py",
                                ROOT / "scripts/quant_quality.py", *modules]}
    if inputs[runtime] != protocol["runtime_sha256"]:
        raise ValueError("runtime does not match the frozen input")
    model = next(m for m in json.loads(catalog.read_text())["models"] if m["id"] == "llama32-3b")
    if (model["repo"], model["revision"]) != (protocol["model"], protocol["model_revision"]):
        raise ValueError("model catalog differs")
    assets = {args.model.resolve() / name: digest for name, digest in model["files"].items()}
    if any(sha(path) != digest for path, digest in assets.items()):
        raise ValueError("model file hash mismatch")
    source = runtime.read_text()
    (build / "monolith.go").write_text(replace_once(source, HEAD, HEAD.replace("linearIntoWithExecutor(", "q8HeadProbeTimed(ctx, ")))
    (build / "inference_perf_test.go").write_text(prepare_model_probe(model_probe.read_text(), protocol))
    (build / "q8_head_test.go").write_bytes(kernel_probe.read_bytes())
    (build / "q8_kernels_test.go").write_text(generate_kernels(source, orders))
    for path in modules:
        (build / path.name).write_bytes(path.read_bytes())
    build_inputs = {path: sha(path) for path in build.iterdir()}
    binary = build / "probe.test"

    def run(cmd, name, timeout, run_env=env):
        with (output / name).open("x") as log:
            return run_measured(cmd, cwd=build, env=run_env, stdout=log, stderr=subprocess.STDOUT,
                                timeout=timeout)

    run(["go", "test", "-race", "-count=1", "-run", "^TestQ8HeadProbeExact$"], "exact.log", 300,
        dict(env, CGO_ENABLED="1"))
    run(["go", "test", "-c", "-trimpath", "-o", binary, "."], "build.log", 300)
    binary_hash = sha(binary)
    print("Bitwise fixture tests passed. Measuring synthetic heads.", flush=True)
    run([binary, "-test.run=^$", "-test.bench=^BenchmarkQ8HeadProbe$",
         f"-test.benchtime={protocol['kernel']['iterations']}x", "-test.count=1"], "kernels.txt", 240)
    kernel = kernel_samples(output / "kernels.txt", protocol, orders)
    print("Synthetic heads complete. Measuring pinned model.", flush=True)
    run_env = dict(env, MONOLITH_PERF_MODEL=str(args.model.resolve()), MONOLITH_PERF_CORPUS=str(corpus),
                   MONOLITH_PERF_FORMAT=protocol["model_cases"]["weights"], MONOLITH_PERF_OUTPUT=str(output / "model.json"))
    resources = run([binary, "-test.run=^TestHFInferencePerformance$", "-test.v", "-test.timeout=12m"],
                    "model.log", 750, run_env)
    if any(sha(path) != digest for path, digest in (inputs | assets | build_inputs).items()) or sha(binary) != binary_hash:
        raise ValueError("probe inputs changed during measurement")
    model_results = model_samples(json.loads((output / "model.json").read_text()), protocol, orders)
    receipt = {
        "settings": {"host": platform.platform(), "go": subprocess.check_output(["go", "version"], env=env, text=True).strip()},
        "inputs_sha256": {str(p.relative_to(ROOT)): digest for p, digest in inputs.items()},
        "model_files": model["files"],
        "build_sources_sha256": {p.name: digest for p, digest in build_inputs.items()},
        "binary_sha256": binary_hash,
        "output_sha256": {name: sha(output / name) for name in ("exact.log", "kernels.txt", "model.json")},
        "model_resources": resources,
        "kernel": kernel, "model": model_results, "decision": decision(kernel, model_results),
    }
    (output / "receipt.json").write_text(json.dumps(receipt, indent=2, allow_nan=False) + "\n")
    print(json.dumps(receipt["decision"]), flush=True)


if __name__ == "__main__":
    main()
