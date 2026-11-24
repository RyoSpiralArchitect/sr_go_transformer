#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Check every replay and summarize the paired timings in events.jsonl."""
import argparse
import hashlib
import json
from pathlib import Path
import re
from statistics import median

from measure import ARCHIVE, CATALOG, CORPUS, FIXTURE, measured_sources, pinned_blob

HERE = Path(__file__).resolve().parent
RECORDED_BINARY_SHA256 = "285eddd975b323e6461bf8030d79ad3f90c0f16f538b073abad309a0755caaf7"
OBSERVATION_DRIVER_SHA256 = "86b5494750a702f772239cbd0650541b7d7abb394dad1c00b6ad5a35baa3f164"


def validate_signature(signature, sessions, position, steps, vocab):
    if not isinstance(signature, dict):
        raise ValueError("invalid output signature")
    for key in ("Logits", "KV"):
        if not isinstance(signature.get(key), str) or not re.fullmatch("[0-9a-f]{64}", signature[key]):
            raise ValueError(f"missing or invalid {key} digest")
    for key in ("Workspace", "KVBytes"):
        if type(signature.get(key)) != int or signature[key] <= 0:
            raise ValueError(f"invalid {key} byte count")
    ids = signature.get("IDs")
    positions = signature.get("Positions")
    if (not isinstance(positions, list) or len(positions) != sessions
            or any(type(p) != int or p != position for p in positions) or not isinstance(ids, list) or len(ids) != steps
            or any(not isinstance(row, list) or len(row) != sessions
                   or any(type(token) != int or not 0 <= token < vocab for token in row) for row in ids)):
        raise ValueError("invalid cache positions or greedy IDs")


