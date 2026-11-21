#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Check the frozen Q4 SIMD comparisons against their measured journals."""

import argparse
import json
import re
from pathlib import Path
from statistics import median

from assess import HERE, assess, describe, digest_ok, need, signature
from run import sha


def read_json(path):
    return json.loads(path.read_text())


def journal(path):
    return [json.loads(line) for line in path.read_text().splitlines()]


def stable(summary, criteria):
    lo, hi = criteria["median_range"]
    return (lo <= summary["median"] <= hi and
            summary["median_abs_from_one"] <= criteria["median_abs_from_one_max"])


def synthetic(directory, spec):
    results = {}
    for block, workers_list in enumerate(spec["workers"]):
        rows = iter(journal(directory / f"simd-{block}.jsonl"))
        for workers in workers_list:
            shapes = spec["shapes"]
            if (workers == 1) != (block == 1):
                shapes = shapes[::-1]
            for shape in shapes:
                orders = spec["orders"]
                if (workers == 1) != ((spec["shapes"].index(shape) + block) % 2 == 1):
                    orders = orders[::-1]
                name = "x".join(map(str, shape))
                samples = {arm: [] for arm in orders[0]}
                for rnd, order in enumerate(orders):
                    for arm in order:
                        row = next(rows, {})
                        expected = dict(Block=block, Workers=workers, Shape=name,
                                        Calls=spec["calls_per_sample"], Round=rnd, Arm=arm)
                        need(all(row.get(k) == v for k, v in expected.items()), f"unexpected sample for {expected}")
                        elapsed = row["ElapsedNS"]
                        need(type(elapsed) is int and elapsed > 0, "invalid kernel timing")
                        samples[arm].append(elapsed)
                ratios = {arm: describe([a / b for a, b in zip(samples[arm], samples["plain"], strict=True)])
                          for arm in ("control", "simd")}
                wins = sum(r < 1 for r in ratios["simd"]["values"])
                accepted = (stable(ratios["control"], spec["controls"]) and
                            wins >= spec["candidate"]["min_wins_out_of_6"] and
                            ratios["simd"]["median"] <= spec["candidate"]["max_median_ratio"])
                results[f"block{block}-w{workers}-{name}"] = dict(
                    median_ms={a: median(v) / spec["calls_per_sample"] / 1e6 for a, v in samples.items()},
                    ratios=ratios, wins=wins, rounds=len(orders), timing_pass=accepted)
        need(next(rows, None) is None, f"trailing kernel samples for block {block}")

    log = (directory / "exact.log").read_text()
    for test in ("TestSIMDQ4BlockExact", "TestSIMDQ4RangeExact"):
        need(f"--- PASS: {test} " in log, f"missing exact gate for {test}")
    instructions = {}
    for func in (".simdQ4Block", ".dotQ4TwoRowOutputPair64"):
        src = (directory / "blocks.s").read_text()
        body = re.search(rf"^TEXT \S+{re.escape(func)}\(SB\).*?\n(.*?^.*?\bRET\b)",
                         src, re.M | re.S)
        need(body is not None, f"missing disassembly for {func}")
        instructions[func[1:]] = {op: len(re.findall(rf"\b{op}\b", body[1]))
                                  for op in ("FMADDS", "VFMLA", "VFADDP")}
    return dict(cases=results, instructions=instructions, exact=True,
                advance=all(case["timing_pass"] for case in results.values()))


