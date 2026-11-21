#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Stage a two-row, two-output Go SIMD kernel without altering the runtime."""

from pathlib import Path
import sys

from instrument import once


def kernel(text):
    # The same four ordered lanes accumulate columns modulo four. A vector
    # executes the four independent FMAs; the two-stage reduction stays fixed.
    code = """//go:build arm64 && goexperiment.simd

package main

import "simd/archsimd"

func simdQ4Block(x0,x1 *[64]float32,w0,w1 *[32]byte) (float32,float32,float32,float32) {
	var s00,s01,s10,s11 archsimd.Float32x4
"""
    for offset in (0,16):
        code += "\t{\n"
        for out in range(2):
            code += f"\t\tp{out} := archsimd.LoadUint8x16(w{out}[{offset}:{offset+16}]).BitsToInt8()\n"
            code += f"\t\tl{out},h{out} := p{out}.ShiftAllLeft(4).ShiftAllRight(4), p{out}.ShiftAllRight(4)\n"
        for half,merge in enumerate(("InterleaveLo","InterleaveHi")):
            code += "\t\t{\n"
            for out in range(2):
                code += f"\t\t\tb{out} := l{out}.{merge}(h{out})\n"
            for eight, move in enumerate(("",".HiToLo()")):
                code += "\t\t\t{\n"
                for out in range(2):
                    code += f"\t\t\t\ti{out} := b{out}{move}.ExtendLo8ToInt16()\n"
                for four, shift in enumerate(("",".HiToLo()")):
                    pos = offset*2 + half*16 + eight*8 + four*4
                    code += "\t\t\t\t{\n"
                    for out in range(2):
                        code += f"\t\t\t\t\tv{out} := i{out}{shift}.ExtendLo4ToInt32().ConvertToFloat32()\n"
                    for row in range(2):
                        code += f"\t\t\t\t\tx{row}v := archsimd.LoadFloat32x4(x{row}[{pos}:{pos+4}])\n"
                        for out in range(2):
                            name = f"s{row}{out}"
                            code += f"\t\t\t\t\t{name} = x{row}v.MulAdd(v{out}, {name})\n"
                    code += "\t\t\t\t}\n"
                code += "\t\t\t}\n"
            code += "\t\t}\n"
        code += "\t}\n"
    code += """	r0,r1 := s00.ConcatAddPairs(s01), s10.ConcatAddPairs(s11)
	out := r0.ConcatAddPairs(r1)
	return out.GetElem(0),out.GetElem(1),out.GetElem(2),out.GetElem(3)
}

"""
    a = text.index("func linearQ4TwoRowOutputPairRange(")
    b = text.index("\n}\n",a)+3
    code += once(once(text[a:b], "linearQ4TwoRowOutputPairRange(", "simdQ4Range("),
                 "dotQ4TwoRowOutputPair64(", "simdQ4Block(")
    return code


if __name__ == "__main__":
    src, dst = (Path(n) for n in sys.argv[1:])
    dst.write_text(kernel(src.read_text()))
