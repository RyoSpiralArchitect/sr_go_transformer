#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Validate the frozen timing schedule and attribute the projection deltas."""

import argparse
from collections import Counter
from itertools import combinations, permutations
import json
from pathlib import Path
import re
from statistics import median


def require(condition, message):
    if not condition:
        raise ValueError(message)


def section(text, name):
    pattern = r"^TEXT [^\s]+\." + name + r"\(SB\)[^\n]*\n(.*?)(?=^TEXT |\Z)"
    body = re.findall(pattern, text, re.M | re.S)
    require(len(body) == 1, f"missing or duplicated symbol {name}")
    return body[0]


def codegen(spec, blocks, ranges, source):
    result = {}
    for form, count in spec["static_block_activation_values"].items():
        tag = form.title()
        body = section(blocks, "gateUp"+tag+"Block")
        body = re.split(r"\bRET\b", body, maxsplit=1)[0]
        call = section(ranges, "gateUp"+tag+"Range")
        require(re.search(r"\bCALL .+\.gateUp"+tag+r"Block\(SB\)", call), f"unused {form} block")
        # Go can reuse an activation argument's register on the last
        # block value. Match the instruction's source line and the
        # expected base at each load, rather than counting table loads.
        loads = Counter()
        lines = source.splitlines()
        for line, op, reg in re.findall(
                r"kernels_test\.go:(\d+)\s+0x[0-9a-f]+\s+[0-9a-f]+\s+(FLDPS|FMOVS)\s+"
                r"(?:\d+)?\(R([0-3])\),", body):
            assignment = re.match(r"\s*[vw][01]0, [vw][01]1 := ([xu][01])\[", lines[int(line)-1])
            if assignment and reg == dict(x0="0", x1="1", u0="2", u1="3")[assignment[1]]:
                loads[op] += 1
        values = loads["FLDPS"]*2 + loads["FMOVS"]
        arithmetic = len(re.findall(r"\bFMADDS\b",body))
        require(values == count and arithmetic == spec["static_block_multiplications_and_additions"],
                f"unexpected {form} code generation: {values} loads, {arithmetic} FMAs")
        result[form] = dict(activation_value_loads=values, load_instructions=dict(loads), fmas=arithmetic)
    return result


def paired(a, b, samples):
    elapsed = [row[a]/row[b] for row in samples]
    return dict(median=median(elapsed), abs_from_one=median(abs(v-1) for v in elapsed),
                low=min(elapsed), high=max(elapsed), wins=sum(v<1 for v in elapsed), ratios=elapsed)


def within_control(spec, report):
    lo, hi = spec["control_median_range"]
    return lo <= report["median"] <= hi and report["abs_from_one"] <= spec["control_absolute_from_one_median_max"]


def within_speed(spec, report):
    return report["median"] <= spec["max_speed_ratio"] and report["wins"] >= spec["min_wins_per_10_pair_block"]


