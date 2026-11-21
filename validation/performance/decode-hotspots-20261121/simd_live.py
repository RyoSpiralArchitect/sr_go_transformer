#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Run the SIMD FFN experiment on the same resident Llama checkpoint."""

import argparse
import json
from pathlib import Path
import platform
import re
import subprocess

from instrument import once
from run import HERE, ROOT, isolated_go_environment, read_journal, run_measured, sha, stopped
from simd import kernel

DRIVER = """// This job belongs to a single trajectory. The owner clears it
// only after all borrowed output ranges have joined.
type simdFFN struct {
	job fp32Kernel
	fn func(int,int)
	calls int
}

func (p *simdFFN) project(e *kernelExecutor,y,x []float32,w *Param,n int) {
	if runtime.GOOS != "darwin" || runtime.GOARCH != "arm64" || n != 2 ||
		e == nil || w.Q4 == nil || w.Cols%64 != 0 || q8NeedsWideSum(x[:n*w.Cols]) {
		linearIntoWithExecutor(e,y,x,w,n)
		return
	}
	if p.fn == nil {
		p.fn = func(lo,hi int) { simdQ4Range(&p.job,lo,hi) }
	}
	p.job = fp32Kernel{x:x,y:y,w:w,n:n}
	e.parallel((w.Rows+31)/32,n*w.Cols*w.Rows,p.fn)
	p.job = fp32Kernel{}
	p.calls++
}
"""


def ffn_forward(src):
    a = src.index("func (m *Model) prefillSelected(")
    b = src.index("\nfunc (m *Model) Step(",a)
    s = once(src[a:b], "prefillSelected(ctx", "ffnSIMDPrefill(ctx")
    s = once(s, "wantLogits []bool)", "wantLogits []bool, ffn *simdFFN)")
    for dst, inp, param in (("G","N","Gate"),("U","N","Up"),("Q","G","Down")):
        args = f"executor, w.{dst}, w.{inp}, b.{param}, n)"
        s = once(s, "linearIntoWithExecutor("+args, "ffn.project("+args)
    return """package main

import ("context";"errors";"math";"runtime";"runtime/trace")

""" + DRIVER + s


def ffn_replay(src):
    a = src.index("func TestHFContextSweep(")
    s = src[:a]
    for name in ("encoding/json","reflect","runtime","strconv","strings","testing"):
        s = once(s, f'\t"{name}"\n', "")
    s = once(s, 'type contextSweepDecode struct {','''type contextSweepDecode struct {
	SIMDCalls int `json:"simd_calls"`''')
    s = once(s, "(r contextSweepDecode, err error) {\n", """(r contextSweepDecode, err error) {
	ffn, _ := ctx.Value(simdLiveKey{}).(*simdFFN)
""")
    s = once(s, "logits, err = m.prefillBorrowed(ctx, caches, chunks, e, w)", """if ffn == nil {
					logits, err = m.prefillBorrowed(ctx, caches, chunks, e, w)
				} else {
					logits, err = m.ffnSIMDPrefill(ctx, caches, chunks, e, w, nil, ffn)
				}""")
    return once(s, "\tr.Workspace = w.floatBytes()", """	if ffn != nil {
		if ffn.job.x != nil || ffn.job.y != nil || ffn.job.w != nil || ffn.job.n != 0 {
			return r,fmt.Errorf("worker kept borrowed job")
		}
		r.SIMDCalls = ffn.calls
	}
	r.Workspace = w.floatBytes()""")


def ffn_harness(src,spec):
    a = src.index("type hotspotStage int")
    b = src.index("func hotspotExact(")
    s = src[:a] + """type simdLiveKey struct{}

type hotspotReplay struct {
	Round int `json:"round"`
	Arm string `json:"arm"`
	Decode contextSweepDecode `json:"decode"`
}

func hotspotReplayOne(ctx context.Context,m *Model,e *kernelExecutor,w *decodeWorkspace,caches []*KVCache,first []float32,rnd int,arm string) (hotspotReplay,error) {
	expected := 0
	if arm == "simd" || arm == "simd_control" {
		ctx = context.WithValue(ctx,simdLiveKey{},&simdFFN{})
		if len(caches) == 2 {
			expected = 3*contextSweepSteps*len(m.Blocks)
		}
	}
	r,err := runContextSweepDecode(ctx,m,e,w,caches,first,"")
	if err == nil && r.SIMDCalls != expected {
		err = fmt.Errorf("got %d SIMD FFN dispatches, expected %d",r.SIMDCalls,expected)
	}
	return hotspotReplay{Round:rnd,Arm:arm,Decode:r},err
}

""" + src[b:]
    a = s.index("// The two ordinary labels")
    b = s.index("func TestHFDecodeHotspots(",a)
    order = "\n".join("\t{"+",".join(json.dumps(x) for x in row)+"}," for row in spec["order"])
    s = s[:a]+"var hotspotOrders = [...][4]string{\n"+order+"\n}\n\n"+s[b:]
    a = s.index("\t\t\tprofileName :=")
    b = s.index("\t\t\tfor _, c := range caches",a)
    s = s[:a]+s[b:]
    s = once(s,"paired round=%d/6","paired round=%d/8")
    s = once(s,"func TestHFDecodeHotspots(","func TestHFQ4SIMDLive(")
    return s.replace("MONOLITH_HOTSPOT_","MONOLITH_SIMD_LIVE_")


