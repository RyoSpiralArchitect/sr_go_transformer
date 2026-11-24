#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Check every replay and summarize the paired timings in events.jsonl."""
import argparse
import hashlib
import json
from pathlib import Path
from statistics import median

HERE = Path(__file__).resolve().parent


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
    root = HERE.parents[2]
    protocol = str((HERE / "protocol.json").relative_to(root))
    if start["inputs"][protocol] != hashlib.sha256((HERE / "protocol.json").read_bytes()).hexdigest():
        raise ValueError("protocol digest differs")
    catalog = json.loads((root / "validation/hf/model-profiles.json").read_text())["models"]
    model = next(m for m in catalog if m["id"] == spec["model_id"])
    if model["revision"] != spec["revision"] or start["assets"] != model["files"]:
        raise ValueError("model assets differ")
    ready = take("ready")
    if ready["ready"]["ready"]["weight_format"] != spec["weights"]:
        raise ValueError("unexpected model plan")
    cases = []
    for index, sessions in enumerate(spec["sessions"]):
        case = dict(sessions=sessions, prefix=spec["prefix"], kv=spec["kv"])
        warm = take("warm", case=case)
        signature = warm["go"]["decode"]
        steps = spec["forwards"]
        if (warm["neon"] != signature or signature["Positions"] != [spec["prefix"] + steps] * sessions
                or len(signature["IDs"]) != steps + 1 or any(len(row) != sessions for row in signature["IDs"])):
            raise ValueError("invalid warm output")
        ratios, times = [], {"A": [], "B": []}
        controls = {"A": [], "B": []}
        order_ratios = {"AB": [], "BA": []}
        for rnd, order in enumerate(spec["orders"]):
            order = order[::-1] if index % 2 else order
            ns = {}
            for label in order:
                sample = take("sample", sessions=sessions, round=rnd, label=label)["sample"]
                if (sample["Signature"] != signature or len(sample["Ns"]) != steps
                        or any(type(n) != int or n <= 0 for n in sample["Ns"])):
                    raise ValueError("inconsistent sample")
                ns[label] = sum(sample["Ns"])
            take("round_end", sessions=sessions, round=rnd)
            ratio = ns["B"] / ns["A"]
            ratios.append(ratio)
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
