"""Run the archived resident probe in two Linux processes on the same four P cores."""
import argparse
from contextlib import ExitStack
import hashlib
import json
import os
from pathlib import Path
import platform
import statistics
import subprocess

ORDERS = ("AabB", "aBAb", "BbaA", "bAaB", "BbaA", "bAaB", "aBAb", "AabB")
REV = "60a99aaf43164077157d64bf909b7b61143c6a6d"


def sha(path):
    with path.open("rb") as f:
        return hashlib.file_digest(f, "sha256").hexdigest()


def record(log, kind, **fields):
    print(json.dumps(dict(event=kind, **fields), separators=(",", ":")), file=log, flush=True)


def reply(proc, request=None):
    if request is not None:
        print(json.dumps(request), file=proc.stdin, flush=True)
    line = proc.stdout.readline()
    if not line.startswith("{"):
        raise RuntimeError(f"resident probe exited or failed: {line.strip()}")
    return json.loads(line)


def run(args):
    if platform.machine() != "x86_64" or sorted(os.sched_getaffinity(0)) != [4, 5, 6, 7]:
        raise ValueError("run on Furnace with taskset -c 4-7")
    if args.model.name != REV:
        raise ValueError("unexpected snapshot revision")
    env = dict(os.environ, GOMAXPROCS="4", HF_HUB_OFFLINE="1", MONOLITH_RESIDENT_MODEL=str(args.model),
               MONOLITH_RESIDENT_CORPUS=str(args.corpus.resolve()))
    for key in ("GOGC", "GOMEMLIMIT", "GODEBUG", "MONOLITH_Q4_FFN_AVX2", "MONOLITH_Q4_FFN_NEON"):
        env.pop(key, None)
    with args.output.open("x", buffering=1) as log, ExitStack() as stack:
        binaries = {"A": args.scalar.resolve(), "B": args.native.resolve()}
        source = next(m for m in json.loads(args.catalog.read_text())["models"] if m["revision"] == REV)
        for name, expected in source["files"].items():
            if sha(args.model/name) != expected:
                raise ValueError("unexpected snapshot asset: " + name)
        record(log, "start", cpu=next(l.split(":")[1].strip() for l in Path("/proc/cpuinfo").read_text().splitlines()
               if l.startswith("model name")), kernel=platform.release(), affinity=sorted(os.sched_getaffinity(0)),
               model=source["repo"], revision=REV, assets=source["files"], corpus_sha256=sha(args.corpus),
               binaries={k: sha(v) for k, v in binaries.items()}, sources=json.loads(args.builds.read_text()),
               runner_sha256=sha(Path(__file__)), load=os.getloadavg())
        workers, ready = {}, {}
        for arm, binary in binaries.items():
            proc = stack.enter_context(subprocess.Popen([str(binary), "-test.run=^TestHFResidentHeadPerf$",
                    "-test.timeout=25m"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True,
                    env=dict(env, MONOLITH_Q4_FFN_AVX2="1" if arm == "B" else "0")))
            stack.callback(lambda p=proc: p.kill() if p.poll() is None else None)
            workers[arm] = proc
            ready[arm] = reply(proc)
            record(log, "ready", arm=arm, result=ready[arm])
        if ready["A"] != ready["B"]:
            raise ValueError("different runtime plans or prompts")
        for sessions in (2, 1):
            case = dict(Prefix=128, Sessions=sessions, KV="f16")
            warm = {}
            for arm in ("AB" if sessions == 2 else "BA"):
                warm[arm] = reply(workers[arm], dict(Op="prepare", **case))
                record(log, "warm", sessions=sessions, arm=arm, result=warm[arm])
            if warm["A"] != warm["B"]:
                raise ValueError("different checkpoint or warm signatures")
            ratios, speeds, controls = [], {"A": [], "B": []}, {"A": [], "B": []}
            for rnd, order in enumerate(ORDERS):
                times = {}
                for label in (order if sessions == 2 else order[::-1]):
                    result = reply(workers[label.upper()], dict(Op="decode", **case))
                    record(log, "sample", sessions=sessions, round=rnd, label=label, result=result)
                    if result["Signature"] != warm["A"]["decode"] or len(result["Ns"]) != 7 or min(result["Ns"]) <= 0:
                        raise ValueError("different or incomplete decode")
                    times[label] = sum(result["Ns"])
                ratios.append(times["B"]/times["A"])
                for arm in "AB":
                    speeds[arm].append(7e9*sessions/times[arm])
                    controls[arm].append(times[arm.lower()]/times[arm])
            med = statistics.median
            stable = all(0.97 <= med(v) <= 1.03 and med([abs(x-1) for x in v]) <= .05 for v in controls.values())
            timing = med(ratios) <= (1.05 if sessions == 1 else .95) and (sessions == 1 or sum(r < 1 for r in ratios) >= 7)
            record(log, "result", sessions=sessions, ratios=ratios, controls=controls, stable=stable,
                   timing_pass=timing, median_ratio=med(ratios), median_aggregate_tps={k: med(v) for k,v in speeds.items()},
                   peak_rss_kib={k: int(next(l.split()[1] for l in Path(f"/proc/{p.pid}/status").read_text().splitlines()
                                      if l.startswith("VmHWM:"))) for k,p in workers.items()}, load=os.getloadavg())
        for proc in workers.values():
            if reply(proc, dict(Op="quit")) != {"stopped": True} or proc.wait(timeout=10):
                raise ValueError("unclean probe exit")
        record(log, "complete")


if __name__ == "__main__":
    cli = argparse.ArgumentParser(description=__doc__)
    for arg in ("scalar", "native", "model", "corpus", "catalog", "builds", "output"):
        cli.add_argument(arg, type=Path)
    run(cli.parse_args())