def live(directory, profile_directory, parent, spec):
    receipt = read_json(directory / "receipt.json")
    profile_receipt = read_json(profile_directory / "receipt.json")
    for path, metadata in ((directory, receipt), (profile_directory, profile_receipt)):
        need(metadata["journal_sha256"] == sha(path / "events.jsonl"), "journal checksum mismatch")
    rows = iter(journal(directory / "events.jsonl"))
    profile_rows = journal(profile_directory / "events.jsonl")
    profile_result = assess(parent, profile_rows, profile_receipt)
    need(profile_result["all_controls_pass"], "ordinary profile controls failed")
    need(receipt["complete"] and receipt["exit_error"] is None and receipt["journal_error"] is None,
         "resident experiment incomplete")
    for field in ("assets", "revision", "cpu", "go"):
        need(receipt[field] == profile_receipt[field], f"mismatched {field} across experiments")
    for field in ("monolith.go", "go.mod", "go.sum", "inference_perf_test.go"):
        need(receipt["sources"][field] == profile_receipt["staged"][field], f"mismatched staged {field}")
    for field in ("cmd/monolith/context_sweep_perf_test.go", "validation/quality/corpus.json"):
        need(receipt["inputs"][field] == profile_receipt["inputs"][field], f"mismatched {field}")
    need(receipt["goexperiment"] == spec["goexperiment"], "unexpected Go experiment")

    def event(kind, **want):
        row = next(rows, {})
        need(row.get("event") == kind and all(row.get(k) == v for k, v in want.items()),
             f"expected {kind} {want}")
        return row

    plan = profile_rows[0]["plan"]
    event("start", plan=plan, workers=parent["workers"], format=parent["kv"], lengths=parent["lengths"])
    config, steps = plan["config"], parent["steps"]
    profile_warm = {(r["prefix"], r["sessions"]): r for r in profile_rows if r["event"] == "warm"}
    before, after = receipt["memory"]
    swapout_delta = after["swapouts"] - before["swapouts"]
    healthy = (min(m["free_percent"] for m in receipt["memory"]) >= spec["gate"]["min_memory_free_percent"]
               and 0 <= swapout_delta <= spec["gate"]["max_new_swapout_pages"])
    cases = {}
    for length_ix, prefix in enumerate(parent["lengths"]):
        event("prefix", length=prefix)
        for _, n in (case for case in parent["case_order"] if case[0] == prefix):
            p = profile_warm[prefix, n]
            warm = event("warm", prefix=prefix, sessions=n, prompt_sha256=p["prompt_sha256"])["result"]
            baseline, _ = signature(p["result"]["decode"], n, prefix, parent, config)
            current, _ = signature(warm["decode"], n, prefix, parent, config)
            need((warm["round"], warm["arm"], warm["decode"]["simd_calls"]) == (-1, "plain", 0)
                 and current == baseline, "warm decode differs from ordinary toolchain")
            need(digest_ok(p["prompt_sha256"]), "missing prompt IDs")

            orders = spec["order"][::-1] if (length_ix + n) % 2 == 0 else spec["order"]
            samples = {arm: [] for arm in orders[0]}
            order_ratios = {"simd_first": [], "plain_first": []}
            for rnd, order in enumerate(orders):
                for arm in order:
                    s = event("sample", prefix=prefix, sessions=n)["result"]
                    need((s["round"], s["arm"]) == (rnd, arm), "unexpected replay order")
                    expected_calls = 3 * config["layers"] * steps if n == 2 and arm.startswith("simd") else 0
                    need(s["decode"]["simd_calls"] == expected_calls, "unexpected dispatch count")
                    result, wall = signature(s["decode"], n, prefix, parent, config)
                    need(result == baseline, "outputs changed on SIMD replay")
                    samples[arm].append(sum(wall) / steps / 1e6)
                key = "simd_first" if order.index("simd") < order.index("plain") else "plain_first"
                order_ratios[key].append(samples["simd"][-1] / samples["plain"][-1])

            c = spec["controls"]
            ratios = {
                f"{a}/{b}": describe([x / y for x, y in zip(samples[a], samples[b], strict=True)])
                for a, b in (("control", "plain"), ("simd_control", "simd"), ("simd", "plain"))
            }
            need(all(len(v) * 2 == len(orders) for v in order_ratios.values()), "unbalanced SIMD-first comparison")
            order_medians = {k: median(v) for k, v in order_ratios.items()}
            candidate = ratios["simd/plain"]
            wins = sum(x < 1 for x in candidate["values"])
            controls_pass = stable(ratios["control/plain"], c) and stable(ratios["simd_control/simd"], c)
            if n == 1:
                timing_pass = stable(candidate, c)
            else:
                g = spec["gate"]
                timing_pass = (candidate["median"] <= g["two_session_max_median_ratio"] and
                               wins >= g["min_wins_out_of_8"] and all(v < 1 for v in order_medians.values()))
            cases[f"{prefix}-s{n}"] = dict(median_ms={k: median(v) for k, v in samples.items()},
                                          ratios=ratios, wins=wins, rounds=len(orders),
                                          order_medians=order_medians, controls_pass=controls_pass,
                                          timing_pass=timing_pass)
    event("complete")
    need(next(rows, None) is None, "trailing resident events")
    return dict(cases=cases, exact=True, complete=True, healthy=healthy, swapout_delta=swapout_delta,
                advance=healthy and all(c["controls_pass"] and c["timing_pass"] for c in cases.values()))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="kind", required=True)
    sub.add_parser("synthetic").add_argument("directory", type=Path)
    resident = sub.add_parser("live")
    resident.add_argument("directory", type=Path)
    resident.add_argument("profile_directory", type=Path)
    args = parser.parse_args()
    if args.kind == "synthetic":
        result = synthetic(args.directory, read_json(HERE / "simd-protocol.json"))
    else:
        spec = read_json(HERE / "live-protocol.json")
        result = live(args.directory, args.profile_directory, read_json(HERE / spec["parent"]), spec)
    print(json.dumps(result, indent=2, allow_nan=False))


if __name__ == "__main__":
    main()
