#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Validate the offline decode profile and rank measured wall spans."""

import argparse
import hashlib
import json
import math
from pathlib import Path
import re
from statistics import median

HERE = Path(__file__).resolve().parent


def need(condition, message):
    if not condition:
        raise ValueError(message)


def digest_ok(value):
    return isinstance(value,str) and bool(re.fullmatch(r"[0-9a-f]{64}",value))


def describe(numbers):
    return dict(median=median(numbers), low=min(numbers), high=max(numbers),
                median_abs_from_one=median(abs(x-1) for x in numbers), values=numbers)


def signature(decode,n,pos,spec,config):
    steps = spec["steps"]
    ns_per_s = 1_000_000_000
    wall = decode["decode_step_seconds"]
    need(len(wall)==steps and all(math.isfinite(x) and x>0 for x in wall),"invalid step timing")
    expected_kv = ((pos+steps+31)//32)*32*2*(config["dim"]//config["heads"])*config["kv_heads"]*config["layers"]*n*2
    need(decode["kv_payload_bytes"]==expected_kv and decode["workspace_bytes"]>0,"invalid KV or workspace capacity")
    for field in ("logits_sha256","kv_sha256"):
        need(digest_ok(decode[field]), "invalid digest")
    ids=decode["token_ids"]
    need(len(ids)==n and all(len(a)==steps+1 and all(type(i) is int and 0<=i<config["vocab"] for i in a)
                             for a in ids),"invalid token IDs")
    return tuple(decode[k] for k in ("logits_sha256","kv_sha256","workspace_bytes","kv_payload_bytes","token_ids")), [x*ns_per_s for x in wall]


def assess(spec,events,receipt=None):
    it=iter(events)

    def event(kind,**want):
        row=next(it,{})
        need(row.get("event")==kind and all(row.get(k)==v for k,v in want.items()),f"expected {kind} {want}")
        return row

    start=event("start",workers=spec["workers"],format=spec["kv"],lengths=spec["lengths"])
    plan=start["plan"]
    config=plan["config"]
    need(plan["weight_format"]==spec["weight_format"] and
         (config["dim"],config["hidden"],config["vocab"],config["layers"])==(3072,8192,128256,28),"unexpected model plan")
    layers,steps=config["layers"],spec["steps"]
    controls=spec["controls"]
    lo,hi=controls["ratio_range"]
    results={}
    all_ranks, all_controls=[], True
    for length_ix,prefix in enumerate(spec["lengths"]):
        timed=event("prefix",length=prefix)["chunked_pair_prefill_seconds"]
        need(math.isfinite(timed) and timed>0,"invalid prefix setup time")
        for _,n in (x for x in spec["case_order"] if x[0]==prefix):
            key=f"{prefix}-s{n}"
            warm=event("warm",prefix=prefix,sessions=n)
            need(digest_ok(warm["prompt_sha256"]),"missing prompt IDs")
            reference,_=signature(warm["result"]["decode"],n,prefix,spec,config)
            trail=[]
            seconds=dict(plain=[],control=[],stages=[])
            ratios={"control/plain":[],"stages/plain":[]}
            orders=spec["orders"]
            orders=orders[::-1] if (length_ix+n)%2==0 else orders
            ranks=[]
            for rnd,order in enumerate(orders):
                totals={}
                for arm in order:
                    s=event("sample",prefix=prefix,sessions=n)["result"]
                    need((s["round"],s["arm"])==(rnd,arm),"unexpected replay order")
                    sig,wall=signature(s["decode"],n,prefix,spec,config)
                    need(sig==reference,"outputs changed on replay")
                    seconds[arm].append(sum(wall)/steps/1e6)
                    totals[arm]=sum(wall)
                    if arm!="stages":
                        need("stages" not in s and "shared_kv_calls" not in s,"plain arm carried clocks")
                        continue
                    stages,shared=s["stages"],s["shared_kv_calls"]
                    need(len(stages)==steps and shared==[0]*steps,"unexpected timers or shared attention before 1024")
                    ns=dict.fromkeys(spec["stages"],0)
                    for step,(spans,total) in enumerate(zip(stages,wall,strict=True)):
                        for label,value in zip(spec["stages"],spans,strict=True):
                            need(value["calls"]==(1 if label=="vocabulary" else layers) and
                                 type(value["ns"]) is int and value["ns"]>0,"stage missing or malformed")
                            ns[label]+=value["ns"]
                        need(sum(v["ns"] for v in spans)<=total+1,f"overlap in step {step}")
                    wall_ns=sum(wall)
                    ns["other"]=max(0,wall_ns-sum(ns.values()))
                    ns["qkv"]=sum(ns[i] for i in ("query","key","value"))
                    ns["ffn_projection"]=sum(ns[i] for i in ("gate","up","down"))
                    ns["layer_projection"]=ns["qkv"]+ns["attention_output"]+ns["ffn_projection"]
                    groups=("ffn_projection","qkv","attention_output","attention","swiglu","vocabulary","other")
                    ranks.append(max(groups,key=lambda k:ns[k]))
                    trail.append(dict(ms={k:v/steps/1e6 for k,v in ns.items()},
                                      share={k:v/wall_ns for k,v in ns.items()}))
                for name in ("control","stages"):
                    ratios[name+"/plain"].append(totals[name]/totals["plain"])
            prof=event("profile",prefix=prefix,sessions=n,file=f"cpu-{key}.pprof",token_ids=reference[-1])
            controls_summary={k:describe(v) for k,v in ratios.items()}
            stable=all(lo<=v["median"]<=hi and v["median_abs_from_one"]<=controls["median_absolute_deviation_from_one_max"]
                       for v in controls_summary.values())
            all_controls &= stable
            all_ranks+=ranks
            results[key]=dict(wall_ms={k:median(v) for k,v in seconds.items()}, controls=controls_summary,
                              controls_pass=stable, prompt_sha256=warm["prompt_sha256"],
                              grouped_hotspot_by_replay=ranks,
                              stages={k:dict(ms=median(row["ms"][k] for row in trail),
                                            share=median(row["share"][k] for row in trail))
                                      for k in trail[0]["ms"]},
                              workspace_bytes=reference[2],kv_payload_bytes=reference[3],
                              cpu_profile=prof["file"])
    event("complete")
    need(next(it,None) is None,"trailing events")
    if receipt is not None:
        need(receipt["complete"] and receipt["baseline"]==spec["baseline"] and
             receipt["staged"]["monolith.go"]==spec["runtime_sha256"] and
             receipt["revision"]==spec["revision"],"receipt does not bind a complete frozen run")
        for r in results.values():
            p=receipt["profiles"][r["cpu_profile"]]
            need(p["status"]==0 and digest_ok(p["raw_sha256"]) and digest_ok(p["text_sha256"]),"invalid CPU profile")
    return dict(cases=results, complete=True, exact=True, all_controls_pass=all_controls,
                ffn_rank_first_count=all_ranks.count("ffn_projection"),timed_replays=len(all_ranks))


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("directory",type=Path)
    a=p.parse_args()
    path=a.directory/"events.jsonl"
    spec=json.loads((HERE/"protocol.json").read_text())
    r=json.loads((a.directory/"receipt.json").read_text())
    rows=[json.loads(l) for l in path.read_text().splitlines()]
    need(r["journal_sha256"]==hashlib.sha256(path.read_bytes()).hexdigest(),"journal checksum mismatch")
    print(json.dumps(assess(spec,rows,r),indent=2,allow_nan=False))


if __name__=="__main__":
    main()
