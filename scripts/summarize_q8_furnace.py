import argparse
import json
from pathlib import Path
from statistics import mean

import measure_q8_resident as measurement
import summarize_q8_resident as resident


def span(values):
    return {"count": len(values), "min": min(values), "max": max(values), "mean": mean(values)} if values else None


def summarize(root):
    base = resident.summarize(root)
    raw = json.loads((root / "result.json").read_text())
    telemetry = [json.loads(line) for line in (root / "machine.jsonl").read_text().splitlines()]
    legs, failures = [], []
    for leg in raw["legs"]:
        requests = []
        for record in leg["records"]:
            if record["warmup"]:
                continue
            usage = record["usage"]
            start, end = usage["before"]["observed_monotonic_ns"], usage["after"]["observed_monotonic_ns"]
            samples = [sample for sample in telemetry if start + 1000000000 <= sample["monotonic_ns"] <= end - 1000000000]
            frequencies = {str(cpu): span([int(sample["cpufreq_kHz"][str(cpu)]["scaling_cur_freq"]) for sample in samples
                                           if sample["cpufreq_kHz"][str(cpu)]["scaling_cur_freq"] is not None])
                           for cpu in usage["after"]["affinity"]}
            temperature = [int(sensor["millidegrees_C"]) / 1000 for sample in samples for sensor in sample["coretemp"].values()
                           if sensor["label"] == "Package id 0" and sensor["millidegrees_C"] is not None]
            derived = usage["derived"]
            requests.append({"trial": record["trial"], "wall_seconds": record["wall_ns"] / 1e9,
                             "cpu_seconds": derived["cpu_seconds"], "parallelism": derived["mean_cpu_parallelism"],
                             "faults": derived["raw_delta"], "io": derived["io_delta"], "gc": record["gc_delta"],
                             "reported_frequency_kHz": frequencies, "package_temperature_C": span(temperature),
                             "affinity": usage["after"]["affinity"]})
        ratio = max(row["wall_seconds"] for row in requests) / min(row["wall_seconds"] for row in requests)
        if ratio > 1.05:
            failures.append(f"leg{leg['index']}: within-leg wall spread exceeds5%")
        legs.append({"index": leg["index"], "label": leg["label"], "requests": requests, "wall_max_over_min": ratio})
    for key in ("same_baseline_late_over_early", "same_candidate_late_over_early"):
        if not 0.97 <= base[key]["wall_ratio"] <= 1.03:
            failures.append(f"{key}: mean ratio outside0.97..1.03")
    return {"protocol": "q8-furnace-cpu-summary-v1", "resident": base, "legs": legs,
            "telemetry_samples": len(telemetry), "screen_failures": failures,
            "passes_operational_stability_screen": not failures,
            "summary_script_sha256": measurement.sha(Path(__file__)),
            "telemetry_scope": "Frequency and temperature summaries use uniform request-interior windows excluding first/last1s, only to avoid idle-boundary samples. No request timing is excluded or corrected. OS-reported frequency is not a hardware perf counter; package temperature includes other workloads. No thermal/frequency causal claim from correlation alone.",
            "hardware_counters": "Unavailable under existing perf policy; CPU time/faults/I/O/affinity and sysfs observations only",
            "adoption": "No automatic adoption: independent Linux/amd64 evidence only, shared-host limitations and unresolved Mac gate remain."}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(summarize(args.input.resolve()), indent=2))


if __name__ == "__main__":
    main()
