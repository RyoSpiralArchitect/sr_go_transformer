#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Check the frozen placement schedule and compare matched samples."""

import argparse
from collections import Counter
from itertools import combinations
import json
from pathlib import Path
from statistics import median


HERE = Path(__file__).resolve().parent


def require(condition, message):
    if not condition:
        raise ValueError(message)


def stats(rows, num, denom):
    ratios = [r[num]/r[denom] for r in rows]
    return dict(median=median(ratios), low=min(ratios), high=max(ratios),
                wins=sum(r<1 for r in ratios), median_abs_from_one=median(abs(r-1) for r in ratios),
                ratios=ratios)


def stable(spec, m):
    lo, hi = spec["same_path_median_range"]
    return lo <= m["median"] <= hi and m["median_abs_from_one"] <= spec["same_path_median_abs_from_one_max"]


def fast(spec, m):
    return m["median"] <= spec["max_speed_ratio"] and m["wins"] >= spec["min_wins_out_of_10"]


def analyze(protocol, journals):
    arms, orders, crit = protocol["arms"], protocol["orders"], protocol["criteria"]
    pairs = list(combinations(arms,2))
    require(len(orders) == 10 and len(arms) == 5, "unexpected schedule width")
    require(all(Counter(o) == Counter(arms) for o in orders), "round arms differ")
    require(all(Counter(o[i] for o in orders) == Counter(dict.fromkeys(arms,2)) for i in range(len(arms))),
            "imbalanced positions")
    require(all(sum(o.index(a)<o.index(b) for o in orders) == 5 for a,b in pairs), "imbalanced pair order")
    require(Counter(x for o in orders for x in zip(o,o[1:])) ==
            Counter({(a,b):2 for a in arms for b in arms if a!=b}), "imbalanced predecessor order")
    require(len(journals) == len(protocol["blocks"]), "missing block")

    decisions = dict(controls_pass=True, inline_control_pass=True, placement_pass=True, native_pass=True)
    phases = []
    for block, (schedule, raw) in enumerate(zip(protocol["blocks"], journals, strict=True)):
        events = iter(raw)
        for n in schedule["workers"]:
            sequence = orders[::-1] if n == schedule["reverse_orders_at"] else orders
            for shape in schedule["shapes"]:
                require(shape in protocol["shapes"], "unknown shape")
                for stage in schedule["stages"]:
                    rows = []
                    for rnd, order in enumerate(sequence):
                        row = {}
                        for arm in order:
                            expected = dict(Block=block, Workers=n, Shape=shape, Stage=stage, Round=rnd, Arm=arm,
                                            Calls=protocol["calls_per_sample"])
                            event = next(events,{})
                            require(all(event.get(k) == v for k,v in expected.items()), f"expected {expected}")
                            ns = event.get("ElapsedNS")
                            require(type(ns) is int and ns > 0, "invalid timer")
                            row[arm] = ns
                        rows.append(row)
                    views = (pairs if stage=="down" else [("owner_control","owner"),("worker_control","worker"),
                                                           ("worker","owner"),("worker","native"),("owner","native")])
                    timings = {f"{a}/{b}":stats(rows,a,b) for a,b in views}
                    controls = (timings.values() if stage=="down" else
                                [timings["owner_control/owner"],timings["worker_control/worker"]])
                    phase = dict(block=block,workers=n,shape=shape,stage=stage,comparisons=timings,
                                 median_ms_per_call={a:median(r[a] for r in rows)/protocol["calls_per_sample"]/1e6
                                                     for a in arms},
                                 controls_pass=all(stable(crit,m) for m in controls))
                    decisions["controls_pass"] &= phase["controls_pass"]
                    if stage=="gate_up":
                        if n==1:
                            phase["inline_control_pass"] = stable(crit,timings["worker/owner"])
                            decisions["inline_control_pass"] &= phase["inline_control_pass"]
                        else:
                            phase["placement_pass"] = fast(crit,timings["worker/owner"])
                            phase["native_pass"] = fast(crit,timings["worker/native"])
                            decisions["placement_pass"] &= phase["placement_pass"]
                            decisions["native_pass"] &= phase["native_pass"]
                    phases.append(phase)
        require(next(events,None) is None, "trailing samples")
    return dict(**decisions, advances_to_model_confirmation=all(decisions.values()), phases=phases)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("journal_dir", type=Path)
    args = p.parse_args()
    protocol = json.loads((HERE/"protocol.json").read_text())
    journals = [[json.loads(s) for s in (args.journal_dir/f"block-{i}.jsonl").read_text().splitlines()]
                for i in range(len(protocol["blocks"]))]
    print(json.dumps(analyze(protocol,journals),indent=2,allow_nan=False))


if __name__ == "__main__":
    main()
