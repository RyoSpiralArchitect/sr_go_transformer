#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Summarize balanced Gate/Up and Down fixture timing."""

import argparse
from itertools import permutations
import json
from pathlib import Path
from statistics import median


def assess(spec, rows):
    samples = iter(rows)
    by_worker = {}
    checks = spec["preflight"]
    for i, workers in enumerate(spec["workers"]):
        pairs = []
        orders = list(permutations(("baseline","control","tile")))
        if i == 1:
            orders.reverse()
        if len(orders) != spec["rounds"]:
            raise ValueError("inconsistent protocol")
        for index, order in enumerate(orders):
            r = {}
            for arm in order:
                s = next(samples, {})
                if ((s.get("Workers"), s.get("Round"), s.get("Calls"), s.get("Arm")) !=
                        (workers, index, spec["calls_per_sample"], arm) or
                        any(type(s[k]) is not int or s[k] <= 0 for k in ("GateUpNS","DownNS"))):
                    raise ValueError("unexpected or incomplete fixture sample")
                r[arm] = s
            pairs.append(r)

        summary = {}
        for stage in ("gate_up", "down", "ffn"):
            def span(x):
                a,b = x["GateUpNS"],x["DownNS"]
                return {"gate_up":a,"down":b,"ffn":a+b}[stage]
            control = [span(pair["control"])/span(pair["baseline"]) for pair in pairs]
            candidate = [span(pair["tile"])/span(pair["baseline"]) for pair in pairs]
            summary[stage] = dict(
                baseline_ms=median(span(p["baseline"])/p["baseline"]["Calls"]/1e6 for p in pairs),
                control_median=median(control), control_abs_from_one=median(abs(v-1) for v in control),
                candidate_median=median(candidate), candidate_wins=sum(v<1 for v in candidate),
                control=control, candidate=candidate)
        low, high = checks["same_path_median"]
        stable = all(low <= x["control_median"] <= high and
                     x["control_abs_from_one"] <= checks["same_path_median_absolute_deviation"]
                     for x in summary.values())
        summary["advances"] = (stable and summary["gate_up"]["candidate_median"] <= checks["gate_up_median_ratio_max"]
                               and summary["down"]["candidate_median"] <= checks["down_median_ratio_max"]
                               and summary["ffn"]["candidate_median"] <= checks["combined_median_ratio_max"]
                               and summary["ffn"]["candidate_wins"] >= checks["combined_min_wins"])
        by_worker[workers] = summary
    if next(samples,None) is not None:
        raise ValueError("extra samples")
    return dict(advances_to_model=all(v["advances"] for v in by_worker.values()), workers=by_worker)


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("samples", type=Path)
    args = cli.parse_args()
    spec = json.loads(Path(__file__).with_name("protocol.json").read_text())
    rows = [json.loads(line) for line in args.samples.read_text().splitlines()]
    print(json.dumps(assess(spec,rows),indent=2))


if __name__ == "__main__":
    main()
