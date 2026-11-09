import argparse
import hashlib
import json
import re
from pathlib import Path
from statistics import median

ROOT = Path(__file__).resolve().parents[1]
PERF = ROOT / "validation/performance"
PATTERN = re.compile(r"^(Benchmark\S+?)(?:-\d+)?\s+\d+\s+([\d.]+) ns/op\s+(\d+) B/op\s+(\d+) allocs/op$")


def read_bench(path, expected_cases):
    rows = {}
    for line in path.read_text().splitlines():
        match = PATTERN.match(line)
        if match:
            name, ns, size, allocs = match.groups()
            if name in rows:
                raise ValueError(f"{path}: duplicate case {name}")
            rows[name] = {"ns": float(ns), "bytes": int(size), "allocs": int(allocs)}
    if len(rows) != expected_cases:
        raise ValueError(f"{path}: expected {expected_cases} cases, got {len(rows)}")
    return rows


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--prefix", default="q4-invocation")
    parser.add_argument("--cases", type=int, default=18)
    parser.add_argument("--runs", type=int, default=3)
    parser.add_argument("--benchtime", default="200ms")
    parser.add_argument("--before-binary", default="runs/post-singleexp-20261109-v2.test")
    parser.add_argument("--after-binary", default="runs/q4-invocation-candidate-20261109.test")
    parser.add_argument("--before-source", default="912870ebf6e41819ba51fc106864f32ec5b239973a0e302debcdf386b2d70717")
    parser.add_argument("--after-source", default="b544029fdac8bfdb3f5f4dcb610d94d28a930f89d795d4cb08cad65e6d1f9aa4")
    args = parser.parse_args()
    if args.cases < 1 or args.runs < 1:
        parser.error("cases and runs must be positive")
    for digest_value in (args.before_source, args.after_source):
        if not re.fullmatch(r"[0-9a-f]{64}", digest_value):
            parser.error("source identities must be SHA-256 digests")
    cases = {}
    raw = {}
    for run in range(1, args.runs + 1):
        legs = []
        for mode in ("before", "after"):
            path = PERF / f"{args.prefix}-generation-{mode}-20261109-run{run}.txt"
            raw[path.name] = digest(path)
            legs.append(read_bench(path, args.cases))
        before, after = legs
        if before.keys() != after.keys():
            raise ValueError("mismatched cases")
        for name in before:
            row = cases.setdefault(name, {"before": [], "after": [], "ratios": []})
            row["before"].append(before[name])
            row["after"].append(after[name])
            row["ratios"].append(after[name]["ns"] / before[name]["ns"])
    for row in cases.values():
        row["median_process_ratio"] = median(row["ratios"])
    paths = ["cmd/monolith/post_singleexp_profile_test.go", args.before_binary, args.after_binary]
    result = {
        "protocol": "q4-invocation-fresh-process-generation-v2",
        "ancestor_commit": "9af9a1c1bf8fc3b3797e8c0315031dc8fd270e50",
        "prefix": args.prefix,
        "declared_source_sha256": {"before": args.before_source, "after": args.after_source},
        "source_provenance": "Source identities are supplied from the build record; binary hashes are recomputed. Reading today's working tree does not establish the source of a historical executable.",
        "process_order": [["before", "after"] if run % 2 else ["after", "before"] for run in range(1, args.runs + 1)],
        "measurement": f"Go benchmark {args.benchtime} per leaf, count1, whole generation; worker count asserted inside leaf; {args.cases} fixed-order format/worker/shape cases in each process",
        "interpretation": "Each ratio divides independently calibrated ns/op estimates, not per-request matched pairs. Fixed format order and small synthetic model limit inference. Control interpretation depends on the selected change; see selection receipt. No universal speedup or across-format completion equality is claimed.",
        "source_and_binary_sha256": {path: digest(ROOT / path) for path in paths},
        "raw_file_sha256": raw,
        "cases": cases,
    }
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
