#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Reconstruct the uninstrumented candidate and the resident fixture."""

import argparse
from pathlib import Path

RECORD = Path(__file__).resolve().parent
ROOT = RECORD.parents[2]
RESIDENT = RECORD.parent / "q8-compact-head-20261118/resident_test.go.txt"


def once(src, old, new):
    if src.count(old) != 1:
        raise ValueError(f"unexpected source anchor: {old}")
    return src.replace(old, new, 1)


def candidate(src):
    anchor = "\tattentionFn func(lo, hi int)\n"
    src = once(src, anchor, anchor + "\tupWeight    *Param\n\tupFn        func(lo, hi int)\n")
    anchor = "type attentionKernel struct {"
    src = once(src, anchor, """// Up and its SwiGLU consumer share the ordinary Q4 output ranges. Up
// is still stored; the same workspace can lend it to KV attention.
func (w *decodeWorkspace) parallelUpSwiGLU(e *kernelExecutor, up *Param, rows int) bool {
	if runtime.GOOS != "darwin" || runtime.GOARCH != "arm64" || rows != 2 ||
		e == nil || e.workers < 2 || up.Q4 == nil || up.Cols%q8Block != 0 {
		return false
	}
	tiles, work := (up.Rows+31)/32, 2*up.Cols*up.Rows
	if tiles < 2 || work < 131072 || q8NeedsWideSum(w.N[:2*up.Cols]) {
		return false
	}
	if w.upFn == nil {
		w.upFn = w.upSwiGLURange
	}
	w.upWeight = up
	e.parallel(tiles, work, w.upFn)
	w.upWeight = nil
	return true
}

func (w *decodeWorkspace) upSwiGLURange(lo, hi int) {
	up := w.upWeight
	job := fp32Kernel{x: w.N, y: w.U, w: up, n: 2}
	linearQ4Range(&job, lo, hi)
	start, end := lo*32, min(hi*32, up.Rows)
	for row := range 2 {
		offset := row * up.Rows
		g, u := w.G[offset+start:offset+end], w.U[offset+start:offset+end]
		for i, v := range g {
			g[i] = float32(float64(v)/(1+math.Exp(-float64(v)))) * u[i]
		}
	}
}

""" + anchor)
    begin = src.index("func (m *Model) prefillSelected(")
    end = src.index("\nfunc (m *Model) Step(", begin)
    code = once(src[begin:end],
                "\t\t} else {\n\t\t\tlinearIntoWithExecutor(executor, w.U, w.N, b.Up, n)",
                "\t\t} else if !w.parallelUpSwiGLU(executor, b.Up, n) {\n\t\t\tlinearIntoWithExecutor(executor, w.U, w.N, b.Up, n)")
    return src[:begin] + code + src[end:]


def fixture(src):
    src = once(src, """	var c *residentCase
	defer func() {
		if c != nil {
			c.close()
		}
	}()""", """	type caseKey struct {
		sessions, prefix int
		kv string
	}
	cases := make(map[caseKey]*residentCase, 3)
	defer func() {
		for _, c := range cases {
			c.close()
		}
	}()""")
    src = once(src, '\t\tswitch req.Op {',
               '\t\tkey := caseKey{req.Sessions, req.Prefix, req.KV}\n\t\tswitch req.Op {')
    src = once(src, """			if c != nil {
				c.close()
				c = nil
			}
			var checkpoint residentSignature
			c, checkpoint, err = prepareResident(ctx, m, e, base, req)""",
               """			if cases[key] != nil || len(cases) == 3 {
				t.Fatal("prepare each bounded case once")
			}
			c, checkpoint, err := prepareResident(ctx, m, e, base, req)""")
    src = once(src, '\t\t\truntime.GC() // No forced collection in a measured call.',
               '\t\t\tcases[key] = c\n\t\t\truntime.GC() // No forced collection in a measured call.')
    src = once(src, '\t\tcase "prefill", "decode":\n\t\t\tif c == nil {',
               '\t\tcase "prefill", "decode":\n\t\t\tc := cases[key]\n\t\t\tif c == nil {')
    return once(src, '\t\t\tvar s residentSample',
                '\t\t\tm.kvFormat = req.KV\n\t\t\tvar s residentSample')


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("--output", type=Path, required=True)
    args = cli.parse_args()
    args.output.write_text(candidate((ROOT/"cmd/monolith/monolith.go").read_text()))


if __name__ == "__main__":
    main()
