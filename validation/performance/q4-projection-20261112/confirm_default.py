#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Compare default dispatch and the previous Q4 worker in one executable."""

import argparse
import hashlib
import json
import math
from pathlib import Path
from statistics import median
import subprocess

from run import RECORD, ROOT, isolated_go_environment, replace_once, run_measured, sha


def harness(text, protocol):
    text = replace_once(text, "type inferencePerfTrial struct {", """type inferencePerfTrial struct {
	Mode string `json:"mode"`""")
    start = text.index('order, err := perfCaseOrder(os.Getenv("MONOLITH_PERF_CASE_ORDER"))')
    end = text.index("\n\tctx, cancel", start)
    order = "[]int{" + ",".join(map(str, protocol["case_order"])) + "}"
    schedule = "[][4]string{" + ",".join(
        "{" + ",".join(json.dumps(mode) for mode in group) + "}"
        for group in protocol["mode_order"]
    ) + "}"
    text = text[:start] + f"order := {order}\n\tmodeOrder := {schedule}" + text[end:]
    text = replace_once(text, "type perfCase struct {", """type perfCase struct {
	Short bool `json:"two_row_prefill_only"`""")
    text = replace_once(text, "for _, sessions := range order {",
                        "for _, short := range []bool{false, true} {\n\tfor index, sessions := range order {")
    text = replace_once(text, "run := func() inferencePerfTrial {", """prefix, steps := 8, 8
		if short {
			prefix, steps = 2/sessions, 1
		}
		run := func(mode string) inferencePerfTrial {
			e.q4Fn = nil
			reference := mode == "reference" || mode == "control"
			baseWorker := func(lo, hi int) { referenceQ4Range(&e.linear, lo, hi) }""")
    text = replace_once(text, "chunks[i] = prompts[i]", "chunks[i] = prompts[i][:prefix]")
    text = replace_once(text, "inferencePerfTrial{TokenIDs:", "inferencePerfTrial{Mode: mode, TokenIDs:")
    text = replace_once(text, "for step := 0; step < 8; step++ {", """for step := 0; step < steps; step++ {
				if reference && ((short && step == 0) || (!short && sessions == 2 && step == 1)) {
					e.q4Fn = baseWorker
				}""")
    text = replace_once(text, "if cache.Pos != 15 {", "if cache.Pos != prefix+steps-1 {")
    text = replace_once(text, "warmup := run()", 'warmup := run("reference")')
    text = replace_once(text, "c := perfCase{Sessions: sessions, PromptIDs: prompts[:sessions]}", """c := perfCase{Short: short, Sessions: sessions, PromptIDs: make([][]int, sessions)}
		for i := range c.PromptIDs {
			c.PromptIDs[i] = prompts[i][:prefix]
		}""")
    text = replace_once(text, "for trial := 0; trial < 3; trial++ {\n\t\t\tr := run()",
                        "for _, mode := range modeOrder[index/2] {\n\t\t\tr := run(mode)")
    return replace_once(text, "\n\treport := map[string]any", "\n\t}\n\treport := map[string]any")


