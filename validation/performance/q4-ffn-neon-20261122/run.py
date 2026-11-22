#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Compare complete ordinary packages with the archived offline resident fixture."""
import argparse
from contextlib import ExitStack
import json
from pathlib import Path
import shutil
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PREVIOUS = HERE.parent / "q8-compact-head-20261118"
sys.path.insert(0, str(PREVIOUS))
from run import Worker, command, isolated_go_environment, memory, sha

FIXTURE = PREVIOUS / "resident_test.go.txt"
HARNESS = ROOT / "cmd/monolith/inference_perf_test.go"
CORPUS = ROOT / "validation/quality/corpus.json"
CATALOG = ROOT / "validation/hf/model-profiles.json"
PROTOCOL = HERE / "protocol.json"
PACKAGE = Path("cmd/monolith")


def build(out, base, go, env):
    if base:
        files = subprocess.check_output(["git", "ls-tree", "-r", "--name-only", base, "--", str(PACKAGE)],
                                        cwd=ROOT, text=True).splitlines()
    else:
        files = [str(p.relative_to(ROOT)) for p in (ROOT / PACKAGE).iterdir() if p.is_file()]
    names = ["go.mod", "go.sum"] + sorted(n for n in files
              if n.endswith((".s", ".go")) and not n.endswith("_test.go"))
    (out / PACKAGE).mkdir(parents=True)
    for name in names:
        data = (subprocess.check_output(["git", "show", f"{base}:{name}"], cwd=ROOT)
                if base else (ROOT / name).read_bytes())
        (out / name).write_bytes(data)
    shutil.copyfile(FIXTURE, out / PACKAGE / "resident_test.go")
    shutil.copy(HARNESS, out / PACKAGE)
    sources = {str(p.relative_to(out)): sha(p) for p in sorted(out.rglob("*")) if p.is_file()}
    binary = out / "resident.test"
    subprocess.run([go, "test", "-c", "-trimpath", "-o", binary, "./cmd/monolith"],
                   cwd=out, env=env, timeout=240, check=True)
    symbols = command(go, "tool", "nm", binary, env=env)
    native = any("dotQ4FFNPairNEON.abi0" in line for line in symbols.splitlines())
    if native != (base is None):
        raise ValueError("unexpected native code in linked binary")
    return binary, dict(sources=sources, binary_sha256=sha(binary), native=native)


def run(model, out):
    out.mkdir(parents=True, exist_ok=False)
    spec = json.loads(PROTOCOL.read_text())
    env = isolated_go_environment()
    go = shutil.which("go", path=env["PATH"])
    if not go or command(go, "version", env=env) != spec["go"]:
        raise ValueError("use the Go toolchain in protocol.json")
    cpu = command("/usr/sbin/sysctl", "-n", "machdep.cpu.brand_string")
    if cpu != spec["cpu"]:
        raise ValueError("CPU differs from protocol")
    checkpoint = next(x for x in json.loads(CATALOG.read_text())["models"] if x["id"] == spec["model_id"])
    if checkpoint["revision"] != spec["revision"]:
        raise ValueError("snapshot revision differs")
    for name, digest in checkpoint["files"].items():
        if sha(model / name) != digest:
            raise ValueError(f"unexpected model asset: {name}")
    binaries, builds = {}, {}
    for label, base in (("A", spec["baseline"]), ("B", None)):
        binaries[label], builds[label] = build(out / label, base, go, env)
    inputs = [FIXTURE, PREVIOUS / "run.py", PREVIOUS / "variants.py", CORPUS, CATALOG, PROTOCOL,
              HERE / "run.py", ROOT / "scripts/compare_inference.py", ROOT / "scripts/quant_quality.py"]
    env.update(MONOLITH_RESIDENT_MODEL=str(model), MONOLITH_RESIDENT_CORPUS=str(CORPUS))
    start = memory()
    def check_memory():
        m = memory()
        if (m["free_percent"] < spec["limits"]["min_free_percent"]
                or m["swapouts"] - start["swapouts"] > spec["limits"]["max_new_swapout_pages"]):
            raise ValueError(f"memory bound crossed: {m}")
        return m

    with ExitStack() as stack:
        log = stack.enter_context((out / "events.jsonl").open("x", buffering=1))
        def event(kind, **values):
            print(json.dumps(dict(event=kind, **values), separators=(",", ":"), allow_nan=False), file=log)
        event("start", baseline=spec["baseline"], cpu=cpu, go=spec["go"], builds=builds,
              repo=checkpoint["repo"], revision=spec["revision"], assets=checkpoint["files"],
              inputs={str(p.relative_to(ROOT)):sha(p) for p in inputs}, memory=check_memory())
        procs, plans = {}, {}
        for label, binary in binaries.items():
            worker = Worker(binary, env, stack.enter_context((out / f"{label}.log").open("xb")))
            stack.callback(worker.stop)
            procs[label] = worker
            plans[label] = worker.receive(180)
            event("ready", arm=label, ready=plans[label], memory=check_memory())
        if plans["A"] != plans["B"] or plans["A"]["ready"]["weight_format"] != spec["weights"]:
            raise ValueError("load plan or prompts differ")
        for idx, (prefix, sessions) in enumerate(spec["cases"]):
            case = dict(prefix=prefix, sessions=sessions, kv=spec["kv"])
            print(f"prepare prefix={prefix} sessions={sessions}", flush=True)
            warm = {}
            for arm in ("AB" if idx % 2 == 0 else "BA"):
                warm[arm] = procs[arm].ask("prepare", case, seconds=240)
                event("warm", case=case, arm=arm, result=warm[arm], memory=check_memory())
            if warm["A"] != warm["B"]:
                raise ValueError(f"warm signatures differ: {case}")
            for rnd, order in enumerate(spec["orders"]):
                for label in (order if idx % 2 == 0 else reversed(order)):
                    sample = procs[label.upper()].ask("decode", case, seconds=60)
                    event("sample", case=case, round=rnd, label=label, sample=sample)
                    if sample["Signature"] != warm["A"]["decode"] or len(sample["Ns"]) != spec["forwards"]:
                        raise ValueError(f"decode mismatch: {case}, round {rnd}, {label}")
                check_memory()
            event("end_case", case=case, rss_kib={k:v.rss_kib() for k,v in procs.items()}, memory=check_memory())
        for worker in procs.values():
            if worker.ask("quit", seconds=10) != {"stopped": True} or worker.proc.wait(10) != 0:
                raise ValueError("unclean worker exit")
        event("complete", memory=check_memory())


if __name__ == "__main__":
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("model", type=Path)
    cli.add_argument("output", type=Path)
    args = cli.parse_args()
    run(args.model.resolve(), args.output.resolve())
