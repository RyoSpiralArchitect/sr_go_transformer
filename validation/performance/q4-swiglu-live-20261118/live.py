#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Interleave separate warmed runtime binaries, using the prior resident driver."""

import argparse
from contextlib import ExitStack
import json
from pathlib import Path
import platform
import signal
import subprocess
import sys

from variant import RECORD, RESIDENT, ROOT, candidate, fixture

sys.path.insert(0, str(RESIDENT.parent))
import run as resident  # earlier resident Worker has pipe and cleanup handling

RUNTIME = ROOT/"cmd/monolith/monolith.go"
PROTOCOL = RECORD/"protocol.json"


def ask_order(group, case_offset, phase_offset, rnd):
    return ("left", "right") if (group + case_offset + phase_offset + rnd) % 2 == 0 else ("right", "left")


def phases(case, group):
    return case["phases"][::-1] if group == 1 else case["phases"]


def run(args, spec):
    model, out = args.model.resolve(), args.output.resolve()
    env = resident.isolated_go_environment()
    goroot = Path(resident.command(ROOT/"scripts/go.sh","env","GOROOT",cwd=ROOT,env=env))
    go = goroot/"bin/go"
    h = resident.command("/usr/sbin/sysctl","-n","machdep.cpu.brand_string")
    version = resident.command(go,"version",env=env)
    if h != spec["host"] or version != spec["go"] or (platform.system(),platform.machine()) != ("Darwin","arm64"):
        raise ValueError("use the frozen host and Go version")
    if resident.sha(RUNTIME) != spec["runtime_sha256"]["baseline"]:
        raise ValueError("use the recorded unmodified runtime")
    catalog = ROOT/"validation/hf/model-profiles.json"
    corpus = ROOT/"validation/quality/corpus.json"
    checkpoint = next(x for x in json.loads(catalog.read_text())["models"] if x["id"]==spec["model_id"])
    if checkpoint["revision"] != spec["model_revision"]:
        raise ValueError("model revision changed")
    weights = {model/f:d for f,d in checkpoint["files"].items()}

    def verify(mapping):
        for file,digest in mapping.items():
            if resident.sha(file) != digest:
                raise ValueError(f"input hash differs: {file.name}")

    verify(weights)
    go_sources = [ROOT/f for f in ("go.mod","go.sum","cmd/monolith/inference_perf_test.go")]
    inputs = {p:resident.sha(p) for p in (PROTOCOL, RECORD/"variant.py", Path(__file__).resolve(), RUNTIME,
                                          RESIDENT, RESIDENT.parent/"run.py", RESIDENT.parent/"variants.py",
                                          catalog, corpus, ROOT/"scripts/compare_inference.py",
                                          ROOT/"scripts/quant_quality.py", ROOT/"scripts/go.sh", *go_sources)}
    out.mkdir(parents=True,exist_ok=False)
    build = out/"build"
    binaries, hashes, identities = {}, {}, {}
    runtime = RUNTIME.read_text()
    for mode, text in (("baseline",runtime),("candidate",candidate(runtime))):
        stage = build/mode
        stage.mkdir(parents=True)
        (stage/"monolith.go").write_text(text)
        (stage/"resident_test.go").write_text(fixture(RESIDENT.read_text()))
        for f in go_sources:
            (stage/f.name).write_bytes(f.read_bytes())
        subprocess.run([goroot/"bin/gofmt","-w", stage/"monolith.go", stage/"resident_test.go"],check=True,timeout=30)
        expected = spec["runtime_sha256"][mode]
        if resident.sha(stage/"monolith.go") != expected:
            raise ValueError(f"{mode} runtime does not match protocol")
        identity = {f:resident.sha(f) for f in stage.iterdir()}
        binary = stage/"resident.test"
        with (stage/"build.log").open("xb") as log:
            subprocess.run([go,"test","-c","-trimpath","-o",binary,"."],cwd=stage,env=env,
                           check=True,stdout=log,stderr=subprocess.STDOUT,timeout=300)
        binaries[mode] = binary
        hashes.update(identity | {binary:resident.sha(binary)})
        identities[mode] = dict(sources={f.name:d for f,d in identity.items()},binary_sha256=hashes[binary])
    if args.build_only:
        (out/"build.json").write_text(json.dumps(identities,indent=2)+"\n")
        return

    env.update(MONOLITH_RESIDENT_MODEL=str(model),MONOLITH_RESIDENT_CORPUS=str(corpus))
    start = resident.memory()
    limits = spec["memory"]
    if start["free_percent"] < limits["entry_free_percent"]:
        raise ValueError("host memory below entry limit")
    signal.signal(signal.SIGALRM, _timeout)
    signal.alarm(spec["timebox_seconds"])
    try:
        with (out/"events.jsonl").open("x",buffering=1) as log, ExitStack() as stack:
            def event(kind,**data):
                log.write(json.dumps(dict(event=kind,**data),allow_nan=False)+"\n")

            def memory_check():
                point = resident.memory()
                if (point["free_percent"] < limits["min_free_percent"] or
                    point["swapouts"]-start["swapouts"] > limits["max_new_swapout_pages"]):
                    event("memory_stop",memory=point)
                    raise ValueError("host memory or swapout bound crossed")
                return point

            event("start",model=checkpoint["repo"],revision=checkpoint["revision"],assets=checkpoint["files"],
                  cpu=h,go=version,memory=start,builds=identities,
                  inputs={str(p.relative_to(ROOT)):d for p,d in inputs.items()})

            def launch(mode, label, owned):
                proc = resident.Worker(binaries[mode], env, owned.enter_context((out/f"{label}.log").open("xb")))
                owned.callback(proc.stop)
                ready = proc.receive(180)
                event("ready",label=label,arm=mode,ready=ready,memory=memory_check())
                if ready["executor_bytes"] != 120 or ready["ready"]["weight_format"] != spec["weights"]:
                    raise ValueError("unexpected worker footprint or weight format")
                print(f"{label}: {mode} ready",flush=True)
                return proc, ready

            left, reference_plan = launch("baseline","left",stack)
            known = {}
            for group, mode in enumerate(spec["partner_order"]):
                with ExitStack() as partner:
                    right, plan = launch(mode,f"right-{group}",partner)
                    if plan != reference_plan:
                        raise ValueError("load plan or prompts differ")
                    workers = {"left":left,"right":right}
                    event("group",group=group,right=mode)
                    for i, idx in enumerate(spec["case_order"][group]):
                        case = spec["cases"][idx]
                        key = case["id"]
                        warm = {}
                        for arm in ask_order(group,i,0,0):
                            if arm == "left" and key in known:
                                event("reuse",group=group,case=key,arm=arm)
                                continue
                            warm[arm] = workers[arm].ask("prepare",case=case,seconds=150)
                            event("warm",group=group,case=key,arm=arm,checkpoints=warm[arm])
                        if "left" in warm:
                            known[key] = warm["left"]
                        if warm["right"] != known[key]:
                            raise ValueError(f"checkpoint or warm-up results differ in {key}")
                        for j, phase in enumerate(phases(case,group)):
                            for rnd in range(spec["rounds_each"][group]):
                                for arm in ask_order(group,i,j,rnd):
                                    s = workers[arm].ask(phase,case=case,seconds=90)
                                    event("sample",group=group,case=key,phase=phase,rnd=rnd,arm=arm,sample=s)
                                    if s["Signature"] != known[key][phase]:
                                        raise ValueError(f"forward result differs: {key}, {phase}")
                            event("end_phase",group=group,case=key,phase=phase,memory=memory_check())
                            print(f"group {group}: {key}/{phase}, {spec['rounds_each'][group]} pairs",flush=True)
                    event("end_group",group=group,memory=memory_check(),rss_kib=[left.rss_kib(),right.rss_kib()])
                    quit_worker(right)
            quit_worker(left)
            verify(inputs | hashes | weights)
            event("complete",memory=memory_check())
    finally:
        signal.alarm(0)


def quit_worker(worker):
    if worker.ask("quit",seconds=10) != {"stopped":True} or worker.proc.wait(10) != 0:
        raise ValueError("probe did not shut down cleanly")


def _timeout(*_):
    raise TimeoutError("frozen resident budget expired")


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("--model",type=Path,required=True)
    cli.add_argument("--output",type=Path,required=True)
    cli.add_argument("--build-only",action="store_true")
    args = cli.parse_args()
    run(args,json.loads(PROTOCOL.read_text()))


if __name__ == "__main__":
    main()
