#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Repeat the same complete comparison once and record competing host CPU usage."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import json
import os
from pathlib import Path
import runpy
import subprocess
from threading import Event
import time

HERE = Path(__file__).resolve().parent
INTERVAL = 2
ENTRY_SAMPLES = 10


def external_cpu():
    # Darwin ps reports percent of one core. Exclude this observer and its
    # descendants (model workers, compiler and ps itself). Retain no identities.
    raw = subprocess.check_output(["/bin/ps", "-A", "-o", "pid=,ppid=,%cpu="], text=True)
    rows = [line.split() for line in raw.splitlines() if line.strip()]
    parents = {int(pid):int(ppid) for pid,ppid,_ in rows}
    excluded = {os.getpid()}
    while True:
        children = {pid for pid,ppid in parents.items() if ppid in excluded}
        if children <= excluded:
            break
        excluded.update(children)
    values = [float(cpu) for pid,_,cpu in rows if int(pid) not in excluded]
    return round(sum(values),1), max(values, default=0)


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("model", type=Path)
    cli.add_argument("output", type=Path)
    cli.add_argument("--existing-load", action="store_true",
                     help="start with the existing host load and label it in the log")
    args = cli.parse_args()
    args.output.mkdir(parents=True, exist_ok=False)
    start = time.monotonic()
    with (args.output/"load.jsonl").open("x", buffering=1) as log:
        def sample(phase):
            total, busiest = external_cpu()
            print(json.dumps(dict(seconds=round(time.monotonic()-start,2), phase=phase,
                                  total_pct=total, busiest_pct=busiest)), file=log)
            return total <= 150 and busiest <= 40
        if args.existing_load:
            sample("existing_load_entry")
        else:
            consecutive = 0
            while consecutive < ENTRY_SAMPLES:
                consecutive = consecutive + 1 if sample("entry") else 0
                if time.monotonic()-start > 600:
                    raise TimeoutError("no quiet entry window within ten minutes")
                time.sleep(INTERVAL)
        def monitor(stop):
            while not stop.is_set():
                sample("run")
                stop.wait(INTERVAL)

        trial = runpy.run_path(str(HERE / "run.py"))["run"]
        stop = Event()
        with ThreadPoolExecutor(max_workers=1) as pool:
            monitor_result = pool.submit(monitor, stop)
            try:
                trial(args.model.resolve(), args.output.resolve() / "run")
            finally:
                stop.set()
                monitor_result.result()


if __name__ == "__main__":
    main()
