import hashlib
import json
import re
from pathlib import Path
from statistics import median

ROOT = Path(__file__).resolve().parents[1]
PERF = ROOT / "validation/performance"
OUTPUTS = ROOT / "runs/realmodel-llama3b"
PREFIX = "q8-cached-realmodel"
DATE = "20261109"
BINARIES = {"before": "runs/q4-refined-20261109", "after": "runs/q8-cached-invocation-20261109"}


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_time(path):
    values = {}
    for line in path.read_text().splitlines():
        match = re.fullmatch(r"\s*(real|user|sys) ([0-9]+(?:\.[0-9]+)?)\s*", line)
        counter = re.fullmatch(r"\s*(\d+)\s+(maximum resident set size|instructions retired|cycles elapsed|peak memory footprint)\s*", line)
        if match:
            key, value = match.group(1), float(match.group(2))
        elif counter:
            key, value = counter.group(2), int(counter.group(1))
        else:
            continue
        if key in values:
            raise ValueError(f"{path}: duplicate {key}")
        values[key] = value
    required = {"real", "user", "sys", "maximum resident set size"}
    if not required <= values.keys() or values["real"] <= 0 or values["maximum resident set size"] <= 0:
        raise ValueError(f"{path}: missing or nonpositive timing/RSS")
    return values


def paired_result(rows, pairs):
    ratios = [rows[after]["time"]["real"] / rows[before]["time"]["real"] for before, after in pairs]
    return {"pairs": pairs, "ratios": ratios, "median_ratio": median(ratios)}


def main():
    identities = {mode: digest(ROOT / path) for mode, path in BINARIES.items()}
    expected = {
        "before": "1fa2fd0f7bdf074a4a6db0280bd660a13216d1dc9a29ae69318d308856e287d8",
        "after": "e9ca0f3ad6fd84c48bb2504cb829466af30963a17f2e5eae210e9bc88dae119c",
    }
    if identities != expected:
        raise ValueError("saved CLI binary identity changed")
    if (PERF / f"{PREFIX}-assets-{DATE}.sha256").read_bytes() != (PERF / f"{PREFIX}-assets-after-{DATE}.sha256").read_bytes():
        raise ValueError("model asset manifests changed")
    groups = {format: [(f"{format}-before-run{run}", f"{format}-after-run{run}")
                       for run in range(1, count + 1)] for format, count in (("q8", 3), ("q4", 2))}
    controls = {stage: [(f"q8-{stage}-before", f"q8-{stage}-after")] for stage in ("precontrol", "postcontrol")}
    rows = {}
    for group, pairs in {**groups, **controls}.items():
        format = "q4" if group == "q4" else "q8"
        reference = OUTPUTS / f"q4-refined-{format}-after-{DATE}.out"
        reference_bytes = reference.read_bytes()
        for pair in pairs:
            for name in pair:
                mode = "after" if group in groups and "-after-" in name else "before"
                output = OUTPUTS / f"{PREFIX}-{name}-{DATE}.out"
                timing = PERF / f"{PREFIX}-{name}-{DATE}.time"
                if output.read_bytes() != reference_bytes:
                    raise ValueError(f"{output}: completion differs from {reference}")
                rows[name] = {
                    "format": format, "binary": BINARIES[mode], "binary_sha256": identities[mode],
                    "time": read_time(timing), "time_file": str(timing.relative_to(ROOT)),
                    "time_file_sha256": digest(timing), "stdout_file": str(output.relative_to(ROOT)),
                    "stdout_sha256": digest(output), "reference_stdout": str(reference.relative_to(ROOT)),
                }
    order = PERF / f"{PREFIX}-order-{DATE}.txt"
    completed = [line.split()[2] for line in order.read_text().splitlines() if " end " in line]
    if len(completed) != len(rows) or set(completed) != rows.keys():
        raise ValueError("incomplete or duplicate completed-run ledger")
    result = {
        "protocol": "q8-cached-realmodel-fresh-cli-v1", "scope": "Complete CLI process, not decode-only",
        "summarizer_sha256": digest(Path(__file__)),
        "model_manifest_after": f"validation/performance/{PREFIX}-assets-after-{DATE}.sha256",
        "model_manifest_after_sha256": digest(PERF / f"{PREFIX}-assets-after-{DATE}.sha256"),
        "units": {"real": "seconds", "user": "CPU seconds", "sys": "CPU seconds",
                  "maximum resident set size": "Darwin bytes", "peak memory footprint": "Darwin bytes"},
        "cases": {group: paired_result(rows, pairs) for group, pairs in groups.items()},
        "controls": {group: paired_result(rows, pairs) for group, pairs in controls.items()},
        "rows": rows, "completed_order": completed, "order_sha256": digest(order),
        "model_manifest": f"validation/performance/{PREFIX}-assets-{DATE}.sha256",
        "model_manifest_sha256": digest(PERF / f"{PREFIX}-assets-{DATE}.sha256"),
        "counter_scope": "OS process totals printed by /usr/bin/time -lp, including startup/loading/quantization/generation; not isolated kernel counters or a causal explanation.",
    }
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
