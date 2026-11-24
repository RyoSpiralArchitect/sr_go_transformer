#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Measure production FFN-only and FFN-plus-attention startup settings on M4."""
import argparse
from contextlib import ExitStack
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
SHARED = HERE.parent / "q8-compact-head-20261118"
SINGLE = HERE.parent / "q4-ffn-single-neon-20261124"
sys.path.insert(0, str(SHARED))
from run import Worker, command, isolated_go_environment, memory, sha

PACKAGE = Path("cmd/monolith")
SPEC = HERE / "protocol.json"
PROBE = HERE / "probe_test.go.txt"
FIXTURE = SHARED / "resident_test.go.txt"
CORPUS = ROOT / "validation/quality/corpus.json"
CATALOG = ROOT / "validation/hf/model-profiles.json"
SWITCH = "MONOLITH_Q4_FFN_NEON"


def pinned(ref, path):
    return subprocess.check_output(["git", "show", f"{ref}:{path}"], cwd=ROOT)


def sources(spec):
    ref = spec["runtime"]
    names = command("git", "ls-tree", "-r", "--name-only", ref, "--", str(PACKAGE), cwd=ROOT).splitlines()
    used = ["go.mod", "go.sum", str(PACKAGE / "inference_perf_test.go")]
    used.extend(n for n in names if n.endswith((".go", ".s")) and not n.endswith("_test.go"))
    contents = {n: pinned(ref, n) for n in used}
    fixture = pinned(ref, FIXTURE.relative_to(ROOT))
    marker = b'"executor_bytes": reflect.TypeOf(kernelExecutor{}).Size()'
    if fixture.count(marker) != 1:
        raise ValueError("unexpected resident fixture")
    contents[str(PACKAGE / "resident_test.go")] = fixture.replace(marker, marker + b', "routing": attentionProbeRoutes(m)')
    contents[str(PACKAGE / "attention_probe_test.go")] = PROBE.read_bytes()
    return contents


def digests(contents):
    return {k: hashlib.sha256(v).hexdigest() for k, v in contents.items()}


def inputs():
    files = [SPEC, PROBE, HERE / "probe.py", FIXTURE, CORPUS, CATALOG, SHARED / "run.py", SHARED / "variants.py",
             ROOT / "scripts/compare_inference.py", ROOT / "scripts/quant_quality.py"]
    return {str(p.relative_to(ROOT)): sha(p) for p in files}


def build(spec, out, go, env):
    (out / PACKAGE).mkdir(parents=True)
    contents = sources(spec)
    for name, data in contents.items():
        (out / name).write_bytes(data)
    binary = out / "probe.test"
    subprocess.run([go, "test", "-c", "-buildvcs=false", "-trimpath", "-o", binary, "./cmd/monolith"],
                   cwd=out, env=env, check=True)
    return binary, digests(contents)


def checkpoint(spec):
    model = next(m for m in json.loads(CATALOG.read_text())["models"] if m["id"] == spec["model"])
    if model["revision"] != spec["revision"]:
        raise ValueError("model revision differs")
    return model


def references(spec):
    archive = pinned(spec["previous"], (SINGLE / "events.jsonl").relative_to(ROOT))
    return {e["case"]["sessions"]: e["go"] for e in map(json.loads, archive.splitlines()) if e["event"] == "warm"}


