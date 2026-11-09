// Copyright 2026 RyoSpiralArchitect
// SPDX-License-Identifier: Apache-2.0

package main

// Frozen pre-candidate output loop from aeb74a5.
func baselineQ4OutputRange(job *fp32Kernel, lo, hi int) {
	y, x, w, n := job.y, job.x, job.w, job.n
	in, out := w.Cols, w.Rows
	groups, tiles := (in+q8Block-1)/q8Block, (out+31)/32
	for task := lo; task < hi; task++ {
		r, o0 := (task/tiles)*4, (task%tiles)*32
		for o := o0; o < min(o0+32, out); o++ {
			wr := w.Q4.Values[o*((in+1)/2) : (o+1)*((in+1)/2)]
			scales := w.Q4.Scales[o*groups : (o+1)*groups]
			if r+4 <= n {
				x0, x1 := x[r*in:(r+1)*in], x[(r+1)*in:(r+2)*in]
				x2, x3 := x[(r+2)*in:(r+3)*in], x[(r+3)*in:(r+4)*in]
				var s0, s1, s2, s3 float32
				for g, scale := range scales {
					var a0, b0, c0, d0, a1, b1, c1, d1, a2, b2, c2, d2, a3, b3, c3, d3 float32
					j, end := g*q8Block, min((g+1)*q8Block, in)
					for ; j+4 <= end; j += 4 {
						v0, v1, v2, v3 := q4Pairs[wr[j/2]][0], q4Pairs[wr[j/2]][1], q4Pairs[wr[j/2+1]][0], q4Pairs[wr[j/2+1]][1]
						a0 += x0[j] * v0
						b0 += x0[j+1] * v1
						c0 += x0[j+2] * v2
						d0 += x0[j+3] * v3
						a1 += x1[j] * v0
						b1 += x1[j+1] * v1
						c1 += x1[j+2] * v2
						d1 += x1[j+3] * v3
						a2 += x2[j] * v0
						b2 += x2[j+1] * v1
						c2 += x2[j+2] * v2
						d2 += x2[j+3] * v3
						a3 += x3[j] * v0
						b3 += x3[j+1] * v1
						c3 += x3[j+2] * v2
						d3 += x3[j+3] * v3
					}
					p0, p1, p2, p3 := (a0+b0)+(c0+d0), (a1+b1)+(c1+d1), (a2+b2)+(c2+d2), (a3+b3)+(c3+d3)
					for ; j < end; j++ {
						v := q4Pairs[wr[(j)/2]][(j)%2]
						p0 += x0[j] * v
						p1 += x1[j] * v
						p2 += x2[j] * v
						p3 += x3[j] * v
					}
					s0 += p0 * scale
					s1 += p1 * scale
					s2 += p2 * scale
					s3 += p3 * scale
				}
				y[r*out+o], y[(r+1)*out+o] = s0, s1
				y[(r+2)*out+o], y[(r+3)*out+o] = s2, s3
			} else {
				row := r
				if row+2 <= n {
					x0, x1 := x[row*in:(row+1)*in], x[(row+1)*in:(row+2)*in]
					var s0, s1 float32
					for g, scale := range scales {
						j, end := g*q8Block, min((g+1)*q8Block, in)
						if end-j == 64 {
							p0, p1 := dotQ4PairBlock64((*[64]float32)(x0[j:end]), (*[64]float32)(x1[j:end]), (*[32]byte)(wr[j/2:end/2]))
							s0 += p0 * scale
							s1 += p1 * scale
							continue
						}
						var a0, b0, c0, d0, a1, b1, c1, d1 float32
						for ; j+4 <= end; j += 4 {
							v0, v1 := q4Pairs[wr[j/2]][0], q4Pairs[wr[j/2]][1]
							v2, v3 := q4Pairs[wr[j/2+1]][0], q4Pairs[wr[j/2+1]][1]
							a0 += x0[j] * v0
							b0 += x0[j+1] * v1
							c0 += x0[j+2] * v2
							d0 += x0[j+3] * v3
							a1 += x1[j] * v0
							b1 += x1[j+1] * v1
							c1 += x1[j+2] * v2
							d1 += x1[j+3] * v3
						}
						p0, p1 := (a0+b0)+(c0+d0), (a1+b1)+(c1+d1)
						for ; j < end; j++ {
							v := q4Pairs[wr[j/2]][j%2]
							p0 += x0[j] * v
							p1 += x1[j] * v
						}
						s0 += p0 * scale
						s1 += p1 * scale
					}
					y[row*out+o], y[(row+1)*out+o] = s0, s1
					row += 2
				}
				for ; row < min(r+4, n); row++ {
					xr := x[row*in : (row+1)*in]
					var sum float32
					for g, scale := range scales {
						j, end := g*q8Block, min((g+1)*q8Block, in)
						if end-j == 64 {
							// Safe array views check the complete block once, without copying.
							sum += dotQ4Block64((*[64]float32)(xr[j:end]), (*[32]byte)(wr[j/2:end/2])) * scale
							continue
						}
						var a, b, c, d float32
						for ; j+4 <= end; j += 4 {
							v0, v1 := q4Pairs[wr[j/2]][0], q4Pairs[wr[j/2]][1]
							v2, v3 := q4Pairs[wr[j/2+1]][0], q4Pairs[wr[j/2+1]][1]
							a += xr[j] * v0
							b += xr[j+1] * v1
							c += xr[j+2] * v2
							d += xr[j+3] * v3
						}
						part := (a + b) + (c + d)
						for ; j < end; j++ {
							part += xr[j] * q4Pairs[wr[(j)/2]][(j)%2]
						}
						sum += part * scale
					}
					y[row*out+o] = sum
				}
			}
		}
	}
}
