import argparse
import json
from pathlib import Path
from statistics import mean

import measure_q8_resident as measurement
import summarize_q8_resident as resident


def evaluate(root):
    summary = resident.summarize(root)
    data = json.loads((root / "result.json").read_text())
    rows, failures = [], []
    for leg in data["legs"]:
        samples = []
        for record in leg["records"]:
            if record["warmup"]:
                continue
            derived = record["usage"]["derived"]
            samples.append({"wall_seconds": record["wall_ns"] / 1e9,
                            "cpu_seconds": derived["cpu_seconds"],
                            "parallelism": derived["mean_cpu_parallelism"],
                            "performance_cpu_fraction": derived["performance_cpu_fraction"],
                            "instructions": derived["raw_delta"]["ri_instructions"],
                            "cycles": derived["raw_delta"]["ri_cycles"],
                            "cycles_per_cpu_ns": derived["cycles_per_cpu_ns"],
                            "pageins": derived["raw_delta"]["ri_pageins"],
                            "disk_read_bytes": derived["raw_delta"]["ri_diskio_bytesread"],
                            "gc": record["gc_delta"]})
        spread = max(row["wall_seconds"] for row in samples) / min(row["wall_seconds"] for row in samples)
        if spread > 1.05:
            failures.append(f"leg{leg['index']}: request wall spread exceeds5%")
        rows.append({"index": leg["index"], "label": leg["label"], "samples": samples,
                     "wall_max_over_min": spread, "mean_wall_seconds": mean(row["wall_seconds"] for row in samples)})
    for label in ("before", "after"):
        selected = [row for leg in rows if leg["label"] == label for row in leg["samples"]]
        instructions = [row["instructions"] for row in selected]
        fractions = [row["performance_cpu_fraction"] for row in selected]
        if max(instructions) / min(instructions) > 1.01:
            failures.append(f"{label}: instructions drift exceeds1%")
        if max(fractions) - min(fractions) > 0.05:
            failures.append(f"{label}: performance CPU fraction spread exceeds5 percentage points")
    for label, key in (("before", "same_baseline_late_over_early"), ("after", "same_candidate_late_over_early")):
        if not 0.97 <= summary[key]["wall_ratio"] <= 1.03:
            failures.append(f"{label}: late/early mean wall exceeds3% screen")
    gc_values = [row["gc"]["monolith_gc_cycles_total"] for leg in rows for row in leg["samples"]]
    if len(set(gc_values)) > 1:
        failures.append("GC activity differs across measured requests")
    if any(row["pageins"] or row["disk_read_bytes"] for leg in rows for row in leg["samples"]):
        failures.append("page-in or disk-read activity needs attribution")
    return {"protocol": "q8-observed-resident-evaluation-v1", "resident_summary": summary,
            "legs": rows, "screen_failures": failures, "eligible_for_confirmation": not failures,
            "gate_file": "validation/performance/q8-observed-gates-20261109.json",
            "evaluator_sha256": measurement.sha(Path(__file__)),
            "interpretation": "All data retained; failed screens block an adoption timing claim. Counters are diagnostic, not a latency correction or direct core-frequency measurement."}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(evaluate(args.input.resolve()), indent=2))


if __name__ == "__main__":
    main()
