#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Recompute the paired timing decision from the raw event journal."""

import argparse
import json
from pathlib import Path
import re
from statistics import median

from pairs import layout, order, prefill_or_decode
from run import RECORD, ROOT, sha


def expect(condition, error):
    if not condition:
        raise ValueError(error)


def validate_signature(s, case, phase, steps, config):
    sessions = case["sessions"]
    positions = case["prefix"] + (steps if phase == "decode" else 0)
    pages = (positions+31)//32
    kv_dim = config["dim"]//config["heads"]*config["kv_heads"]
    capacity = (2 if case["kv"] == "f16" else 4)*pages*32*2*kv_dim*config["layers"]*sessions
    expect(s["Positions"] == [positions]*sessions and s["KVBytes"] == capacity and s["Workspace"] > 0 and
           len(s["IDs"]) == (steps+1 if phase == "decode" else 1) and
           all(len(row) == sessions and all(0 <= i < config["vocab"] for i in row) for row in s["IDs"]) and
           all(re.fullmatch(r"[0-9a-f]{64}", s[k]) for k in ("Logits","KV")),
           "signature differs from the frozen workload")


def report(rows, steps):
    a = [sum(r["left"]["Ns"]) for r in rows]
    b = [sum(r["right"]["Ns"]) for r in rows]
    ratios = [y/x for x,y in zip(a,b)]
    return dict(values=ratios, median=median(ratios), low=min(ratios), high=max(ratios),
                wins=sum(v<1 for v in ratios), median_abs_from_one=median(abs(v-1) for v in ratios),
                median_ms_per_call=[median(v)/steps/1e6 for v in [a,b]],
                ratio_by_first_arm={side:median(v for v,r in zip(ratios,rows) if r["first"] == side)
                                    for side in ("left","right")},
                ratio_by_block={block:median(v for v,r in zip(ratios,rows) if r["block"] == block)
                                for block in sorted({r["block"] for r in rows})},
                median_allocations=[median(r[s]["Allocations"] for r in rows) for s in ("left","right")],
                median_allocated_bytes=[median(r[s]["Allocated"] for r in rows) for s in ("left","right")],
                allocations_saved=median(r["left"]["Allocations"]-r["right"]["Allocations"] for r in rows))


