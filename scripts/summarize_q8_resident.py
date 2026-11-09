import argparse
import json
from pathlib import Path
from statistics import mean

import measure_q8_resident as measurement
import darwin_usage
import linux_usage


def aggregate(records):
    measured = [record for record in records if not record["warmup"]]
    if not measured:
        raise ValueError("no measured requests")
    wall = [record["wall_ns"] / 1e9 for record in measured]
    compute = [record["delta"]["monolith_batch_compute_seconds_sum"] for record in measured]
    if any(value <= 0 for value in wall + compute):
        raise ValueError("nonpositive measurement")
    return {"wall_seconds": wall, "compute_seconds": compute, "mean_wall_seconds": mean(wall), "mean_compute_seconds": mean(compute)}


def summarize(root):
    root = root.resolve()
    data = json.loads((root / "result.json").read_text())
    protocol = json.loads((root / "protocol.json").read_text())
    schedule = ["before", "after", "after", "before"]
    if protocol["schedule"] != schedule or len(data["legs"]) != 4:
        raise ValueError("unexpected schedule")
    for name, expected in data["raw_file_sha256"].items():
        path = (root / name).resolve()
        if root not in path.parents or measurement.sha(path) != expected:
            raise ValueError(f"changed or unsafe raw artifact {name}")
    reference = json.loads((root / "reference.json").read_text())
    if reference != data["reference"]:
        raise ValueError("reference changed")
    legs, first_response = [], None
    for index, leg in enumerate(data["legs"]):
        if leg["label"] != schedule[index] or leg["index"] != index or leg["returncode"] != 0:
            raise ValueError("invalid leg identity or shutdown")
        binaries = protocol.get("binaries", measurement.BINARIES)
        if leg["binary_sha256"] != binaries[leg["label"]][1]:
            raise ValueError("unexpected binary identity")
        directory = root / f"leg{index}-{leg['label']}"
        warmups = protocol["warmups_per_leg"]
        if json.loads((directory / "result.json").read_text()) != leg or len(leg["records"]) != protocol["repeats"] + warmups:
            raise ValueError("leg or repeat count changed")
        for trial, record in enumerate(leg["records"]):
            prefix = directory / f"request{trial}"
            if record["trial"] != trial or record["warmup"] != (trial < warmups) or json.loads(prefix.with_suffix(".timing.json").read_text()) != record:
                raise ValueError("request timing or warmup label changed")
            raw = prefix.with_suffix(".response.json").read_bytes()
            measurement.validate_completion(json.loads(raw), protocol["tokens"], reference)
            if first_response is None:
                first_response = raw
            if raw != first_response or measurement.sha(prefix.with_suffix(".response.json")) != record["response_sha256"]:
                raise ValueError("response bytes changed")
            before = measurement.parse_metrics(prefix.with_suffix(".before.prom").read_bytes())
            after = measurement.parse_metrics(prefix.with_suffix(".after.prom").read_bytes())
            if measurement.metric_delta(before, after, protocol["tokens"]) != record["delta"]:
                raise ValueError("metric delta changed")
            if "usage" in record:
                usage = record["usage"]
                observer = linux_usage if usage.get("kind") == "linux-proc-v1" else darwin_usage
                if observer.difference(usage["before"], usage["after"], record["wall_ns"]) != usage["derived"]:
                    raise ValueError("process counter derivation changed")
        legs.append({"index": index, "label": leg["label"], **aggregate(leg["records"])})
    pairs = []
    for before, after in ((0, 1), (3, 2)):
        pairs.append({"before_leg": before, "after_leg": after,
                      "wall_ratio": legs[after]["mean_wall_seconds"] / legs[before]["mean_wall_seconds"],
                      "compute_ratio": legs[after]["mean_compute_seconds"] / legs[before]["mean_compute_seconds"]})
    return {"protocol": "q8-resident-http-generation-summary-v1", "input": str(root),
            "input_sha256": measurement.sha(root / "result.json"), "reader_sha256": measurement.sha(Path(__file__)),
            "measurement_protocol": protocol, "reference": reference, "legs": legs, "comparison_pairs": pairs,
            "same_baseline_late_over_early": {"wall_ratio": legs[3]["mean_wall_seconds"] / legs[0]["mean_wall_seconds"],
                                              "compute_ratio": legs[3]["mean_compute_seconds"] / legs[0]["mean_compute_seconds"]},
            "same_candidate_late_over_early": {"wall_ratio": legs[2]["mean_wall_seconds"] / legs[1]["mean_wall_seconds"],
                                               "compute_ratio": legs[2]["mean_compute_seconds"] / legs[1]["mean_compute_seconds"]},
            "all_response_bytes_identical": True,
            "scope": "Warmup excluded; resident single-request HTTP latency includes prefill, scheduling and response transfer. Compute sums cover engine model batches, not decode alone. Independent request/process estimates; no equivalence test or universal speed claim."}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(summarize(args.input), indent=2))


if __name__ == "__main__":
    main()