def memory():
    raw = subprocess.check_output(["/usr/bin/memory_pressure","-Q"],text=True,timeout=15)
    vms = subprocess.check_output(["/usr/bin/vm_stat"],text=True,timeout=15)
    return dict(free_percent=int(re.search(r"memory free percentage:\s*(\d+)%",raw)[1]),
                swapouts=int(re.search(r"^Swapouts:\s+(\d+)\.",vms,re.M)[1]))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model",type=Path,required=True)
    parser.add_argument("--output",type=Path,required=True)
    args = parser.parse_args()
    model,out = args.model.resolve(),args.output.resolve()
    spec = json.loads((HERE/"live-protocol.json").read_text())
    parent = json.loads((HERE/spec["parent"]).read_text())
    if (platform.system(),platform.machine()) != ("Darwin","arm64") or subprocess.check_output(
        ["/usr/sbin/sysctl","-n","machdep.cpu.brand_string"],text=True,timeout=10).strip() != parent["cpu"]:
        raise ValueError("use the frozen Apple Silicon host")
    env = dict(isolated_go_environment(),GOEXPERIMENT=spec["goexperiment"])
    go = Path(subprocess.check_output([ROOT/"scripts/go.sh","env","GOROOT"],env=env,text=True,timeout=20).strip())/"bin/go"
    version = subprocess.check_output([go,"version"],env=dict(env,GOEXPERIMENT=""),text=True,timeout=10).strip()
    if version != parent["go"]:
        raise ValueError("use the frozen Go version")

    catalog = ROOT/"validation/hf/model-profiles.json"
    corpus = ROOT/"validation/quality/corpus.json"
    entry = next(x for x in json.loads(catalog.read_text())["models"] if x["id"]==parent["model_id"])
    if entry["revision"]!=parent["revision"]:
        raise ValueError("unexpected checkpoint revision")
    assets = {model/f:h for f,h in entry["files"].items()}
    runtime = ROOT/"cmd/monolith/monolith.go"
    sweep = ROOT/"cmd/monolith/context_sweep_perf_test.go"
    digest = ROOT/"cmd/monolith/inference_perf_test.go"

    def verify(items):
        for p,h in items.items():
            if sha(p)!=h:
                raise ValueError(f"input changed: {p.name}")

    verify(assets | {runtime:parent["runtime_sha256"]})
    harness = HERE/"hotspots_test.go.txt"
    source = runtime.read_text()
    inputs = {p:sha(p) for p in (runtime,sweep,digest,catalog,corpus,HERE/"simd.py",harness,
              HERE/"instrument.py",HERE/spec["parent"],HERE/"live-protocol.json",Path(__file__).resolve(),
              HERE/"run.py",ROOT/"scripts/go.sh",ROOT/"scripts/compare_inference.py",
              ROOT/"scripts/quant_quality.py",ROOT/"scripts/measure_context_sweep.py",ROOT/"go.mod",ROOT/"go.sum")}
    build = out/"build"
    out.mkdir(parents=True,exist_ok=False)
    build.mkdir()
    for p in (runtime,digest,ROOT/"go.mod",ROOT/"go.sum"):
        (build/p.name).write_bytes(p.read_bytes())
    (build/"ffn_test.go").write_text(ffn_forward(source))
    (build/"kernel_test.go").write_text(kernel(source))
    (build/"replay_test.go").write_text(ffn_replay(sweep.read_text()))
    (build/"resident_test.go").write_text(ffn_harness(harness.read_text(),spec))
    subprocess.run([go.with_name("gofmt"),"-w",*build.glob("*_test.go")],timeout=30,check=True)
    sources={p:sha(p) for p in build.iterdir()}
    binary=build/"simd-live.test"
    with (out/"build.log").open("xb") as f:
        subprocess.run([go,"test","-c","-trimpath","-o",binary,"."],cwd=build,env=env,
                       stdout=f,stderr=subprocess.STDOUT,timeout=120,check=True)
    bsha=sha(binary)
    before=memory()
    if before["free_percent"] < spec["gate"]["min_memory_free_percent"]:
        raise ValueError("not enough free memory to start")
    env.update(MONOLITH_SIMD_LIVE_MODEL=str(model),MONOLITH_SIMD_LIVE_OUTPUT=str(out),MONOLITH_SIMD_LIVE_CORPUS=str(corpus))
    print("Beginning resident SIMD model diagnostic",flush=True)
    error=None
    with (out/"probe.log").open("xb") as log:
        try:
            run_measured([binary,"-test.run=^TestHFQ4SIMDLive$","-test.v","-test.timeout=12m"],cwd=build,env=env,
                         stdout=log,stderr=subprocess.STDOUT,timeout=spec["budget_seconds"],outcome_path=out/"resources.json")
        except (subprocess.CalledProcessError,subprocess.TimeoutExpired) as exc:
            error=stopped(exc)
    after=memory()
    raw=out/"events.jsonl"
    events,journal_error=read_journal(raw)
    verify(inputs|sources|assets|{binary:bsha})
    receipt=dict(cpu=parent["cpu"],go=version,goexperiment=spec["goexperiment"],revision=entry["revision"],
                 assets=entry["files"],inputs={str(p.relative_to(ROOT)):h for p,h in inputs.items()},
                 sources={p.name:h for p,h in sources.items()},binary_sha256=bsha,memory=[before,after],
                 complete=not error and not journal_error and bool(events) and events[-1]["event"]=="complete",
                 journal_error=journal_error,exit_error=error,journal_sha256=sha(raw) if raw.is_file() else None,
                 resources=json.loads((out/"resources.json").read_text()))
    (out/"receipt.json").write_text(json.dumps(receipt,indent=2,allow_nan=False)+"\n")
    if not receipt["complete"]:
        raise SystemExit("incomplete model diagnostic; preserved the journal")
    print("Resident SIMD comparison complete",flush=True)


if __name__=="__main__":
    main()
