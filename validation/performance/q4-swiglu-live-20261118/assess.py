#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Check resident execution order, output signatures, and timing gates."""

import argparse
import hashlib
import json
from pathlib import Path
import re
from statistics import median

from live import PROTOCOL, ROOT, ask_order, phases


def require(condition, message):
    if not condition:
        raise ValueError(message)


def check_signature(s, count, pos, steps, kv, c):
    groups = c["dim"] // c["heads"] * c["kv_heads"]
    pages = (pos + 31) // 32
    payload = (4 if kv=="f32" else 2)*pages*32*2*c["layers"]*groups*count
    require(s["Positions"] == [pos]*count and s["KVBytes"] == payload and s["Workspace"] > 0,
            "unexpected cache size, position or workspace")
    require(len(s["IDs"]) == steps+1 and all(len(row)==count and all(0 <= x < c["vocab"] for x in row)
                                            for row in s["IDs"]), "malformed token results")
    require(all(re.fullmatch(r"[0-9a-f]{64}",s[k]) for k in ("Logits","KV")), "malformed digest")


def paired(rows, steps):
    ratios = [sum(d["right"]["Ns"])/sum(d["left"]["Ns"]) for d in rows]
    first = {side:median(r for r,d in zip(ratios,rows) if d["first"]==side) for side in ("left","right")}
    return dict(median=median(ratios), low=min(ratios), high=max(ratios), wins=sum(x<1 for x in ratios),
                ratios=ratios, median_abs_from_one=median(abs(v-1) for v in ratios), median_by_first=first,
                median_ms_per_forward={a:median(sum(d[a]["Ns"])/steps/1e6 for d in rows)
                                       for a in ("left","right")},
                allocations={a:median(d[a]["Allocations"] for d in rows) for a in ("left","right")},
                allocated_bytes={a:median(d[a]["Allocated"] for d in rows) for a in ("left","right")})


