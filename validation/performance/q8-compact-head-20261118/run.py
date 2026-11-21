#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Interleave uninstrumented forward calls in four warmed model processes."""

import argparse
from contextlib import ExitStack
import json
import os
from pathlib import Path
import platform
import re
import selectors
import subprocess
import sys
import time

from variants import PATCH, RECORD, RUNTIME, make_variant

ROOT = RECORD.parents[2]
sys.path.insert(0, str(ROOT / "scripts"))
from compare_inference import isolated_go_environment, sha


def command(*args, **kwargs):
    return subprocess.check_output(args, text=True, timeout=30, **kwargs).strip()


def memory():
    free = re.search(r"memory free percentage:\s*(\d+)%", command("/usr/bin/memory_pressure", "-Q"))
    swaps = re.search(r"^Swapouts:\s+(\d+)\.$", command("/usr/bin/vm_stat"), re.M)
    if not free or not swaps:
        raise ValueError("missing host memory counters")
    return {"free_percent": int(free[1]), "swapouts": int(swaps[1])}


def arm_order(spec, phase, round_):
    rows = spec["orders"]
    offset = round_ if round_ < len(rows) else spec["rounds"] - 1 - round_
    return rows[(phase + offset) % len(rows)]


class Worker:
    def __init__(self, binary, env, diagnostic):
        self.proc = subprocess.Popen([binary, "-test.run=^TestHFResidentHeadPerf$", "-test.timeout=20m"],
                                     stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=diagnostic, env=env)
        self.diagnostic = diagnostic
        self.buffer = b""

    def receive(self, seconds):
        deadline = time.monotonic() + seconds
        with selectors.DefaultSelector() as sel:
            sel.register(self.proc.stdout, selectors.EVENT_READ)
            while b"\n" not in self.buffer:
                timeout = deadline - time.monotonic()
                if timeout <= 0 or not sel.select(timeout):
                    raise TimeoutError("resident probe did not reply")
                chunk = os.read(self.proc.stdout.fileno(), 65536)
                if not chunk:
                    raise ValueError("resident probe exited without a reply")
                self.buffer += chunk
                if len(self.buffer) > 1 << 20:
                    raise ValueError("resident probe reply exceeded 1 MiB")
        line, self.buffer = self.buffer.split(b"\n", 1)
        try:
            return json.loads(line)
        except ValueError:
            self.diagnostic.write(line + b"\n" + self.buffer)
            self.diagnostic.flush()
            raise ValueError("invalid resident probe reply; see local diagnostic") from None

    def ask(self, op, case=None, seconds=120):
        request = {"Op": op}
        if case:
            request.update(Sessions=case["sessions"], Prefix=case["prefix"], KV=case["kv"])
        self.proc.stdin.write(json.dumps(request).encode() + b"\n")
        self.proc.stdin.flush()
        return self.receive(seconds)

    def rss_kib(self):
        return int(command("/bin/ps", "-p", str(self.proc.pid), "-o", "rss="))

    def stop(self):
        # Only owned children. Called on both successful and incomplete runs.
        if self.proc.poll() is None:
            self.proc.terminate()
            try:
                self.proc.wait(5)
            except subprocess.TimeoutExpired:
                self.proc.kill()
                self.proc.wait(5)
        self.proc.stdin.close()
        self.proc.stdout.close()