def assess(spec, common, events, *, incomplete=False, direct=False):
    stream = iter(events)
    points = []

    class Incomplete(Exception):
        pass

    def take(kind, **expected):
        item = next(stream, None)
        if incomplete and item is None:
            raise Incomplete
        item = item or {}
        expect(item.get("event") == kind and all(item.get(k) == v for k,v in expected.items()),
               f"expected {kind} {expected}; got {item.get('event')}")
        if "memory" in item:
            points.append(item["memory"])
        return item

    start = take("start")
    for name in ("pairs.json", "pairs.py"):
        p = RECORD/name
        expect(start["inputs"][str(p.relative_to(ROOT))] == sha(p), f"{name} hash mismatch")
    build = start["build"]
    expect((build["host"], build["cpu"], build["go"], build["revision"]) ==
           ("Darwin/arm64", common["cpu"], common["go_version"], common["model_revision"]),
           "wrong host, Go version or model")
    expect({mode:b["sources"]["cmd/monolith/monolith.go"] for mode,b in build["builds"].items()} ==
           common["runtime_sha256"], "runtime hashes differ")
    contract = take("ready", worker="reference", mode="baseline")["reply"]
    expect(contract["executor_bytes"] == common["executor_bytes"] and
           contract["ready"]["weight_format"] == common["weights"], "executor footprint or format differs")
    config = contract["ready"]["config"]
    expect(config["dim"] % 64 == 0 and config["vocab"] >= 65536 and len(contract["prompts"]) == 2, "wrong head")
    rows, signatures = {}, {}
    left_mode = "baseline"
    complete = False
    first_missing = None
    try:
        for group, (block, lmode, rmode, cases, reverse, rounds) in enumerate(layout(spec)):
            if lmode != left_mode:
                expect(take("ready", worker="pair-direct", mode=lmode)["reply"] == contract, "direct left plan changed")
                left_mode = lmode
            expect(take("ready", worker=f"right-{group}", mode=rmode)["reply"] == contract, "right plan changed")
            take("group", group=group, block=block, left=lmode, right=rmode)
            comparison = rmode if lmode == "baseline" else "shared-over-pair"
            for i, idx in enumerate(cases):
                case = spec["cases"][idx]
                key = case["id"]
                for arm in order(reverse,i,0,0):
                    warm = take("warm", group=group, case=key, arm=arm)["signatures"]
                    expect(signatures.setdefault(key,warm) == warm, "warm-up results differ")
                    validate_signature(warm["checkpoint"],case,"prefill",0,config)
                for s, phase in enumerate(prefill_or_decode(case, reverse)):
                    steps = common["decode_steps"] if phase == "decode" else 1
                    signature = warm[phase]
                    validate_signature(signature,case,phase,steps,config)
                    samples = rows.setdefault(key,{}).setdefault(phase,{}).setdefault(comparison,[])
                    for r in range(rounds):
                        arms = order(reverse,i,s,r)
                        row = dict(first=arms[0], block=block)
                        for arm in arms:
                            value = take("sample", group=group, case=key, phase=phase, round=r, arm=arm)["sample"]
                            expect(value["Signature"] == signature, "parity failure")
                            expect(len(value["Ns"]) == steps and all(type(n) is int and n > 0 for n in value["Ns"]) and
                                   all(type(value[k]) is int and value[k] >= 0 for k in ("Allocations","Allocated")),
                                   "invalid timing/allocation samples")
                            row[arm] = value
                        samples.append(row)
                    take("checkpoint", group=group, case=key, phase=phase)
            take("end_group", group=group)
        take("complete")
        expect(next(stream,None) is None, "trailing events")
        complete = True
    except Incomplete:
        first_missing = (group, comparison) if 'comparison' in locals() else None
    floor = min(p["free_percent"] for p in points)
    swaps = points[-1]["swapouts"]-points[0]["swapouts"]
    memory_ok = (floor >= spec["group_min_free_percent"] and swaps <= spec["one_side_swapout_pages_max"]
                 and points[0]["free_percent"] >= spec["start_min_free_percent"])
    results, eligible = {}, {"pair":True,"shared":True}
    control_ok = share_ok = True
    for case in spec["cases"]:
        key = case["id"]
        results[key] = {}
        for stage in case["phases"]:
            steps = common["decode_steps"] if stage == "decode" else 1
            measures = results[key][stage] = {}
            for m, v in rows.get(key, {}).get(stage, {}).items():
                if {r["first"] for r in v} != {"left","right"}:
                    continue
                stat = measures[m] = report(v,steps)
                expected = spec["direct"]["rounds"] if m == "shared-over-pair" else spec["rounds_per_block"]*len(spec["blocks"])
                stat.update(pairs=len(v), expected_pairs=expected)
            if direct or not complete:
                continue
            control = measures["baseline"]
            control["passes"] = (spec["phase_control_median_min"] <= control["median"] <= spec["phase_control_median_max"]
                                 and control["median_abs_from_one"] <= spec["phase_control_absolute_deviation_max"])
            control_ok = control_ok and control["passes"]
            two = stage == "decode" and case["sessions"] == 2
            for mode in eligible:
                m = measures[mode]
                if two:
                    m["passes"] = (m["median"] <= spec["two_session_decode_max_ratio"] and
                                   m["wins"] >= spec["two_session_decode_min_wins"] and
                                   max((*m["ratio_by_first_arm"].values(), *m["ratio_by_block"].values())) <
                                   spec["two_session_order_and_block_medians_max"])
                else:
                    m["passes"] = m["median"] <= spec["prefill_max_ratio" if stage=="prefill" else "single_session_decode_max_ratio"]
                eligible[mode] = eligible[mode] and m["passes"]
            m = measures["shared-over-pair"]
            m["passes"] = (m["median"] <= spec["shared_over_pair_max_ratio"] and
                           (not two or m["allocations_saved"] >= spec["shared_min_saved_allocations_per_two_session_trace"]))
            share_ok = share_ok and m["passes"]
    screened = not direct and complete
    return dict(complete=complete, first_missing=first_missing, exact_observed=True, executor_bytes=common["executor_bytes"],
                memory=dict(min_free_percent=floor, swapout_pages_added=swaps, passes=memory_ok and complete),
                controls_pass=control_ok if screened else None, variants=eligible if screened else None,
                share_increment_pass=share_ok if screened else None,
                advances_to_7b=[m for m in eligible
                                if screened and eligible[m] and control_ok and memory_ok and (m=="pair" or share_ok)],
                cases=results)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("journal", type=Path)
    mode = p.add_mutually_exclusive_group()
    mode.add_argument("--incomplete", action="store_true", help="retain complete pairs from an incomplete screen")
    mode.add_argument("--direct", action="store_true", help="measure only the separate direct follow-up")
    args = p.parse_args()
    spec = json.loads((RECORD/"pairs.json").read_text())
    common = json.loads((RECORD/spec["common"]).read_text())
    if args.direct:
        alt = json.loads((RECORD/"direct.json").read_text())
        spec.update(blocks=[], timebox_seconds=alt["timebox_seconds"], direct={k:alt[k] for k in
                    ("left","right","cases","rounds","reverse")})
    events = [json.loads(line) for line in args.journal.read_text().splitlines()]
    result = assess(spec, common, events, incomplete=args.incomplete, direct=args.direct)
    result["journal_sha256"] = sha(args.journal)
    print(json.dumps(result,indent=2,allow_nan=False))


if __name__ == "__main__":
    main()
