#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Validate the balanced journal without changing its decision bounds."""

import argparse
from collections import Counter
from itertools import combinations
import json
from pathlib import Path
import re
from statistics import median

HERE = Path(__file__).resolve().parent


def require(condition, message):
    if not condition:
        raise ValueError(message)


def paired(a, b, samples):
    ratios = [row[a] / row[b] for row in samples]
    return dict(median=median(ratios), low=min(ratios), high=max(ratios),
                wins=sum(r < 1 for r in ratios),
                median_abs_from_one=median(abs(r-1) for r in ratios), ratios=ratios)


def stable(gate, p):
    lo, hi = gate["control_median_range"]
    return lo <= p["median"] <= hi and p["median_abs_from_one"] <= gate["control_median_abs_from_one_max"]


def fast(gate, p):
    return p["median"] <= gate["elapsed_ratio_max"] and p["wins"] >= gate["min_wins_per_block"]


def analyze(spec, journals):
    modes, orders, gate = spec["modes"], spec["orders"], spec["gate"]
    require(all(set(row) == set(modes) and len(row) == len(modes) for row in orders), "not a permutation")
    require(all(Counter(order[pos] for order in orders) == Counter(dict.fromkeys(modes,2)) for pos in range(len(modes))),
            "position imbalance")
    require(all(sum(order.index(a) < order.index(b) for order in orders)*2 == len(orders)
                for a,b in combinations(modes,2)), "order imbalance")
    require(len(journals) == len(spec["blocks"]), "missing blocks")
    control_pass = retention_effect = net_improvement = True
    phases = []
    for index, (rows, layout) in enumerate(zip(journals,spec["blocks"],strict=True)):
        stream = iter(rows)
        for workers in layout["workers"]:
            schedule = orders[::-1] if workers == layout["reverse_orders_at"] else orders
            for stage in layout["stages"]:
                batch = []
                for round_, order in enumerate(schedule):
                    sample = {}
                    for mode in order:
                        shot = next(stream,{})
                        want = dict(Block=index,Workers=workers,Round=round_,Mode=mode,Stage=stage,
                                    Calls=spec["calls_per_sample"])
                        require(all(shot.get(k) == v for k,v in want.items()), f"expected {want}")
                        ns = shot.get("ElapsedNS")
                        require(type(ns) is int and ns > 0, "invalid sample")
                        sample[mode] = ns
                    batch.append(sample)
                subset = (list(combinations(modes,2)) if stage == "down" else
                          [("reference_control","reference"),("store_control","store"),("local","store"),
                           ("local","reference"),("store","reference")])
                stats = {f"{a}/{b}":paired(a,b,batch) for a,b in subset}
                controls = (stats.values() if stage == "down" else
                            [stats["reference_control/reference"],stats["store_control/store"]])
                controls_ok = all(stable(gate,p) for p in controls)
                control_pass = control_pass and controls_ok
                result = dict(block=index, workers=workers, stage=stage, control_pass=controls_ok,
                              ms_per_call={m:median(row[m] for row in batch)/spec["calls_per_sample"]/1e6 for m in modes},
                              comparisons=stats)
                if stage == "gate_up":
                    result["writeback_gate"] = fast(gate,stats["local/store"])
                    result["net_gate"] = fast(gate,stats["local/reference"])
                    retention_effect = retention_effect and result["writeback_gate"]
                    net_improvement = net_improvement and result["net_gate"]
                phases.append(result)
        require(next(stream,None) is None, "trailing samples")
    return dict(controls_pass=control_pass, writeback_gate=retention_effect, net_gate=net_improvement,
                advances_to_model_timing=control_pass and retention_effect and net_improvement,
                phases=phases)


def stores(source, objdump):
    """Count only the scalar stores to Up and the activated gate outputs."""
    by_function = {}
    code = source.splitlines()
    section = None
    for line in objdump.splitlines():
        if line.startswith("TEXT "):
            section = line.split("(SB)")[0].split(".")[-1]
            by_function[section] = Counter()
        match = re.search(r"generated_test\.go:(\d+)\s+0x[0-9a-f]+\s+[0-9a-f]+\s+"
                          r"(FMOVS|FSTPS)\s+(?:F\d+|\(F\d+,\s*F\d+\)),\s+(?:[^\s]*)\(R", line)
        if match and section:
            expr = code[int(match[1])-1].strip()
            if expr.startswith("y[o]"):
                by_function[section]["up_values"] += 2 if match[2] == "FSTPS" else 1
            if expr.startswith("gate["):
                by_function[section]["gate_values"] += 2 if match[2] == "FSTPS" else 1
    wanted = {"storeUpRange":{"up_values":6,"gate_values":6}, "localUpRange":{"gate_values":6}}
    require(by_function == wanted, f"pair/tail store audit differs: {by_function}")
    return dict(storeUpRange=dict(up_values=6,gate_values=6),localUpRange=dict(up_values=0,gate_values=6),
                note="Static sites: four values in the two-output loop plus two in the odd tail.")


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("run", type=Path)
    p.add_argument("--codegen", action="store_true", help="also verify static stores using the staged source and objdump")
    args = p.parse_args()
    spec = json.loads((HERE/"protocol.json").read_text())
    data = [[json.loads(l) for l in (args.run/f"block-{i}.jsonl").read_text().splitlines()]
            for i in range(len(spec["blocks"]))]
    result = analyze(spec,data)
    if args.codegen:
        result["static_store_counts"] = stores((args.run/"generated_test.go").read_text(),(args.run/"stores.s").read_text())
    print(json.dumps(result,indent=2,allow_nan=False))


if __name__ == "__main__":
    main()