def assess(path):
    spec = json.loads((HERE / "protocol.json").read_text())
    limits = spec["limits"]
    events = iter(map(json.loads, path.read_bytes().splitlines()))
    observations = []

    def take(kind, **expected):
        event = next(events, {})
        if event.get("event") != kind or any(event.get(k) != v for k, v in expected.items()):
            raise ValueError(f"expected {kind} {expected}")
        if kind in ("start", "ready", "warm", "round_end", "complete"):
            memory = event["memory"]
            if (type(memory["free_percent"]) != int or not 0 <= memory["free_percent"] <= 100
                    or type(memory["swapouts"]) != int or memory["swapouts"] < 0
                    or observations and memory["swapouts"] < observations[-1]["swapouts"]):
                raise ValueError("invalid memory observation")
            observations.append(memory)
        return event

    start = take("start", cpu=spec["cpu"], go=spec["go"], revision=spec["revision"])
    expected = {name: hashlib.sha256(data).hexdigest() for name, data in measured_sources().items()}
    if start.get("sources") != expected or start.get("binary") != RECORDED_BINARY_SHA256:
        raise ValueError("runtime, generated fixture or binary differs from the measured build")
    root = HERE.parents[2]
    shared = [HERE / "protocol.json", FIXTURE, ARCHIVE / "run.py", CORPUS, CATALOG,
              root / "scripts/compare_inference.py", root / "scripts/quant_quality.py"]
    inputs = {str(p.relative_to(root)): hashlib.sha256(pinned_blob(p.relative_to(root))).hexdigest() for p in shared}
    if hashlib.sha256((HERE / "protocol.json").read_bytes()).hexdigest() != inputs[str(shared[0].relative_to(root))]:
        raise ValueError("protocol digest differs")
    driver = HERE / "measure.py"
    driver_key = str(driver.relative_to(root))
    if not any(start.get("inputs") == {**inputs, driver_key: h} for h in
               (OBSERVATION_DRIVER_SHA256, hashlib.sha256(driver.read_bytes()).hexdigest())):
        raise ValueError("runner, protocol, corpus or helper inputs differ")
    catalog = json.loads((root / "validation/hf/model-profiles.json").read_text())["models"]
    model = next(m for m in catalog if m["id"] == spec["model_id"])
    if model["revision"] != spec["revision"] or start["assets"] != model["files"]:
        raise ValueError("model assets differ")
    ready = take("ready")
    if ready["ready"]["ready"]["weight_format"] != spec["weights"]:
        raise ValueError("unexpected model plan")
    vocab = ready["ready"]["ready"]["config"]["vocab"]
    cases = []
    for index, sessions in enumerate(spec["sessions"]):
        case = dict(sessions=sessions, prefix=spec["prefix"], kv=spec["kv"])
        warm = take("warm", case=case)
        signature = warm["go"]["decode"]
        steps = spec["forwards"]
        validate_signature(warm["go"]["checkpoint"], sessions, spec["prefix"], 1, vocab)
        validate_signature(signature, sessions, spec["prefix"] + steps, steps + 1, vocab)
        validate_signature(warm["neon"], sessions, spec["prefix"] + steps, steps + 1, vocab)
        if warm["neon"] != signature:
            raise ValueError("warm outputs differ")
        ratios, times = [], {"A": [], "B": []}
        repeats, pooled = [], []
        controls = {"A": [], "B": []}
        order_ratios = {"AB": [], "BA": []}
        for rnd, order in enumerate(spec["orders"]):
            order = order[::-1] if index % 2 else order
            ns = {}
            for label in order:
                sample = take("sample", sessions=sessions, round=rnd, label=label)["sample"]
                validate_signature(sample["Signature"], sessions, spec["prefix"] + steps, steps + 1, vocab)
                if (sample["Signature"] != signature or len(sample["Ns"]) != steps
                        or any(type(n) != int or n <= 0 for n in sample["Ns"])):
                    raise ValueError("inconsistent sample")
                ns[label] = sum(sample["Ns"])
            take("round_end", sessions=sessions, round=rnd)
            ratio = ns["B"] / ns["A"]
            ratios.append(ratio)
            repeats.append(ns["b"] / ns["a"])
            pooled.append((ns["B"] + ns["b"]) / (ns["A"] + ns["a"]))
            order_ratios["AB" if order.index("A") < order.index("B") else "BA"].append(ratio)
            for arm in "AB":
                controls[arm].append(ns[arm.lower()] / ns[arm])
                times[arm].append(ns[arm] / (steps * 1e6))
        end = take("end_case", sessions=sessions)
        control = {k:dict(median=median(v), median_abs_from_one=median(abs(x - 1) for x in v))
                   for k, v in controls.items()}
        low, high = limits["control_median_range"]
        stable = all(low <= c["median"] <= high and c["median_abs_from_one"] <= limits["control_median_abs_error_max"]
                     for c in control.values())
        wins = sum(v < 1 for v in ratios)
        speed = (median(ratios) <= limits["single_median_max"] and wins >= limits["single_min_wins"]
                 if sessions == 1 else median(ratios) <= limits["two_median_max"])
        cases.append(dict(sessions=sessions, exact_replays=4 * len(ratios), paired_median=median(ratios),
                          repeat_median=median(repeats), pooled_median=median(pooled),
                          median_ms_per_forward={k:median(v) for k,v in times.items()},
                          order_medians={k:median(v) for k,v in order_ratios.items()}, wins=wins,
                          control=control, control_pass=stable, speed_pass=speed, rss_kib=end["rss_kib"]))
    take("complete")
    if next(events, None) is not None:
        raise ValueError("unexpected trailing events")
    free = min(o["free_percent"] for o in observations)
    swaps = max(o["swapouts"] for o in observations)
    new_swaps = swaps - start["memory"]["swapouts"]
    memory_ok = free >= limits["min_free_percent"] and new_swaps <= limits["max_new_swapout_pages"]
    return dict(cases=cases, min_free_percent=free, new_swapouts=new_swaps,
                swapouts_after_load=swaps-ready["memory"]["swapouts"], memory_pass=memory_ok,
                accepted=memory_ok and all(c["control_pass"] and c["speed_pass"] for c in cases),
                events_sha256=hashlib.sha256(path.read_bytes()).hexdigest())


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("events", nargs="?", type=Path, default=HERE / "events.jsonl")
    args = parser.parse_args()
    print(json.dumps(assess(args.events), indent=2, allow_nan=False))
