#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Validate frozen sample order and summarize paired projection timings."""

from collections import defaultdict
import json
import math
from pathlib import Path
import re
from statistics import median
import sys

from run import RECORD, sha

ROLES = ("gate", "up", "down")


def paired(rounds):
    reference = [r["reference"] for r in rounds]
    return {
        "reference_median": median(reference),
        **{
            mode: {
                "median": median(r[mode] for r in rounds),
                "ratios": [r[mode] / r["reference"] for r in rounds],
                "paired_median": median(r[mode] / r["reference"] for r in rounds),
            }
            for mode in ("control", "direct", "tile")
        },
    }


def read_kernels(path, orders, iterations):
    pattern = re.compile(r"BenchmarkQ4ProjectionRoles/(\S+)/(workers[14])/round(\d+)/(\w+)-4"
                         r"\s+(\d+)\s+(\d+(?:\.\d+)?) ns/op\s+\d+ B/op\s+\d+ allocs/op")
    data = defaultdict(list)
    for line in path.read_text().splitlines():
        if match := pattern.fullmatch(line):
            role, workers, round_id, mode, count, ns = match.groups()
            if int(count) != iterations:
                raise ValueError("wrong kernel iteration count")
            data[role, workers].append((int(round_id), mode, float(ns) / 1e6))
    if set(data) != {(role, workers) for role in ("gate-up", "down") for workers in ("workers1", "workers4")}:
        raise ValueError("wrong synthetic shapes or workers")
    expected = [(i, mode) for i, order in enumerate(orders) for mode in order]
    result = {}
    for (role, workers), samples in data.items():
        if [(i, mode) for i, mode, _ in samples] != expected:
            raise ValueError("kernel samples are incomplete or out of order")
        result[f"{role}/{workers}"] = paired([
            {mode: ms for i, mode, ms in samples if i == round_id} for round_id in range(len(orders))
        ])
    return result


def read_model(path, protocol):
    report = json.loads(path.read_text())
    config = report["plan"]["config"]
    if config["dim"] != 3072 or config["hidden"] != 8192 or config["layers"] != 28:
        raise ValueError("unexpected model dimensions")
    model = protocol["model"]
    session_order = [n for case in model["sessions_per_round"] for n in case]
    if (report["case_order"] != session_order or
        [c["sessions"] for c in report["cases"]] != session_order or
        report["kernel_workers"] != model["workers"] or
        report["prefill_tokens_per_session"] != model["prefill_tokens_per_session"] or
        report["decode_steps"] != model["decode_calls_per_trial"] or
        report["plan"]["weight_format"] != model["weights"].lower() or
        report["plan"]["kv_bytes_per_token"] != 2 * 4 * config["layers"] * config["dim"] // config["heads"] * config["kv_heads"]):
        raise ValueError("model protocol changed")
    steps = model["decode_calls_per_trial"]
    identities = {}
    samples = defaultdict(list)
    for index, case in enumerate(report["cases"]):
        n = case["sessions"]
        order = protocol["rounds"][index//2]
        trials = case["trials"]
        if [r["mode"] for r in trials] != order:
            raise ValueError("model samples are incomplete or out of order")
        round_data = defaultdict(dict)
        for trial in trials:
            mode = trial["mode"]
            signature = (case["prompt_ids"], trial["token_ids"], trial["logits_sha256"],
                         trial["kv_sha256"], trial["workspace_bytes"])
            if signature != identities.setdefault(n, signature):
                raise ValueError("numerical identity or workspace mismatch")
            if (len(trial["decode_step_seconds"]) != steps or
                any(not math.isfinite(t) or t <= 0 for t in trial["decode_step_seconds"]) or
                not math.isclose(sum(trial["decode_step_seconds"]), trial["decode_seconds"])):
                raise ValueError("invalid decode intervals")
            for phase, calls in (("prefill", 1), ("decode", steps)):
                seconds = trial[f"{phase}_seconds"]
                if not math.isfinite(seconds) or seconds <= 0:
                    raise ValueError("invalid model interval")
                round_data[phase][mode] = seconds * 1000 / calls
                spans = trial[f"{phase}_roles"]
                if (len(spans) != len(ROLES) or
                    any(span["calls"] != calls * config["layers"] or span["ns"] <= 0 for span in spans) or
                    sum(span["ns"] for span in spans) > seconds * 1e9 + 1):
                    raise ValueError("projection span coverage or elapsed time mismatch")
                for role, span in zip(ROLES, spans):
                    round_data[f"{phase}_{role}"][mode] = span["ns"] / 1e6 / calls
                ffn_ms = sum(span["ns"] for span in spans) / 1e6 / calls
                round_data[f"{phase}_ffn"][mode] = ffn_ms
                round_data[f"{phase}_other"][mode] = round_data[phase][mode] - ffn_ms
        for key, values in round_data.items():
            samples[n, key].append(values)
    return {
        str(n): {
            "workspace_bytes": identities[n][-1],
            **{key: paired(samples[n, key]) for sessions, key in samples if sessions == n},
        } for n in (1, 2)
    }


def main():
    output = Path(sys.argv[1])
    protocol = json.loads((RECORD / "protocol.json").read_text())
    receipt = json.loads((output / "receipt.json").read_text())
    if (sha(output / "kernels.txt") != receipt["kernel_log_sha256"]
            or sha(output / "model.json") != receipt["model_report_sha256"]
            or receipt["revision"] != protocol["model"]["revision"]
            or receipt["source_sha256"]["cmd/monolith/monolith.go"] != protocol["runtime_sha256"]):
        raise ValueError("receipt identity mismatch")
    kernels = read_kernels(output / "kernels.txt", protocol["rounds"], protocol["kernel"]["iterations_per_sample"])
    model = read_model(output / "model.json", protocol)
    controls = all(
        0.95 <= case[metric]["control"]["paired_median"] <= 1.05
        for case in model.values() for metric in ("prefill", "decode")
    )
    advance = {}
    for mode in ("direct", "tile"):
        decode = model["2"]["decode"][mode]
        guard = all(case[metric][mode]["paired_median"] <= 1.05
                    for case, metric in ((model["1"], "decode"), (model["1"], "prefill"), (model["2"], "prefill")))
        advance[mode] = (controls and guard and decode["paired_median"] <= 0.95
                         and sum(ratio < 1 for ratio in decode["ratios"]) >= 3)
    result = {"units": "milliseconds per batched call", "kernel": kernels, "model": model,
              "model_parity": True, "same_path_controls_within_gate": controls, "advance": advance}
    print(json.dumps(result, indent=2, allow_nan=False))


if __name__ == "__main__":
    main()
