import argparse
import hashlib
import json
import os
import subprocess
import threading
from pathlib import Path

import linux_usage
import measure_q8_resident as resident


def file_sha(path):
    digest = hashlib.sha256()
    with path.open("rb") as file:
        for block in iter(lambda: file.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parent
    build = json.loads((root / "q8-furnace-build-20261109.json").read_text())
    cpus = sorted(os.sched_getaffinity(0))
    if cpus != [4, 5, 6, 7]:
        raise ValueError("run controller under taskset -c4-7; no host-wide affinity changes")
    for name, expected in (*build["binaries"].values(), *build["test_binaries"].values()):
        if file_sha(root / name) != expected:
            raise ValueError(f"binary changed: {name}")
    output = args.output.resolve()
    output.mkdir(exist_ok=False)
    model = root / "model"
    assets = {name: file_sha(model / name) for name in build["model_assets"]}
    if assets != build["model_assets"]:
        raise ValueError("model assets differ from Mac manifest")
    resident.save(output / "assets-before.json", assets)
    for label, (name, _) in build["test_binaries"].items():
        fixture = root / f"fixture-{label}"
        if file_sha(fixture / "cmd/monolith/monolith.go") != build["source_sha256"][label]:
            raise ValueError("fixture source identity changed")
        with (output / f"tests-{label}.log").open("xb") as log:
            subprocess.run([str(root / name), "-test.count=1", "-test.timeout=10m"], cwd=fixture,
                           stdout=log, stderr=subprocess.STDOUT, check=True)
    schedule = ["before", "after", "after", "before"]
    resident.ROOT = root
    resident.BINARIES = build["binaries"]
    config = argparse.Namespace(model=model, tokens=64, repeats=3, warmups=2, usage_helper=None, linux_observer=True)
    resident.save(output / "protocol.json", {"schedule": schedule, "tokens": 64, "repeats": 3, "warmups_per_leg": 2,
         "binaries": build["binaries"], "build": build, "affinity": cpus,
         "scope": "Independent Linux resident-generation experiment; no Mac speed/frequency inference. HTTP includes prefill and response transfer.",
         "predeclared_screens": {"within_leg_request_max_over_min": 1.05, "same_binary_late_over_early_mean": [0.97, 1.03]},
         "limitations": "GPU job remains active on host. Affinity constrains only our processes, not exclusive cores or shared memory bandwidth. perf disallowed by policy; no security, governor, turbo or power setting changed.",
         "source_sha256": {name: file_sha(root / name) for name in ("measure_q8_furnace.py", "measure_q8_resident.py", "linux_usage.py", "darwin_usage.py")},
         "gates_sha256": file_sha(root / "q8-furnace-gates-20261109.json")})
    errors = []
    stop = threading.Event()

    def monitor():
        try:
            with (output / "machine.jsonl").open("x") as file:
                while not stop.is_set():
                    file.write(json.dumps(linux_usage.machine(cpus)) + "\n")
                    file.flush()
                    stop.wait(1)
        except Exception as error:
            errors.append(str(error))

    thread = threading.Thread(target=monitor)
    thread.start()
    legs, reference = [], None
    try:
        for index, label in enumerate(schedule):
            leg, reference = resident.run_leg(label, index, config, output, reference)
            legs.append(leg)
    finally:
        stop.set()
        thread.join(timeout=10)
    if thread.is_alive() or errors:
        raise RuntimeError(f"machine telemetry failed: {errors}")
    after = {name: file_sha(model / name) for name in assets}
    resident.save(output / "assets-after.json", after)
    if after != assets:
        raise ValueError("model changed during measurement")
    hashes = {str(path.relative_to(output)): file_sha(path) for path in sorted(output.rglob("*")) if path.is_file()}
    resident.save(output / "result.json", {"legs": legs, "reference": reference, "raw_file_sha256": hashes})


if __name__ == "__main__":
    main()
