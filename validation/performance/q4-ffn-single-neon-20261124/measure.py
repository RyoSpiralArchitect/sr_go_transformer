#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Replay the single-row comparison in one resident model on Apple M4."""
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
ARCHIVE = HERE.parent / "q8-compact-head-20261118"
sys.path.insert(0, str(ARCHIVE))
from run import Worker, command, isolated_go_environment, memory, sha

PACKAGE = Path("cmd/monolith")
FIXTURE = ARCHIVE / "resident_test.go.txt"
CORPUS = ROOT / "validation/quality/corpus.json"
CATALOG = ROOT / "validation/hf/model-profiles.json"
PROTOCOL = HERE / "protocol.json"
MEASURED = "7254c73ebfbebe87fd45bd47b6340c3a20fe4a55"
# Only the manual test accepts these commands, between synchronous forwards.
SWITCH = '''
		case "quad-go", "quad-neon":
			if q4FFNPairDot == nil || !m.Blocks[0].Gate.q4FFNPair {
				t.Fatal("expected native FFN weights and two-row kernel")
			}
			if req.Op == "quad-go" {
				q4FFNQuadDot = nil
			} else {
				q4FFNQuadDot = dotQ4FFNQuadNEON
			}
			reply(map[string]bool{"quad": q4FFNQuadDot != nil, "pair": true})
'''


def pinned_blob(name):
    return subprocess.check_output(["git", "show", f"{MEASURED}:{name}"], cwd=ROOT)


def measured_sources():
    tree = command("git", "ls-tree", "-r", "--name-only", MEASURED, "--", str(PACKAGE), cwd=ROOT)
    names = ["go.mod", "go.sum", str(PACKAGE / "inference_perf_test.go")]
    names.extend(n for n in tree.splitlines() if n.endswith((".go", ".s")) and not n.endswith("_test.go"))
    sources = {n: pinned_blob(n) for n in names}
    template = pinned_blob(FIXTURE.relative_to(ROOT)).decode()
    marker = '\t\tcase "quit":'
    if template.count(marker) != 1:
        raise ValueError("resident fixture command loop changed")
    sources[str(PACKAGE / "resident_test.go")] = template.replace(marker, SWITCH + marker).encode()
    return sources


def build(out, go, env):
    (out / PACKAGE).mkdir(parents=True)
    sources = measured_sources()
    for name, data in sources.items():
        (out / name).write_bytes(data)
    binary = out / "resident.test"
    subprocess.run([go, "test", "-c", "-trimpath", "-o", binary, "./cmd/monolith"],
                   cwd=out, env=env, check=True)
    return binary, {name: hashlib.sha256(data).hexdigest() for name, data in sources.items()}


def run(model, out, observe_swap):
    spec = json.loads(PROTOCOL.read_text())
    env = isolated_go_environment(q4_ffn_neon=True)
    go = shutil.which("go", path=env["PATH"])
    if command(go, "version", env=env) != spec["go"] or command("/usr/sbin/sysctl", "-n", "machdep.cpu.brand_string") != spec["cpu"]:
        raise ValueError("host or Go version differs from protocol")
    entry = next(m for m in json.loads(CATALOG.read_text())["models"] if m["id"] == spec["model_id"])
    if entry["revision"] != spec["revision"] or any(sha(model / n) != h for n, h in entry["files"].items()):
        raise ValueError("model differs from the pinned snapshot")
    out.mkdir(parents=True, exist_ok=False)
    binary, sources = build(out / "build", go, env)
    env.update(MONOLITH_RESIDENT_MODEL=str(model), MONOLITH_RESIDENT_CORPUS=str(CORPUS))
    with ExitStack() as stack:
        log = stack.enter_context((out / "events.jsonl").open("x", buffering=1))

        def emit(kind, **values):
            print(json.dumps(dict(event=kind, **values), separators=(",", ":"), allow_nan=False), file=log)

        start = memory()
        limits = spec["limits"]

        def observe():
            m = memory()
            crossed_swap_limit = m["swapouts"] - start["swapouts"] > limits["max_new_swapout_pages"]
            if m["free_percent"] < limits["min_free_percent"] or (crossed_swap_limit and not observe_swap):
                emit("memory_stop", memory=m)
                raise ValueError(f"host memory limit crossed: {m}")
            return m

        inputs = [Path(__file__).resolve(), PROTOCOL, FIXTURE, ARCHIVE / "run.py", CORPUS, CATALOG,
                  ROOT / "scripts/compare_inference.py", ROOT / "scripts/quant_quality.py"]
        emit("start", cpu=spec["cpu"], go=spec["go"], revision=entry["revision"], assets=entry["files"], observe_swap=observe_swap,
             inputs={str(p.relative_to(ROOT)):sha(p) for p in inputs}, sources=sources, binary=sha(binary), memory=start)
        observe()
        worker = Worker(binary, env, stack.enter_context((out / "worker.log").open("xb")))
        stack.callback(worker.stop)
        ready = worker.receive(240)
        if ready["ready"]["weight_format"] != spec["weights"]:
            raise ValueError("unexpected model load plan")
        emit("ready", ready=ready, memory=observe())

        def select(label):
            native = label.upper() == "B"
            state = worker.ask("quad-neon" if native else "quad-go")
            if state != {"quad": native, "pair": True}:
                raise ValueError("kernel selection failed")

        for index, sessions in enumerate(spec["sessions"]):
            case = dict(sessions=sessions, prefix=spec["prefix"], kv=spec["kv"])
            print(f"measuring {sessions} session(s)", flush=True)
            select("A")
            warm = worker.ask("prepare", case, seconds=240)
            select("B")
            first = worker.ask("decode", case)
            emit("warm", case=case, go=warm, neon=first["Signature"], memory=observe())
            if first["Signature"] != warm["decode"]:
                raise ValueError("warm outputs differ")
            for rnd, order in enumerate(spec["orders"]):
                for label in (order if index % 2 == 0 else order[::-1]):
                    select(label)
                    sample = worker.ask("decode", case)
                    emit("sample", sessions=sessions, round=rnd, label=label, sample=sample)
                    if sample["Signature"] != warm["decode"] or len(sample["Ns"]) != spec["forwards"]:
                        raise ValueError("measured output or shape differs")
                emit("round_end", sessions=sessions, round=rnd, memory=observe())
            emit("end_case", sessions=sessions, rss_kib=worker.rss_kib())
        if worker.ask("quit") != {"stopped": True} or worker.proc.wait(10) != 0:
            raise ValueError("unclean worker exit")
        emit("complete", memory=observe())


if __name__ == "__main__":
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("model", type=Path)
    cli.add_argument("output", type=Path)
    cli.add_argument("--observe-swap", action="store_true", help="keep sampling after swapouts; the original acceptance limits still apply")
    args = cli.parse_args()
    run(args.model.resolve(), args.output.resolve(), args.observe_swap)
