#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Verify the raw samples and evaluate the two-wave attention comparison."""
import argparse
from collections import Counter, defaultdict
import hashlib
import json
from pathlib import Path
import re
from statistics import median
import sys

import probe

sys.path.insert(0, str(probe.SINGLE))
from assess import validate_signature

TOOLING = "2f5d856d741f8e5608aaab68f5624522901e7fbb"
BENCH = re.compile(r"BenchmarkAttentionQ4/(QO|KV)/rows([12])/workers([14])-4\s+(\d+)\s+([\d.]+) ns/op\s+(\d+) B/op\s+(\d+) allocs/op")


def projections(take, spec):
    times = defaultdict(lambda: {"A": [], "B": []})
    max_allocs = defaultdict(int)
    micro = spec["projection_probe"]
    for index, order in enumerate(micro["orders"]):
        for arm in order:
            output = take("projection", round=index, arm=arm)["output"]
            seen = set()
            for line in output.splitlines():
                if not line.startswith("Benchmark"):
                    continue
                m = BENCH.fullmatch(line.strip())
                if not m or int(m[4]) != micro["iterations"] or float(m[5]) <= 0:
                    raise ValueError("invalid projection benchmark row")
                key = f"{m[1]}/rows{m[2]}/workers{m[3]}"
                if key in seen:
                    raise ValueError("duplicate projection shape")
                seen.add(key)
                times[key][arm].append(float(m[5]))
                max_allocs[key] = max(max_allocs[key], int(m[7]))
            if len(seen) != 8 or not output.rstrip().endswith("PASS"):
                raise ValueError("incomplete projection benchmarks")
    return {k: dict(ms={arm: median(t) / 1e6 for arm, t in v.items()},
                    paired_ratio=median(b/a for a, b in zip(v["A"], v["B"])),
                    wins=sum(b < a for a, b in zip(v["A"], v["B"])), max_allocs_per_op=max_allocs[k])
            for k, v in sorted(times.items())}


def case_summary(rounds, limits, steps):
    ratios, wave_ratios = [], defaultdict(list)
    controls, elapsed = {"A": [], "B": []}, {"A": [], "B": []}
    for wave, ns in rounds:
        ratio = (ns["B"] + ns["b"]) / (ns["A"] + ns["a"])
        wave_ratios[wave].append(ratio)
        ratios.append(ratio)
        for arm in "AB":
            repeat = ns[arm.lower()]
            controls[arm].append(repeat / ns[arm])
            elapsed[arm].append((repeat + ns[arm]) / (2 * steps * 1e6))
    waves = [median(v) for v in wave_ratios.values()]
    wins = sum(r < 1 for r in ratios)
    noise = {k: dict(median=median(v), median_abs_from_one=median(abs(x-1) for x in v)) for k, v in controls.items()}
    low, high = limits["repeat_median_range"]
    return dict(exact_replays=len(rounds)*4, ms_per_forward={k: median(v) for k,v in elapsed.items()},
                pooled_median=median(ratios), wave_medians=waves, wins=wins, repeats=noise,
                repeat_pass=all(low <= c["median"] <= high and c["median_abs_from_one"] <= limits["max_repeat_median_abs_error"] for c in noise.values()),
                speed_pass=median(ratios) <= limits["max_pooled_ratio"] and wins >= limits["min_round_wins"] and max(waves) < limits["max_wave_ratio"])