def summarize(report, protocol):
    order = protocol["case_order"]
    expected = [(short, sessions) for short in (False, True) for sessions in order]
    if [(case["two_row_prefill_only"], case["sessions"]) for case in report["cases"]] != expected:
        raise ValueError("case order mismatch")
    identity, samples = {}, {}
    for index, case in enumerate(report["cases"]):
        short, sessions = expected[index]
        trials = case["trials"]
        prefix, steps = (2 // sessions, 1) if short else (8, 8)
        if len(case["prompt_ids"]) != sessions or any(len(ids) != prefix for ids in case["prompt_ids"]):
            raise ValueError("prompt shape mismatch")
        round_id = (index % len(order)) // 2
        if [trial["mode"] for trial in trials] != protocol["mode_order"][round_id]:
            raise ValueError("mode order mismatch")
        for trial in trials:
            if (len(trial["token_ids"]) != sessions or any(len(ids) != steps for ids in trial["token_ids"])
                    or len(trial["decode_step_seconds"]) != steps - 1
                    or any(t <= 0 or not math.isfinite(t) for t in trial["decode_step_seconds"])
                    or not math.isclose(sum(trial["decode_step_seconds"]), trial["decode_seconds"])
                    or trial["prefill_seconds"] <= 0 or not math.isfinite(trial["prefill_seconds"])):
                raise ValueError("incomplete or invalid trial")
            key = (short, sessions)
            signature = (case["prompt_ids"], trial["token_ids"], trial["logits_sha256"],
                         trial["kv_sha256"], trial["workspace_bytes"])
            if identity.setdefault(key, signature) != signature:
                raise ValueError("numerical or workspace mismatch")
        for phase, calls in (("prefill", 1), ("decode", 7)):
            if short and phase == "decode":
                continue
            key = f"{'two_rows' if short else 'eight_tokens'}_s{sessions}_{phase}"
            samples.setdefault(key, []).append({
                trial["mode"]: trial[f"{phase}_seconds"] * 1000 / calls for trial in trials
            })
    output = {}
    for key, rounds in samples.items():
        pairs = {name: [row[a] / row[b] for row in rounds] for name, a, b in (
            ("candidate_over_reference", "candidate", "reference"),
            ("repeat_over_control", "repeat", "control"),
            ("control_over_reference", "control", "reference"),
            ("repeat_over_candidate", "repeat", "candidate"),
        )}
        output[key] = {
            "median_ms_by_mode": {name: median(row[name] for row in rounds) for name in rounds[0]},
            "ratios": pairs,
            "median_ratios": {name: median(values) for name, values in pairs.items()},
        }
    target = "eight_tokens_s2_decode"
    candidates = ("candidate_over_reference", "repeat_over_control")
    controls = ("control_over_reference", "repeat_over_candidate")
    passed = all(0.95 <= row["median_ratios"][control] <= 1.05 for row in output.values() for control in controls)
    passed &= all(row["median_ratios"][c] <= 1.05 for key, row in output.items() if key != target for c in candidates)
    passed &= all(output[target]["median_ratios"][c] <= 0.95 and
                  sum(ratio < 1 for ratio in output[target]["ratios"][c]) >= 3 for c in candidates)
    return {"passed": passed, "cases": output, "exact_trials": 64}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    build = output / "build"
    build.mkdir()
    protocol_file = RECORD / "adoption-protocol.json"
    protocol = json.loads(protocol_file.read_text())
    env = isolated_go_environment()
    manifest = ROOT / "validation/hf/model-profiles.json"
    catalog = json.loads(manifest.read_text())
    model = next(row for row in catalog["models"] if row["id"] == "llama32-3b")
    if model["revision"] != protocol["model_revision"]:
        raise ValueError("checkpoint revision changed")
    assets = {args.model.resolve() / name: digest for name, digest in model["files"].items()}
    corpus = ROOT / "validation/quality/corpus.json"
    runtime = ROOT / "cmd/monolith/monolith.go"
    probe = ROOT / "cmd/monolith/inference_perf_test.go"
    inputs = {path: sha(path) for path in (runtime, probe, corpus, manifest, protocol_file, Path(__file__).resolve(),
                                         RECORD / "run.py", ROOT / "scripts/compare_inference.py",
                                         ROOT / "scripts/quant_quality.py", ROOT / "go.mod", ROOT / "go.sum")}
    base = subprocess.check_output(["git", "show", protocol["runtime_base"] + ":cmd/monolith/monolith.go"], cwd=ROOT)
    if (inputs[runtime] != protocol["candidate_sha256"] or
            hashlib.sha256(base).hexdigest() != protocol["reference_sha256"]):
        raise ValueError("runtime source identity mismatch")
    if any(sha(path) != digest for path, digest in assets.items()):
        raise ValueError("model file hash mismatch")
    source = base.decode()
    start = source.index("func linearQ4Range(")
    end = source.index("\n// A full single-row tile", start)
    old_range = replace_once(source[start:end], "func linearQ4Range(", "func referenceQ4Range(")
    (build / "reference_test.go").write_text('package main\n\nimport "runtime"\n\n' + old_range)
    (build / "inference_perf_test.go").write_text(harness(probe.read_text(), protocol))
    for path in (runtime, ROOT / "go.mod", ROOT / "go.sum"):
        (build / path.name).write_bytes(path.read_bytes())
    binary = build / "probe.test"
    source_hashes = {path.name: sha(path) for path in build.iterdir()}
    subprocess.run(["go", "test", "-c", "-trimpath", "-o", binary, "."], cwd=build, env=env, check=True, timeout=300)
    binary_hash = sha(binary)
    disassembly = subprocess.check_output(["go", "tool", "objdump", "-s", r"\.linearQ4Range$", binary],
                                          env=env, text=True)
    if not any("CALL " in line and ".linearQ4TwoRowOutputPairRange(SB)" in line for line in disassembly.splitlines()):
        raise ValueError("default compiled range did not contain the candidate dispatch")
    run_env = dict(env, MONOLITH_PERF_MODEL=str(args.model.resolve()), MONOLITH_PERF_CORPUS=str(corpus),
                   MONOLITH_PERF_FORMAT="q4-mixed", MONOLITH_PERF_OUTPUT=str(output / "model.json"))
    print("Default dispatch found. Starting interleaved model trials.", flush=True)
    with (output / "model.log").open("x") as log:
        resources = run_measured([binary, "-test.run=^TestHFInferencePerformance$", "-test.v", "-test.timeout=12m"],
                                 cwd=build, env=run_env, stdout=log, stderr=subprocess.STDOUT, timeout=750)
    if (any(sha(path) != digest for path, digest in (inputs | assets).items())
            or any(sha(build / name) != digest for name, digest in source_hashes.items()) or sha(binary) != binary_hash):
        raise ValueError("inputs changed during run")
    summary = summarize(json.loads((output / "model.json").read_text()), protocol)
    receipt = {
        "summary": summary, "binary_sha256": binary_hash, "model_report_sha256": sha(output / "model.json"),
        "inputs_sha256": {str(path.relative_to(ROOT)): digest for path, digest in inputs.items()},
        "build_sources_sha256": source_hashes, "model_files": model["files"],
        "go_version": subprocess.check_output(["go", "version"], env=env, text=True).strip(),
        "model_resources": resources, "default_dispatch_present_in_binary": True,
    }
    (output / "receipt.json").write_text(json.dumps(receipt, indent=2, allow_nan=False) + "\n")
    print("Passed frozen comparison:", summary["passed"], flush=True)


if __name__ == "__main__":
    main()
