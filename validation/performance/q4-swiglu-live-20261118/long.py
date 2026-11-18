#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Reuse the pinned Up-borrowing fixture against the measured candidate."""

import argparse
from pathlib import Path

from variant import RECORD, once


def long_test():
    src = (RECORD.parent/"q4-up-writeback-20261118/long_test.go.txt").read_text()
    src = once(src, "func TestUpWritebackLongAttention(", "func TestSwiGLULiveLongAttention(")
    src = src.replace("sameUpBits", "sameSwiGLULiveBits")
    src = src.replace("m.prefillWritebackProbe(", "m.prefillSelected(")
    src = src.replace("m.prefillSelected(context.Background(), want,", "m.swigluReferencePrefill(context.Background(), want,")
    src = once(src, "\t\t\t\t\tpoisonUp(local.U)\n", "")
    a = src.index("\t\t\t\t\tif workers == 4 {")
    b = src.index("\t\t\t\t\tt.Logf(", a)
    return src[:a] + """					if (local.upFn != nil) != (workers == 4) || local.upWeight != nil {
						t.Fatal("unexpected dispatch or live weight reference")
					}
					if !sameSwiGLULiveBits(ref.U, local.U) || !sameSwiGLULiveBits(ref.G, local.G) {
						t.Fatal("preserved Up or activated output differs after shared attention")
					}
""" + src[b:] + """
func sameSwiGLULiveBits(a,b []float32) bool {
	if len(a) != len(b) { return false }
	for i,x := range a {
		if math.Float32bits(x) != math.Float32bits(b[i]) { return false }
	}
	return true
}
"""


def reference(src):
    start = src.index("func (m *Model) prefillSelected(")
    end = src.index("\nfunc (m *Model) Step(", start)
    return ('package main\n\nimport ("context";"errors";"math";"runtime";"runtime/trace")\n\n'
            + once(src[start:end], ") prefillSelected(", ") swigluReferencePrefill("))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("baseline", type=Path)
    p.add_argument("output", type=Path)
    args = p.parse_args()
    (args.output/"reference_test.go").write_text(reference(args.baseline.read_text()))
    (args.output/"long_test.go").write_text(long_test())


if __name__ == "__main__":
    main()