def summarize(path):
    spec = json.loads(probe.pinned(TOOLING, probe.SPEC.relative_to(probe.ROOT)))
    blob = path.read_bytes()
    stream = iter(map(json.loads, blob.splitlines()))
    memory = []

    def take(kind, **fields):
        row = next(stream, {})
        if row.get("event") != kind or any(row.get(k) != v for k, v in fields.items()):
            raise ValueError(f"expected {kind} {fields}")
        if kind in ("start", "ready", "warm", "round_end", "complete"):
            m = row["memory"]
            if (type(m["free_percent"]) != int or not 0 <= m["free_percent"] <= 100
                    or type(m["swapouts"]) != int or m["swapouts"] < 0
                    or memory and m["swapouts"] < memory[-1]["swapouts"]):
                raise ValueError("invalid memory counters")
            memory.append(m)
        return row

    start = take("start", cpu=spec["cpu"], go=spec["go"], modes=spec["modes"], binary=spec["binary_sha256"])
    expected_inputs = {k: hashlib.sha256(probe.pinned(TOOLING, k)).hexdigest() for k in probe.inputs()}
    if start["inputs"] != expected_inputs or start["sources"] != probe.digests(probe.sources(spec)):
        raise ValueError("source or fixture identity differs")
    catalog = json.loads(probe.pinned(TOOLING, probe.CATALOG.relative_to(probe.ROOT)))
    model = next(m for m in catalog["models"] if m["id"] == spec["model"])
    if start["assets"] != model["files"] or model["revision"] != spec["revision"]:
        raise ValueError("model identity differs")
    micro = projections(take, spec)
    prior = list(map(json.loads, probe.pinned(spec["previous"], (probe.SINGLE/"events.jsonl").relative_to(probe.ROOT)).splitlines()))
    reference_ready = next(r["ready"] for r in prior if r["event"] == "ready")
    reference = {r["case"]["sessions"]:r["go"] for r in prior if r["event"] == "warm"}
    cfg = reference_ready["ready"]["config"]
    cases = defaultdict(list)
    steps = spec["steps"]
    for wave, settings in enumerate(spec["waves"]):
        for arm in settings["load"]:
            ready = take("ready", wave=wave, arm=arm)["ready"]
            attn = 4*cfg["layers"] if arm == "B" else 0
            ffn = 3*cfg["layers"]
            if ready != {**reference_ready, "routing": {"attention":attn, "ffn":ffn, "total":attn+ffn}}:
                raise ValueError("unexpected routing, model plan, or prompts")
        orders = settings["orders"]
        if any(Counter(pos) != Counter("AaBb") for pos in zip(*orders)) or any(set(o) != set("AaBb") or len(o) != 4 for o in orders):
            raise ValueError("each label must occupy each position once per wave")
        for sessions in settings["sessions"]:
            fields = dict(wave=wave, sessions=sessions)
            for arm in settings["load"]:
                warm = take("warm", arm=arm, **fields)["result"]
                validate_signature(warm["checkpoint"], sessions, spec["prefix"], 1, cfg["vocab"])
                validate_signature(warm["decode"], sessions, spec["prefix"]+steps, steps+1, cfg["vocab"])
                if warm != reference[sessions]:
                    raise ValueError("warm run differs from the previous release")
            for index, order in enumerate(orders):
                ns = {}
                for label in (order if sessions == 1 else order[::-1]):
                    sample = take("sample", round=index, label=label, **fields)["sample"]
                    sig = sample["Signature"]
                    validate_signature(sig, sessions, spec["prefix"]+steps, steps+1, cfg["vocab"])
                    if sig != reference[sessions]["decode"] or len(sample["Ns"]) != steps or any(type(n) != int or n <= 0 for n in sample["Ns"]):
                        raise ValueError("invalid measured decode")
                    ns[label] = sum(sample["Ns"])
                take("round_end", round=index, **fields)
                cases[sessions].append((wave, ns))
        for arm in settings["load"]:
            if take("stopped", wave=wave, arm=arm)["rss_kib"] <= 0:
                raise ValueError("missing resident size")
    take("complete")
    if next(stream, None) is not None:
        raise ValueError("unexpected trailing event")
    limits = spec["limits"]
    cases = {str(sessions): case_summary(case, limits, steps) for sessions, case in sorted(cases.items())}
    swaps = memory[-1]["swapouts"] - memory[0]["swapouts"]
    free = min(m["free_percent"] for m in memory)
    memory_ok = swaps <= limits["max_new_swapouts"] and free >= limits["min_free_percent"]
    return dict(events_sha256=hashlib.sha256(blob).hexdigest(), projections=micro, sessions=cases,
                min_free_percent=free, new_swapouts=swaps, memory_pass=memory_ok,
                accepted=memory_ok and all(c["repeat_pass"] and c["speed_pass"] for c in cases.values()))


if __name__ == "__main__":
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("events", nargs="?", type=Path, default=probe.HERE / "events.jsonl")
    print(json.dumps(summarize(cli.parse_args().events), indent=2, allow_nan=False))
