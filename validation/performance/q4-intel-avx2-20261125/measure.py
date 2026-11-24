#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Measure the three production AVX2 settings in resident Furnace CPU processes."""
import argparse
from contextlib import ExitStack
import errno
import json
import os
from pathlib import Path
import platform
import shutil
import sys
from tempfile import TemporaryDirectory

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "q4-attention-neon-20261124"))
import probe

SPEC = HERE / "protocol.json"
SWITCH = "MONOLITH_Q4_FFN_AVX2"


def references(archive):
    rows = [json.loads(line) for line in archive.read_text().splitlines()]
    ready = next(r["result"] for r in rows if r["event"] == "ready" and r["arm"] == "A")
    warm = {r["sessions"]: r["result"] for r in rows if r["event"] == "warm" and r["arm"] == "A"}
    return ready, warm


def memory():
    available = next(l.split()[1] for l in Path("/proc/meminfo").read_text().splitlines() if l.startswith("MemAvailable:"))
    swapouts = next(l.split()[1] for l in Path("/proc/vmstat").read_text().splitlines() if l.startswith("pswpout "))
    return dict(available_kib=int(available), swapouts=int(swapouts))


def stage(source, dest, files):
    for name, digest in files.items():
        target = dest / name
        original = (source / name).resolve(strict=True)
        try:
            os.link(original, target)
        except OSError as err:
            if err.errno != errno.EXDEV:
                raise
            shutil.copyfile(original, target)
        if probe.sha(target) != digest:
            raise ValueError(f"snapshot hash differs for {name}")


def run(model_id, snapshot, binary, manifest, out):
    spec = json.loads(SPEC.read_text())
    builds = json.loads(manifest.read_text())
    if (builds["runtime"], builds["toolchain"], builds["target"]) != (spec["runtime"], spec["toolchain"], spec["target"]):
        raise ValueError("probe build differs from the protocol")
    if probe.sha(binary) != builds["binary"] or any(probe.sha(probe.ROOT/k) != v for k, v in builds["inputs"].items()):
        raise ValueError("binary or input hash differs from build manifest")
    cpuinfo = Path("/proc/cpuinfo").read_text().splitlines()
    cpu = next(l.split(":", 1)[1].strip() for l in cpuinfo if l.startswith("model name"))
    affinity = sorted(os.sched_getaffinity(0))
    if platform.machine() != "x86_64" or cpu != spec["cpu"] or affinity != spec["cores"]:
        raise ValueError("unexpected CPU or affinity")
    model = next(m for m in json.loads(probe.CATALOG.read_text())["models"] if m["id"] == model_id)
    ready_ref, warm = references(probe.ROOT / spec["models"][model_id])
    layers = ready_ref["ready"]["config"]["layers"]
    out.mkdir(parents=True, exist_ok=False)
    with TemporaryDirectory(dir=out) as staged, (out/"events.jsonl").open("x", buffering=1) as log:
        stage(snapshot, Path(staged), model["files"])
        def emit(kind, **fields):
            print(json.dumps(dict(event=kind, **fields), separators=(",", ":"), allow_nan=False), file=log)

        start = memory()
        def observe():
            m = memory()
            if m["available_kib"] < spec["limits"]["min_available_kib"] or m["swapouts"]-start["swapouts"] > spec["limits"]["max_new_swapouts"]:
                emit("memory_stop", memory=m)
                raise ValueError("host memory outside protocol")
            return m

        emit("start", model=model_id, repo=model["repo"], revision=model["revision"], assets=model["files"],
             build_sha256=probe.sha(manifest), binary=builds["binary"], cpu=cpu, affinity=affinity,
             kernel=platform.release(), modes=spec["modes"], memory=start)
        env = dict(probe.isolated_go_environment(), MONOLITH_RESIDENT_MODEL=staged, MONOLITH_RESIDENT_CORPUS=str(probe.CORPUS))
        for wave, settings in enumerate(spec["waves"]):
            with ExitStack() as stack:
                workers = {}
                for arm in settings["load"]:
                    diagnostic = stack.enter_context((out/f"worker-{wave}-{arm}.log").open("xb"))
                    worker = probe.Worker(binary, dict(env, **{SWITCH:spec["modes"][arm]},
                                         MONOLITH_PROFILE_PATH=str(out/arm)), diagnostic)
                    stack.callback(worker.stop)
                    workers[arm] = worker
                    ready = worker.receive(300)
                    emit("ready", wave=wave, arm=arm, result=ready, memory=observe())
                    attention = 4*layers if arm == "B" else 0
                    if ready != dict(ready_ref, pair=True, quad=arm!="A",
                                     routing=dict(attention=attention, ffn=3*layers, total=attention+3*layers)):
                        raise ValueError("incorrect matrix selection, startup hooks or model plan")
                for sessions in settings["sessions"]:
                    print(f"{model_id} wave {wave+1}, {sessions} session(s)", flush=True)
                    case = dict(sessions=sessions, prefix=spec["prefix"], kv=spec["kv"])
                    for arm, worker in workers.items():
                        result = worker.ask("prepare", case, seconds=240)
                        emit("warm", wave=wave, sessions=sessions, arm=arm, result=result)
                        if result != warm[sessions]:
                            raise ValueError("checkpoint or warm decode differs from the previous release")
                    for rnd, order in enumerate(settings["orders"]):
                        for label in (order if sessions == 1 else order[::-1]):
                            result = workers[label.upper()].ask("decode", case)
                            emit("sample", wave=wave, sessions=sessions, round=rnd, label=label, result=result)
                            if (result["Signature"] != warm[sessions]["decode"] or len(result["Ns"]) != spec["steps"]
                                    or any(type(t) != int or t <= 0 for t in result["Ns"])):
                                raise ValueError("decode differs from the previous release or has invalid timings")
                        emit("round_end", wave=wave, sessions=sessions, round=rnd, memory=observe())
                rss = {}
                for arm, worker in workers.items():
                    status = Path(f"/proc/{worker.proc.pid}/status").read_text().splitlines()
                    rss[arm] = int(next(l.split()[1] for l in status if l.startswith("VmHWM:")))
                emit("peaks", wave=wave, rss_kib=rss)
                if wave == len(spec["waves"])-1:
                    for sessions in settings["sessions"]:
                        case = dict(sessions=sessions, prefix=spec["prefix"], kv=spec["kv"])
                        for arm in ("A", "B"):
                            if workers[arm].ask("prepare", case, seconds=240) != warm[sessions]:
                                raise ValueError("profile warmup differs")
                            signatures = workers[arm].ask("profile", case)
                            if signatures != [warm[sessions]["decode"]]*spec["profile_replays"]:
                                raise ValueError("profile decode differs")
                            emit("profile", sessions=sessions, arm=arm, sha256=probe.sha(out/f"{arm}-{sessions}.pprof"))
                for worker in workers.values():
                    if worker.ask("quit") != {"stopped":True} or worker.proc.wait(10) != 0:
                        raise ValueError("unclean exit")
        emit("complete", memory=observe())


if __name__ == "__main__":
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("model_id", choices=json.loads(SPEC.read_text())["models"])
    for name in ("snapshot", "binary", "manifest", "output"):
        cli.add_argument(name, type=lambda p: Path(p).resolve())
    args = cli.parse_args()
    run(args.model_id, args.snapshot, args.binary, args.manifest, args.output)