def analyze(spec, journals):
    modes, orders = spec["modes"], spec["orders"]
    require(all(sorted(o) == sorted(modes) for o in orders), "order lacks a mode")
    require(all(Counter(row[i] for row in orders) == Counter(dict.fromkeys(modes,2)) for i in range(len(modes))),
            "position imbalance")
    require(all(sum(row.index(m) < row.index(n) for row in orders)*2 == len(orders)
                for m,n in combinations(modes,2)), "pair order imbalance")
    require(len(journals) == len(spec["blocks"]), "missing blocks")
    result = []
    decisions = dict(control_pass=True, packed_pass=True, net_shared_pass=True, loads_only_pass=True)
    for block, (raw, plan) in enumerate(zip(journals,spec["blocks"],strict=True)):
        events = iter(raw)
        for workers in plan["workers"]:
            schedule = orders[::-1] if workers == plan["reverse_orders_at"] else orders
            for stage in plan["stages"]:
                samples = []
                for index, order in enumerate(schedule):
                    row = {}
                    for mode in order:
                        event = next(events,{})
                        want = dict(Block=block,Workers=workers,Round=index,Stage=stage,Mode=mode,Calls=spec["calls_per_sample"])
                        require(all(event.get(k) == v for k,v in want.items()), f"expected {want}")
                        ns = event["ElapsedNS"]
                        require(type(ns) is int and ns > 0, f"invalid sample for {want}")
                        row[mode] = ns
                    samples.append(row)
                outcome = dict(block=block,workers=workers,stage=stage, ms={m:median(r[m] for r in samples)
                                                                          /spec["calls_per_sample"]/1e6 for m in modes})
                comparisons = [("control","reference"),("packed","reference"),("split","packed"),
                               ("shared","split"),("shared","reference")]
                if stage == "down":
                    # Each label runs identical code on the same frozen
                    # buffer. Check every pair so phase position drift is visible.
                    comparisons = list(combinations(modes,2))
                outcome["pairs"] = {f"{a}/{b}":paired(a,b,samples) for a,b in comparisons}
                if stage == "down":
                    outcome["control_pass"] = all(within_control(spec,p) for p in outcome["pairs"].values())
                else:
                    p = outcome["pairs"]
                    outcome["control_pass"] = within_control(spec,p["control/reference"])
                    for key, comparison in (("packed_pass","packed/reference"),("net_shared_pass","shared/reference"),
                                            ("loads_only_pass","shared/split")):
                        outcome[key] = within_speed(spec,p[comparison])
                        decisions[key] = decisions[key] and outcome[key]
                decisions["control_pass"] = decisions["control_pass"] and outcome["control_pass"]
                result.append(outcome)
        require(next(events,None) is None, "trailing samples")
    advance = []
    if decisions["control_pass"]:
        if decisions["packed_pass"]:
            advance.append("packed")
        if decisions["loads_only_pass"] and decisions["net_shared_pass"]:
            advance.append("shared")
    return dict(decision=decisions, advance_to_model=advance, phases=result)


def analyze_waves(spec, rows):
    orders = list(permutations(("reference","control","one_join")))
    require(len(orders) == spec["rounds_per_block"], "invalid number of wave rounds")
    events = iter(rows)
    results = []
    for block, workers in enumerate(spec["workers_by_block"]):
        for n in workers:
            samples = []
            schedule = orders[::-1] if n == spec["reverse_orders_at"][block] else orders
            for index, order in enumerate(schedule):
                row = {}
                for mode in order:
                    e = next(events,{})
                    want = dict(Block=block,Workers=n,Round=index,Stage="wave",Mode=mode,Calls=spec["calls_per_sample"])
                    require(all(e.get(k) == v for k,v in want.items()), f"expected {want}")
                    require(type(e["ElapsedNS"]) is int and e["ElapsedNS"] > 0, "invalid wave duration")
                    row[mode] = e["ElapsedNS"]
                samples.append(row)
            control, one = paired("control","reference",samples), paired("one_join","reference",samples)
            pass_control = within_control(spec,control)
            pass_one = (within_control(spec,one) if n == 1 else
                        one["median"] <= spec["max_speed_ratio"] and one["wins"] >= spec["minimum_wins"])
            results.append(dict(block=block, workers=n, control=control, one_join=one,
                                control_pass=pass_control, one_join_pass=pass_one))
    require(next(events,None) is None, "trailing wave samples")
    return dict(barrier_effect_pass=all(r["control_pass"] and r["one_join_pass"] for r in results), phases=results)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("run", type=Path)
    mode = p.add_mutually_exclusive_group()
    mode.add_argument("--waves", action="store_true", help="assess the barrier-only journal")
    mode.add_argument("--timings-only", action="store_true", help="reassess saved timings without a local build")
    args = p.parse_args()
    if args.waves:
        spec = json.loads(Path(__file__).with_name("barrier-protocol.json").read_text())
        rows = [json.loads(line) for line in (args.run/"waves.jsonl").read_text().splitlines()]
        print(json.dumps(analyze_waves(spec,rows),indent=2,allow_nan=False))
        return
    spec = json.loads(Path(__file__).with_name("protocol.json").read_text())
    folder = args.run
    journals = [[json.loads(line) for line in (folder/f"block-{block}.jsonl").read_text().splitlines()]
                for block in range(len(spec["blocks"]))]
    result = analyze(spec,journals)
    if not args.timings_only:
        static = codegen(spec,(folder/"blocks.s").read_text(),(folder/"ranges.s").read_text(),
                         (folder/"kernels_test.go").read_text())
        result = dict(codegen=static,**result)
    print(json.dumps(result,indent=2,allow_nan=False))


if __name__ == "__main__":
    main()