def assess(spec, events, allow_incomplete=False):
    points, measurements, known = [], {}, {}
    journal = iter(events)
    stopped_at = None
    observed = 0

    class Incomplete(Exception):
        pass

    def take(kind, **expected):
        nonlocal stopped_at
        e = next(journal,None)
        if allow_incomplete and (e is None or e.get("event") == "memory_stop"):
            stopped_at = dict(expected_event=kind, expected_fields=expected, last_status=e)
            if e is not None:
                points.append(e["memory"])
                require(next(journal,None) is None,"events after memory stop")
            raise Incomplete
        require(e is not None and e.get("event") == kind and all(e.get(k)==v for k,v in expected.items()),
                f"expected {kind} {expected}")
        if "memory" in e:
            points.append(e["memory"])
        return e

    complete = False
    try:
        start = take("start",revision=spec["model_revision"],cpu=spec["host"],go=spec["go"])
        require({m:b["sources"]["monolith.go"] for m,b in start["builds"].items()}==spec["runtime_sha256"],
                "wrong source hashes")
        require(start["inputs"][str(PROTOCOL.relative_to(ROOT))] ==
                hashlib.sha256(PROTOCOL.read_bytes()).hexdigest(), "changed protocol")
        expected = take("ready",label="left",arm="baseline")["ready"]
        require(expected["executor_bytes"] == 120 and expected["ready"]["weight_format"] == spec["weights"],
                "unexpected resident plan")
        config = expected["ready"]["config"]
        require((config["layers"],config["dim"],config["hidden"],config["vocab"]) == (28,3072,8192,128256),
                "unexpected pinned shape")
        for group, right in enumerate(spec["partner_order"]):
            ready = take("ready",label=f"right-{group}",arm=right)
            require(ready["ready"] == expected, "load plan or prompts differ")
            take("group",group=group,right=right)
            for i, idx in enumerate(spec["case_order"][group]):
                case = spec["cases"][idx]
                key, count, pos, kv = (case[k] for k in ("id","sessions","prefix","kv"))
                reuse = key in known
                for arm in ask_order(group,i,0,0):
                    if arm=="left" and reuse:
                        take("reuse",group=group,case=key,arm=arm)
                        continue
                    warm = take("warm",group=group,case=key,arm=arm)["checkpoints"]
                    check_signature(warm["checkpoint"],count,pos,0,kv,config)
                    check_signature(warm["decode"],count,pos+spec["decode_steps"],spec["decode_steps"],kv,config)
                    if pos==8:
                        check_signature(warm["prefill"],count,pos,0,kv,config)
                    elif warm["prefill"] is not None:
                        raise ValueError("unexpected long prefill sample")
                    known.setdefault(key,warm)
                    require(known[key]==warm, "warm-up signatures disagree")
                for j, phase in enumerate(phases(case,group)):
                    rows = []
                    steps = spec["decode_steps"] if phase=="decode" else 1
                    row_key = (key,phase,group)
                    for rnd in range(spec["rounds_each"][group]):
                        order = ask_order(group,i,j,rnd)
                        row = dict(first=order[0])
                        for arm in order:
                            s = take("sample",group=group,case=key,phase=phase,rnd=rnd,arm=arm)["sample"]
                            require(s["Signature"]==known[key][phase],"logit or KV parity failed")
                            require(len(s["Ns"])==steps and all(type(ns) is int and ns > 0 for ns in s["Ns"]) and
                                    all(type(s[k]) is int and s[k]>=0 for k in ("Allocated","Allocations")),
                                    "invalid measurement sample")
                            row[arm] = s
                            observed += 1
                        rows.append(row)
                    take("end_phase",group=group,case=key,phase=phase)
                    measurements[row_key] = paired(rows,steps)
            take("end_group",group=group)
        take("complete")
        require(next(journal,None) is None,"extra events")
        complete = True
    except Incomplete:
        pass

    limits = spec["limits"]
    lo,hi = limits["controls_median_range"]
    floor = min((p["free_percent"] for p in points),default=0)
    swaps = points[-1]["swapouts"]-points[0]["swapouts"] if points else None
    memory_pass = bool(points and points[0]["free_percent"] >= spec["memory"]["entry_free_percent"] and
                       floor>=spec["memory"]["min_free_percent"] and swaps<=spec["memory"]["max_new_swapout_pages"])
    report, all_controls, all_candidates = {}, True, True
    for case in spec["cases"]:
        key = case["id"]
        report[key] = {}
        for phase in case["phases"]:
            active = {str(group):measurements[key,phase,group] for group in range(3)
                      if (key,phase,group) in measurements}
            control_checks = [lo<=m["median"]<=hi and m["median_abs_from_one"]<=limits["controls_median_abs_from_one"]
                              for g,m in active.items() if g!="1"]
            controls = len(control_checks)==2 and all(control_checks)
            m = active.get("1")
            candidate_ok = False
            if m:
                if phase=="prefill":
                    candidate_ok = m["median"]<=limits["prefill_median_ratio_max"]
                elif case["sessions"]==1:
                    candidate_ok = m["median"]<=limits["single_decode_median_ratio_max"]
                else:
                    candidate_ok = (m["median"]<=limits["decode_median_ratio_max"] and
                                    m["wins"]>=limits["decode_min_wins"] and max(m["median_by_first"].values())<1)
            report[key][phase] = dict(groups=active,control_pass=controls,candidate_pass=candidate_ok)
            all_controls &= controls
            all_candidates &= candidate_ok
    return dict(complete=complete, measured_arms=observed, exact_observed=True, stopped_at=stopped_at,
                memory=dict(min_free_percent=floor,new_swapout_pages=swaps,passes=memory_pass),
                stable_controls=all_controls, candidate_gate=all_candidates,
                positive_model_signal=complete and all_controls and all_candidates and memory_pass, cases=report)


def main():
    cli=argparse.ArgumentParser(description=__doc__)
    cli.add_argument("journal",type=Path)
    cli.add_argument("--incomplete",action="store_true")
    args=cli.parse_args()
    spec=json.loads(PROTOCOL.read_text())
    events=[json.loads(line) for line in args.journal.read_text().splitlines()]
    result=assess(spec,events,args.incomplete)
    result["journal_sha256"]=hashlib.sha256(args.journal.read_bytes()).hexdigest()
    print(json.dumps(result,indent=2,allow_nan=False))


if __name__=="__main__":
    main()