def run(spec, snapshot, output):
    if (platform.system(), platform.machine()) != ("Darwin", "arm64"):
        raise ValueError("protocol requires Apple Silicon")
    cpu = command("/usr/sbin/sysctl", "-n", "machdep.cpu.brand_string")
    if cpu != spec["cpu"]:
        raise ValueError("protocol requires the recorded CPU")
    env = isolated_go_environment()
    goroot = Path(command(ROOT/"scripts/go.sh", "env", "GOROOT", cwd=ROOT, env=env))
    go = goroot/"bin/go"
    version = command(go, "version", env=env)
    if version != spec["go_version"]:
        raise ValueError("use the frozen Go version")
    if sha(ROOT/RUNTIME) != spec["runtime_sha256"]["baseline"]:
        raise ValueError("use a worktree with the baseline runtime")
    catalog = ROOT/"validation/hf/model-profiles.json"
    corpus = ROOT/"validation/quality/corpus.json"
    model = next(m for m in json.loads(catalog.read_text())["models"] if m["id"] == spec["model_id"])
    if model["revision"] != spec["model_revision"]:
        raise ValueError("model revision changed")
    assets = {snapshot / name: want for name, want in model["files"].items()}

    def check_hashes(hashes):
        if any(sha(path) != want for path, want in hashes.items()):
            raise ValueError("hashed files changed or differ from the protocol")

    check_hashes(assets)
    probe = RECORD/"resident_test.go.txt"
    perf = ROOT/"cmd/monolith/inference_perf_test.go"
    globals_ = [catalog, corpus, probe, perf, PATCH, RECORD/"variants.py", Path(__file__).resolve(),
                RECORD/"protocol.json", ROOT/RUNTIME, ROOT/"go.mod", ROOT/"go.sum",
                ROOT/"scripts/compare_inference.py", ROOT/"scripts/quant_quality.py", ROOT/"scripts/go.sh"]
    inputs = {p: sha(p) for p in globals_}
    output.mkdir(parents=True, exist_ok=False)
    artifacts, builds, hashes = {}, {}, {}
    for mode, runtime_hash in spec["runtime_sha256"].items():
        build = output/"build"/mode
        (build/RUNTIME.parent).mkdir(parents=True)
        for name in (RUNTIME, Path("go.mod"), Path("go.sum")):
            (build/name).write_bytes((ROOT/name).read_bytes())
        make_variant(build, mode)
        if sha(build/RUNTIME) != runtime_hash:
            raise ValueError(f"{mode} runtime differs from the protocol")
        for source, target in ((probe, "resident_perf_test.go"), (perf, perf.name)):
            (build/RUNTIME.parent/target).write_bytes(source.read_bytes())
        sources = {p: sha(p) for p in build.rglob("*") if p.is_file()}
        binary = build/"resident.test"
        with (build/"build.log").open("xb") as log:
            subprocess.run([go, "test", "-c", "-trimpath", "-o", binary, "./cmd/monolith"],
                           cwd=build, env=env, stdout=log, stderr=subprocess.STDOUT, check=True, timeout=300)
        artifacts[mode], binary_hash = binary, sha(binary)
        hashes.update(sources | {binary: binary_hash})
        builds[mode] = dict(binary_sha256=binary_hash, sources={str(p.relative_to(build)): h for p,h in sources.items()})
    env.update(MONOLITH_RESIDENT_MODEL=str(snapshot), MONOLITH_RESIDENT_CORPUS=str(corpus))
    modes = {"reference": "baseline", "control": "baseline", "pair": "pair", "shared": "shared"}
    with (output/"events.jsonl").open("x", buffering=1) as journal, ExitStack() as cleanup:
        def event(kind, **values):
            journal.write(json.dumps(dict(event=kind, **values), allow_nan=False) + "\n")

        start = memory()
        if start["free_percent"] < 55:
            raise ValueError("need at least 55% free memory before loading four models")
        event("start", host=f"{platform.system()}/{platform.machine()}", cpu=cpu, go=version,
              memory=start, builds=builds, model_files=model["files"], revision=model["revision"],
              inputs={str(p.relative_to(ROOT)): h for p,h in inputs.items()}, modes=modes)
        workers, ready = {}, {}
        for arm, mode in modes.items():
            log = cleanup.enter_context((output/f"{arm}.log").open("xb"))
            worker = Worker(artifacts[mode], env, log)
            cleanup.callback(worker.stop)
            workers[arm] = worker
            ready[arm] = worker.receive(180)
            event("ready", arm=arm, reply=ready[arm], rss_kib=worker.rss_kib(), memory=memory())
            if (ready[arm]["executor_bytes"] != spec["executor_bytes"] or
                    ready[arm]["ready"]["weight_format"] != spec["weights"] or ready[arm] != ready["reference"]):
                raise ValueError("resident workers disagree on plan, prompt IDs or executor size")
            print(f"Ready: {arm} ({worker.rss_kib() / 1024:.0f} MiB RSS)", flush=True)
        phase = 0
        for case_index, case in enumerate(spec["cases"]):
            before = memory()
            event("case", case=case, memory=before)
            if before["free_percent"] < spec["min_memory_free_percent"]:
                raise ValueError("insufficient free memory for the resident comparison")
            print(f"Prepare {case['id']}", flush=True)
            warm = {}
            for arm in spec["orders"][case_index % 4]:
                warm[arm] = workers[arm].ask("prepare", case=case, seconds=180)
                event("warm", case=case["id"], arm=arm, signatures=warm[arm])
            if any(r != warm["reference"] for r in warm.values()):
                raise ValueError(f"numerical mismatch preparing {case['id']}")
            for stage in case["phases"]:
                for round_ in range(spec["rounds"]):
                    order = arm_order(spec, phase, round_)
                    for arm in order:
                        result = workers[arm].ask(stage)
                        event("sample", case=case["id"], phase=stage, round=round_, arm=arm, sample=result)
                        if result["Signature"] != warm["reference"][stage]:
                            raise ValueError(f"numerical mismatch in {case['id']} {stage} round {round_}")
                    print(f"{case['id']} {stage}: round {round_+1}/{spec['rounds']}", flush=True)
                phase += 1
            event("end_case", case=case["id"], memory=memory(), rss_kib={a: w.rss_kib() for a,w in workers.items()})
        for worker in workers.values():
            if worker.ask("quit") != {"stopped": True} or worker.proc.wait(10) != 0:
                raise ValueError("resident worker did not shut down cleanly")
        check_hashes(inputs | hashes | assets)
        event("complete", memory=memory())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--model", type=Path, required=True)
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    run(json.loads((RECORD/"protocol.json").read_text()), args.model.resolve(), args.output.resolve())


if __name__ == "__main__":
    main()
