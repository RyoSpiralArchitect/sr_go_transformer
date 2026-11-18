#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Derive the pair and shared-slot sources from the archived Q8 head."""

import argparse
import os
from pathlib import Path
import subprocess

RECORD = Path(__file__).resolve().parent
PATCH = RECORD.parent / "q8-head-composition-20261118/candidate.patch"
RUNTIME = Path("cmd/monolith/monolith.go")


def once(text, old, new):
    if text.count(old) != 1:
        raise ValueError(f"expected one source anchor: {old!r}")
    return text.replace(old, new)


def make_variant(tree, mode):
    """tree contains a clean copy of only the baseline runtime path."""
    if mode == "baseline":
        return
    if mode not in ("pair", "shared"):
        raise ValueError(f"unknown variant: {mode}")
    env = dict(os.environ, GIT_CEILING_DIRECTORIES=str(tree.parent))
    subprocess.run(["git", "apply", f"--include={RUNTIME}", "--whitespace=error-all", PATCH],
                   cwd=tree, env=env, check=True, timeout=30)
    source = tree / RUNTIME
    src = once(source.read_text(), "\tq8HeadFn  func(lo, hi int)\n", "")
    start = src.index("\t\tif e.q8HeadFn == nil {")
    end = src.index("\t\treturn\n", start)
    if mode == "pair":
        dispatch = """		job := fp32Kernel{x: x, y: y, w: w, n: rows}
		e.parallel((w.Rows+31)/32, rows*w.Cols*w.Rows, func(lo, hi int) {
			linearQ8OutputPairRange(&job, lo, hi)
		})
"""
    else:
        dispatch = """		if e.q4Fn == nil {
			e.q4Fn = e.quantizedRange
		}
		e.linear = fp32Kernel{x: x, y: y, w: w, n: rows}
		e.parallel((w.Rows+31)/32, rows*w.Cols*w.Rows, e.q4Fn)
		e.linear = fp32Kernel{}
"""
    src = src[:start] + dispatch + src[end:]
    if mode == "shared":
        src = once(src, "e.q4Fn = func(lo, hi int) { linearQ4Range(&e.linear, lo, hi) }",
                   "e.q4Fn = e.quantizedRange")
        src = once(src, "\tq4Fn      func(lo, hi int)\n",
                   "\tq4Fn      func(lo, hi int) // Shared by Q4 and the selected Q8 head.\n")
        anchor = "func linearQ4Range(job *fp32Kernel, lo, hi int) {"
        src = once(src, anchor, """// The owner's borrowed job selects a range once per worker, not once per
// output. Keep the original Q4 route on platforms without the paired head.
func (e *kernelExecutor) quantizedRange(lo, hi int) {
	if runtime.GOOS == "darwin" && runtime.GOARCH == "arm64" && e.linear.w.Q4 == nil {
		linearQ8OutputPairRange(&e.linear, lo, hi)
		return
	}
	linearQ4Range(&e.linear, lo, hi)
}

""" + anchor)
    source.write_text(src)


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("tree", type=Path)
    p.add_argument("mode", choices=("baseline", "pair", "shared"))
    args = p.parse_args()
    make_variant(args.tree.resolve(), args.mode)