def run(model, out):
    spec = json.loads(SPEC.read_text())
    env = isolated_go_environment()
    go = shutil.which("go", path=env["PATH"])
    if not go or command(go, "version", env=env) != spec["go"] or command("/usr/sbin/sysctl", "-n", "machdep.cpu.brand_string") != spec["cpu"]:
        raise ValueError("use the host and Go version in the protocol")
    entry = checkpoint(spec)
    if any(sha(model / name) != digest for name, digest in entry["files"].items()):
        raise ValueError("model assets differ from the pinned snapshot")
    out.mkdir(parents=True, exist_ok=False)
    binary, manifest = build(spec, out / "build", go, env)
    if sha(binary) != spec["binary_sha256"]:
        raise ValueError("rebuilt probe differs from the protocol")
    modes = {arm: dict(env, **{SWITCH: mode}, MONOLITH_RESIDENT_MODEL=str(model),
                       MONOLITH_RESIDENT_CORPUS=str(CORPUS)) for arm, mode in spec["modes"].items()}
    expected = references(spec)
    with (out / "events.jsonl").open("x", buffering=1) as log:
        def emit(kind, **fields):
            print(json.dumps(dict(event=kind, **fields), separators=(",", ":"), allow_nan=False), file=log)

        def observe():
            m = memory()
            if m["free_percent"] < spec["limits"]["min_free_percent"]:
                emit("memory_stop", memory=m)
                raise ValueError(f"host free memory fell below the floor: {m}")
            return m

        emit("start", inputs=inputs(), sources=manifest, binary=sha(binary), assets=entry["files"], cpu=spec["cpu"],
             go=spec["go"], modes=spec["modes"], memory=observe())
        micro = spec["projection_probe"]
        for index, order in enumerate(micro["orders"]):
            for arm in order:
                output = subprocess.check_output([binary, "-test.run=^$", "-test.bench=^BenchmarkAttentionQ4$",
                                                  f"-test.benchtime={micro['iterations']}x", "-test.benchmem"],
                                                 env=modes[arm], text=True, timeout=90)
                emit("projection", round=index, arm=arm, output=output)
        for wave, settings in enumerate(spec["waves"]):
            with ExitStack() as stack:
                workers = {}
                for arm in settings["load"]:
                    diagnostic = stack.enter_context((out / f"worker-{wave}-{arm}.log").open("xb"))
                    worker = Worker(binary, modes[arm], diagnostic)
                    stack.callback(worker.stop)
                    workers[arm] = worker
                    ready = worker.receive(240)
                    emit("ready", wave=wave, arm=arm, ready=ready, memory=observe())
                    layers = ready["ready"]["config"]["layers"]
                    attention = 4 * layers if arm == "B" else 0
                    if ready["ready"]["weight_format"] != spec["weights"] or ready["routing"] != {
                            "attention": attention, "ffn": 3*layers, "total": attention + 3*layers}:
                        raise ValueError("unexpected projection selection or format")
                for sessions in settings["sessions"]:
                    print(f"wave {wave+1}, {sessions} session(s)", flush=True)
                    case = dict(sessions=sessions, prefix=spec["prefix"], kv=spec["kv"])
                    for arm in settings["load"]:
                        warm = workers[arm].ask("prepare", case, seconds=240)
                        emit("warm", wave=wave, sessions=sessions, arm=arm, result=warm, memory=observe())
                        if warm != expected[sessions]:
                            raise ValueError("prefix or warm decode differs from the previous release")
                    for index, order in enumerate(settings["orders"]):
                        for label in (order if sessions == 1 else order[::-1]):
                            sample = workers[label.upper()].ask("decode", case)
                            emit("sample", wave=wave, sessions=sessions, round=index, label=label, sample=sample)
                            if sample["Signature"] != expected[sessions]["decode"] or len(sample["Ns"]) != spec["steps"]:
                                raise ValueError("decode differs from the previous release")
                        emit("round_end", wave=wave, sessions=sessions, round=index, memory=observe())
                for arm, worker in workers.items():
                    rss = worker.rss_kib()
                    if worker.ask("quit") != {"stopped": True} or worker.proc.wait(10) != 0:
                        raise ValueError("unclean probe exit")
                    emit("stopped", wave=wave, arm=arm, rss_kib=rss)
        emit("complete", memory=observe())


if __name__ == "__main__":
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("model", type=Path)
    cli.add_argument("output", type=Path)
    args = cli.parse_args()
    run(args.model.resolve(), args.output.resolve())
