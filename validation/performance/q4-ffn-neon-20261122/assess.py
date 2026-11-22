#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Replay the frozen parity, order and timing checks from the raw JSONL log."""
import argparse
import hashlib
import json
from pathlib import Path
from statistics import median

PROTOCOL = Path(__file__).with_name("protocol.json")


def assess(path):
    spec = json.loads(PROTOCOL.read_text())
    limits = spec["limits"]
    data = path.read_bytes()
    events = iter(map(json.loads, data.splitlines()))

    def take(kind, **expected):
        event = next(events, {})
        if event.get("event") != kind or any(event.get(k) != v for k, v in expected.items()):
            raise ValueError(f"missing or unexpected {kind} event for {expected}")
        return event

    start = take("start", baseline=spec["baseline"], revision=spec["revision"], cpu=spec["cpu"], go=spec["go"])
    if (start["builds"]["A"]["native"], start["builds"]["B"]["native"]) != (False, True):
        raise ValueError("wrong linked backends")
    if start["inputs"][str(PROTOCOL.relative_to(PROTOCOL.parents[3]))] != hashlib.sha256(PROTOCOL.read_bytes()).hexdigest():
        raise ValueError("protocol digest differs")
    ready = [take("ready", arm=arm)["ready"] for arm in "AB"]
    if ready[0] != ready[1] or ready[0]["ready"]["weight_format"] != spec["weights"]:
        raise ValueError("model plan or source inputs differ")
    rows = []
    for index, (prefix, sessions) in enumerate(spec["cases"]):
        case = dict(prefix=prefix, sessions=sessions, kv=spec["kv"])
        warm = [take("warm", case=case, arm=arm)["result"] for arm in ("BA" if index%2 else "AB")]
        if warm[0] != warm[1]:
            raise ValueError("prefix or warm decode differs")
        reference = warm[0]["decode"]
        if (reference["Positions"] != [prefix+spec["forwards"]]*sessions or
                len(reference["IDs"]) != spec["forwards"]+1 or
                any(len(step) != sessions for step in reference["IDs"])):
            raise ValueError("incomplete decode")
        ratios, by_order = [], {"AB":[], "BA":[]}
        controls = {"A":[], "B":[]}
        times = {"A":[], "B":[]}
        for rnd, order in enumerate(spec["orders"]):
            if index%2:
                order = order[::-1]
            ns = {}
            for label in order:
                sample = take("sample", case=case, round=rnd, label=label)["sample"]
                if (sample["Signature"] != reference or len(sample["Ns"]) != spec["forwards"] or
                        any(not isinstance(n, int) or n <= 0 for n in sample["Ns"])):
                    raise ValueError(f"invalid replay for {case}, round {rnd}, {label}")
                ns[label] = sum(sample["Ns"])
            ratio = ns["B"]/ns["A"]
            ratios.append(ratio)
            by_order["AB" if order.index("A") < order.index("B") else "BA"].append(ratio)
            for arm in "AB":
                controls[arm].append(ns[arm.lower()]/ns[arm])
                times[arm].append(ns[arm]/(1e6*spec["forwards"]))
        end = take("end_case", case=case)
        lo, hi = limits["control_median_range"]
        controls = {a:dict(median=median(v), median_abs_from_one=median(abs(x-1) for x in v)) for a,v in controls.items()}
        stable = all(lo <= v["median"] <= hi and v["median_abs_from_one"] <= limits["control_median_abs_error_max"]
                     for v in controls.values())
        ratio, wins = median(ratios), sum(v<1 for v in ratios)
        orders = {k:median(v) for k,v in by_order.items()}
        speed = (ratio <= limits["single_median_max"] if sessions == 1 else
                 ratio <= limits["two_median_max"] and wins >= limits["two_min_wins"] and max(orders.values()) < 1)
        rows.append(dict(prefix=prefix,sessions=sessions,exact_replays=len(ratios)*4,
                         median_ms_per_forward={k:median(v) for k,v in times.items()},
                         median_ratio=ratio, wins=wins, order_medians=orders, controls=controls,
                         controls_pass=stable, speed_pass=speed, rss_kib=end["rss_kib"]))
    end = take("complete")
    if next(events, None) is not None:
        raise ValueError("unexpected trailing events")
    return dict(events_sha256=hashlib.sha256(data).hexdigest(), cases=rows,
                new_swapout_pages=end["memory"]["swapouts"]-start["memory"]["swapouts"],
                accepted=all(r["controls_pass"] and r["speed_pass"] for r in rows))


if __name__ == "__main__":
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("events", type=Path)
    result = assess(cli.parse_args().events)
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result["accepted"] else 1)
