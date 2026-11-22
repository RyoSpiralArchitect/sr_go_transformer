#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Replay the frozen parity, order and timing checks from the raw JSONL log."""
import argparse
import hashlib
import json
from pathlib import Path
from statistics import median
import subprocess

PROTOCOL = Path(__file__).with_name("protocol.json")


ROOT = PROTOCOL.parents[3]
CANDIDATE = "5ff300789b6b33d54ac6e3c16366d1c72680f06b"
TOOLING = "e4b8747e3873931a8f88378c34b62f99378d0982"
FIXTURE = "validation/performance/q8-compact-head-20261118/resident_test.go.txt"
HARNESS = "cmd/monolith/inference_perf_test.go"
CATALOG = "validation/hf/model-profiles.json"


def blob(ref, path):
    return subprocess.check_output(["git", "show", f"{ref}:{path}"], cwd=ROOT)


def digest(ref, path):
    return hashlib.sha256(blob(ref, path)).hexdigest()


def verify_start(start, spec):
    catalog = json.loads(blob(CANDIDATE, CATALOG))
    model = next(m for m in catalog["models"] if m["id"] == spec["model_id"])
    if (start["repo"], start["revision"], start["assets"]) != (model["repo"], model["revision"], model["files"]):
        raise ValueError("model assets differ from the pinned catalog")
    fixtures = {HARNESS: digest(CANDIDATE, HARNESS), "cmd/monolith/resident_test.go": digest(CANDIDATE, FIXTURE)}
    for arm, ref in [("A", spec["baseline"]), ("B", CANDIDATE)]:
        files = subprocess.check_output(["git", "ls-tree", "--name-only", ref + ":cmd/monolith"],
                                        cwd=ROOT, text=True).splitlines()
        names = ["cmd/monolith/" + n for n in files if n.endswith((".go", ".s")) and not n.endswith("_test.go")]
        sources = {p: digest(ref, p) for p in [*names, "go.mod", "go.sum"]} | fixtures
        build = start["builds"][arm]
        if build["sources"] != sources or build["native"] != (arm == "B"):
            raise ValueError(f"unexpected source, fixture or backend in build {arm}")
    driver = str(PROTOCOL.relative_to(ROOT).parent)
    shared = [FIXTURE, str(Path(FIXTURE).with_name("run.py")), str(Path(FIXTURE).with_name("variants.py")),
              "validation/quality/corpus.json", CATALOG, driver+"/protocol.json", driver+"/run.py"]
    inputs = {p:digest(CANDIDATE, p) for p in shared}
    helpers = ["scripts/compare_inference.py", "scripts/quant_quality.py"]
    if not any(start["inputs"] == inputs | {p:digest(ref, p) for p in helpers} for ref in (CANDIDATE, TOOLING)):
        raise ValueError("unexpected driver, corpus or helper inputs")


def assess(path):
    spec = json.loads(PROTOCOL.read_text())
    limits = spec["limits"]
    data = path.read_bytes()
    events = iter(map(json.loads, data.splitlines()))

    memory = []

    def take(kind, **expected):
        event = next(events, {})
        if event.get("event") != kind or any(event.get(k) != v for k, v in expected.items()):
            raise ValueError(f"missing or unexpected {kind} event for {expected}")
        if "memory" in event:
            memory.append(event["memory"])
        return event

    start = take("start", baseline=spec["baseline"], revision=spec["revision"], cpu=spec["cpu"], go=spec["go"])
    verify_start(start, spec)
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
    take("complete")
    if next(events, None) is not None:
        raise ValueError("unexpected trailing events")
    low_free = min(m["free_percent"] for m in memory)
    new_swapouts = max(m["swapouts"] for m in memory) - start["memory"]["swapouts"]
    memory_ok = low_free >= limits["min_free_percent"] and new_swapouts <= limits["max_new_swapout_pages"]
    return dict(events_sha256=hashlib.sha256(data).hexdigest(), cases=rows,
                min_recorded_free_percent=low_free, new_swapout_pages=new_swapouts, memory_pass=memory_ok,
                accepted=memory_ok and all(r["controls_pass"] and r["speed_pass"] for r in rows))


if __name__ == "__main__":
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("events", type=Path)
    result = assess(cli.parse_args().events)
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result["accepted"] else 1)
