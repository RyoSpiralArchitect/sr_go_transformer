#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Replay the ordered Furnace record against its frozen build and Linux signatures."""
import argparse
from collections import defaultdict
import json
from pathlib import Path
from statistics import median

from measure import HERE, SPEC, probe, references

BUILD_SHA256 = "ec5302211582d6d83a6d1f5e7a89ccb39932e94dce129a457fc4e65d6150f613"


def case_result(rounds, sessions, steps, limits):
    # F and f are repeat measurements from the same FFN-only process.
    elapsed = defaultdict(list)
    ratios = defaultdict(lambda: defaultdict(list))
    repeats = []
    for wave, times in rounds:
        middle = (times["F"] + times["f"]) / 2
        for arm, ns in (("A", times["A"]), ("F", middle), ("B", times["B"])):
            elapsed[arm].append(ns)
        ratios["ffn"][wave].append(middle/times["A"])
        ratios["attention"][wave].append(times["B"]/middle)
        ratios["combined"][wave].append(times["B"]/times["A"])
        repeats.append(times["f"]/times["F"])
    effects = {}
    for name, waves in ratios.items():
        all_ratios = [r for group in waves.values() for r in group]
        ratio = median(all_ratios)
        per_wave = [median(group) for group in waves.values()]
        wins = sum(r < 1 for r in all_ratios)
        if name == "ffn" and sessions == 2:
            lo, hi = limits["two_row_ffn_control_range"]
            passed = lo <= ratio <= hi
        else:
            passed = ratio <= limits["time_ratio"] and wins >= limits["min_wins"] and max(per_wave) < limits["max_wave_ratio"]
        effects[name] = dict(median_ratio=ratio, wave_medians=per_wave, wins=wins, passed=passed)
    lo, hi = limits["repeat_range"]
    deviation = median(abs(r-1) for r in repeats)
    repeat = dict(median_ratio=median(repeats), median_abs_from_one=deviation,
                  passed=lo <= median(repeats) <= hi and deviation <= limits["max_repeat_median_abs_error"])
    return dict(exact_replays=4*len(rounds), controls=repeat, effects=effects,
                aggregate_tok_s={arm:median(steps*sessions*1e9/ns for ns in group) for arm,group in elapsed.items()},
                passed=repeat["passed"] and all(effect["passed"] for effect in effects.values()))


def assess(path, model_id, manifest=HERE/"build.json"):
    if probe.sha(manifest) != BUILD_SHA256:
        raise ValueError("unexpected build manifest")
    build = json.loads(manifest.read_text())
    if probe.sha(SPEC) != build["inputs"][str(SPEC.relative_to(probe.ROOT))]:
        raise ValueError("protocol differs")
    spec = json.loads(SPEC.read_text())
    archive = spec["models"][model_id]
    if probe.sha(probe.ROOT/archive) != build["inputs"][archive]:
        raise ValueError("reference archive differs")
    ready_ref, warm = references(probe.ROOT/archive)
    # The previous Linux run recorded the full snapshot identity. Its archive
    # is pinned above, so replay also works after new entries join the catalog.
    with (probe.ROOT/archive).open() as previous:
        snapshot = json.loads(previous.readline())
    if snapshot["event"] != "start":
        raise ValueError("missing reference snapshot")
    rows = iter(json.loads(line) for line in path.read_text().splitlines())
    memory, peaks, profiles = [], [], {}
    def take(event, **fields):
        row = next(rows, {})
        if row.get("event") != event or any(row.get(k) != v for k,v in fields.items()):
            raise ValueError(f"expected {event} {fields}")
        if event in ("start", "ready", "round_end", "complete"):
            m = row["memory"]
            if (type(m["available_kib"]) != int or m["available_kib"] <= 0 or type(m["swapouts"]) != int
                    or m["swapouts"] < 0 or memory and m["swapouts"] < memory[-1]["swapouts"]):
                raise ValueError("invalid memory counters")
            memory.append(m)
        return row

    take("start", model=model_id, repo=snapshot["model"], revision=snapshot["revision"], assets=snapshot["assets"],
         build_sha256=BUILD_SHA256, binary=build["binary"], cpu=spec["cpu"], affinity=spec["cores"], modes=spec["modes"])
    layers = ready_ref["ready"]["config"]["layers"]
    timings = defaultdict(list)
    for wave, settings in enumerate(spec["waves"]):
        for arm in settings["load"]:
            att = 4*layers if arm == "B" else 0
            expected = dict(ready_ref, routing=dict(attention=att, ffn=3*layers, total=att+3*layers),
                            pair=True, quad=arm!="A")
            if take("ready", wave=wave, arm=arm)["result"] != expected:
                raise ValueError("incorrect matrix routing or model plan")
        for sessions in settings["sessions"]:
            fields = dict(wave=wave, sessions=sessions)
            for arm in settings["load"]:
                if take("warm", arm=arm, **fields)["result"] != warm[sessions]:
                    raise ValueError("warm signature differs")
            for rnd, order in enumerate(settings["orders"]):
                ns = {}
                for label in (order if sessions == 1 else order[::-1]):
                    result = take("sample", round=rnd, label=label, **fields)["result"]
                    if result["Signature"] != warm[sessions]["decode"]:
                        raise ValueError("decode signature differs")
                    values = result["Ns"]
                    if len(values) != spec["steps"] or any(type(t) != int or t <= 0 for t in values):
                        raise ValueError("invalid timings")
                    ns[label] = sum(values)
                take("round_end", round=rnd, **fields)
                timings[sessions].append((wave, ns))
        peak = take("peaks", wave=wave)["rss_kib"]
        if set(peak) != set(spec["modes"]) or any(type(n) != int or n <= 0 for n in peak.values()):
            raise ValueError("missing resident memory")
        peaks.append(peak)
        if wave == len(spec["waves"])-1:
            for sessions in settings["sessions"]:
                for arm in ("A","B"):
                    digest = take("profile", sessions=sessions, arm=arm)["sha256"]
                    if len(digest) != 64 or any(c not in "0123456789abcdef" for c in digest):
                        raise ValueError("invalid CPU profile digest")
                    profiles[f"{arm}-{sessions}"] = digest
    take("complete")
    if next(rows, None) is not None:
        raise ValueError("trailing events")
    limits = spec["limits"]
    cases = {str(n):case_result(rounds, n, spec["steps"], limits) for n,rounds in sorted(timings.items())}
    available = min(m["available_kib"] for m in memory)
    swapouts = memory[-1]["swapouts"] - memory[0]["swapouts"]
    return dict(events_sha256=probe.sha(path), sessions=cases, peak_rss_kib=peaks, profile_sha256=profiles,
                min_available_kib=available, new_swapouts=swapouts, passed=available>=limits["min_available_kib"]
                and swapouts<=limits["max_new_swapouts"] and all(v["passed"] for v in cases.values()))


if __name__ == "__main__":
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("model_id")
    cli.add_argument("events", type=Path)
    args = cli.parse_args()
    print(json.dumps(assess(args.events, args.model_id), indent=2, allow_nan=False))
