#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Build and run a read-only offline profile of the current decode path."""

import argparse
import json
from pathlib import Path
import platform
import subprocess
import sys

from instrument import forward, replay

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sys.path.insert(0, str(ROOT/"scripts"))
from compare_inference import isolated_go_environment
from quant_quality import run_measured, sha
from measure_context_sweep import read_journal


def stopped(exc):
    return dict(type=type(exc).__name__, returncode=getattr(exc,"returncode",None),
                timeout_seconds=getattr(exc,"timeout",None))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--model", type=Path)
    p.add_argument("--output",type=Path,required=True)
    p.add_argument("--build-only",action="store_true")
    args = p.parse_args()
    if not args.build_only and not args.model:
        p.error("--model is required for a live run")
    spec = json.loads((HERE/"protocol.json").read_text())
    if (platform.system(),platform.machine()) != ("Darwin","arm64") or subprocess.check_output(
            ["/usr/sbin/sysctl","-n","machdep.cpu.brand_string"],text=True,timeout=10).strip() != spec["cpu"]:
        raise ValueError("use the frozen Apple Silicon platform")
    env = isolated_go_environment()
    go = Path(subprocess.check_output([ROOT/"scripts/go.sh","env","GOROOT"], env=env, text=True, timeout=20).strip())/"bin/go"
    if subprocess.check_output([go,"version"],env=env,text=True,timeout=10).strip() != spec["go"]:
        raise ValueError("use the frozen Go version")
    out = args.output.resolve()
    model = args.model.resolve() if args.model else None
    catalog = ROOT/"validation/hf/model-profiles.json"
    corpus = ROOT/"validation/quality/corpus.json"
    entry = next(x for x in json.loads(catalog.read_text())["models"] if x["id"] == spec["model_id"])
    if entry["revision"] != spec["revision"]:
        raise ValueError("model revision mismatch")

    def verify(items):
        for f,want in items.items():
            if sha(f) != want:
                raise ValueError(f"source or asset changed: {f.name}")

    assets = {model/f:h for f,h in entry["files"].items()} if model else {}
    verify(assets)
    source = ROOT/"cmd/monolith/monolith.go"
    verify({source:spec["runtime_sha256"]})
    sweep = ROOT/"cmd/monolith/context_sweep_perf_test.go"
    digest = ROOT/"cmd/monolith/inference_perf_test.go"
    paths = [source,sweep,digest,catalog,corpus,ROOT/"go.mod",ROOT/"go.sum",
             ROOT/"scripts/quant_quality.py",ROOT/"scripts/compare_inference.py",ROOT/"scripts/measure_context_sweep.py",
             ROOT/"scripts/go.sh",HERE/"hotspots_test.go.txt",HERE/"instrument.py",HERE/"protocol.json",Path(__file__).resolve()]
    inputs = {x:sha(x) for x in paths}
    out.mkdir(parents=True,exist_ok=False)
    build = out/"build"
    build.mkdir()
    for src in (source,digest,ROOT/"go.mod",ROOT/"go.sum"):
        (build/src.name).write_bytes(src.read_bytes())
    (build/"timed_forward_test.go").write_text(forward(source.read_text()))
    (build/"replay_test.go").write_text(replay(sweep.read_text()))
    (build/"hotspots_test.go").write_bytes((HERE/"hotspots_test.go.txt").read_bytes())
    subprocess.run([go.with_name("gofmt"),"-w",*sorted(build.glob("*_test.go"))],check=True,timeout=30)
    staged = {x:sha(x) for x in build.iterdir()}
    with (out/"exact.log").open("xb") as log:
        subprocess.run([go,"test","-race","-count=1","-run","^TestDecodeHotspotFixture$","-timeout=30s","-v","."],
                       env=dict(env,CGO_ENABLED="1"),cwd=build,stdout=log,stderr=subprocess.STDOUT,
                       check=True,timeout=60)
    binary = build/"hotspot.test"
    with (out/"build.log").open("xb") as log:
        subprocess.run([go,"test","-c","-trimpath","-o",binary,"."],env=env,cwd=build,stdout=log,stderr=subprocess.STDOUT,
                       check=True,timeout=120)
    executable = sha(binary)
    receipt = dict(baseline=spec["baseline"],cpu=spec["cpu"],go=spec["go"],model=entry["repo"],revision=entry["revision"],
                   assets=entry["files"],inputs={str(x.relative_to(ROOT)):v for x,v in inputs.items()},
                   staged={x.name:v for x,v in staged.items()},binary_sha256=executable,
                   exact_fixture_sha256=sha(out/"exact.log"))
    if args.build_only:
        verify(inputs | staged | {binary:executable})
        (out/"receipt.json").write_text(json.dumps(receipt,indent=2)+"\n")
        return
    env.update(MONOLITH_HOTSPOT_MODEL=str(model),MONOLITH_HOTSPOT_OUTPUT=str(out),MONOLITH_HOTSPOT_CORPUS=str(corpus))
    print("Exactness fixture passed; beginning pinned model profile",flush=True)
    error = None
    with (out/"probe.log").open("xb") as log:
        try:
            receipt["resources"] = run_measured([binary,"-test.run=^TestHFDecodeHotspots$","-test.v","-test.timeout=12m"],
                                               env=env,cwd=build,stdout=log,stderr=subprocess.STDOUT,
                                               timeout=spec["budget_seconds"],outcome_path=out/"resources.json")
        except (subprocess.CalledProcessError,subprocess.TimeoutExpired) as exc:
            error = stopped(exc)
    journal = out/"events.jsonl"
    rows, read_error = read_journal(journal)
    receipt.update(exit_error=error,journal_error=read_error,journal_sha256=sha(journal) if journal.is_file() else None,
                   complete=not error and not read_error and bool(rows) and rows[-1]["event"]=="complete",
                   profiles={})
    for e in rows:
        if e["event"] != "profile":
            continue
        path = out/e["file"]
        dest = path.with_suffix(".txt")
        with dest.open("xb") as log:
            status = subprocess.run([go,"tool","pprof","-top","-nodecount=20","-unit=milliseconds",binary,path],
                                    env=env,cwd=build,stdout=log,stderr=subprocess.STDOUT,timeout=45).returncode
        receipt["profiles"][path.name] = dict(raw_sha256=sha(path),text_sha256=sha(dest),status=status)
    verify(inputs | staged | assets | {binary:executable})
    with (out/"receipt.json").open("x") as file:
        json.dump(receipt,file,indent=2,allow_nan=False)
        file.write("\n")
    if not receipt["complete"] or any(p["status"] for p in receipt["profiles"].values()):
        raise SystemExit("incomplete profile; preserved the journal")
    print("Pinned model profile complete",flush=True)


if __name__ == "__main__":
    main()
