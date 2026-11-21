#!/bin/sh
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
set -eu
record=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
root=$(git -C "$record" rev-parse --show-toplevel)
mkdir -- "$1"
out=$(CDPATH='' cd -- "$1" && pwd)
cd "$out"
export GOENV=off GOWORK=off GOFLAGS='' GOTOOLCHAIN=local GOMAXPROCS=4 GOEXPERIMENT=simd GOPROXY=off GOSUMDB=off PYTHONDONTWRITEBYTECODE=1
test "$(go version)" = 'go version go1.27.1 darwin/arm64'
test "$(sysctl -n machdep.cpu.brand_string)" = 'Apple M4'
for f in go.mod go.sum cmd/monolith/monolith.go; do
  git -C "$root" show 68810f7a59d85944575d4a5fa3100e85d1ca8789:"$f" > "$(basename -- "$f")"
done
test "$(shasum -a 256 monolith.go | cut -d' ' -f1)" = 553feda2ba5630c2ba5c6683141d677c21045172cd9a59ae30f447893ab69342
python3 -S "$record/simd.py" monolith.go kernel_test.go
cp "$record/simd_test.go.txt" simd_test.go
gofmt -w kernel_test.go
shasum -a 256 "$record/simd-protocol.json" "$record/simd.py" "$record/simd.sh" "$record/simd_test.go.txt" "$record/instrument.py" > inputs.sha256
go test -race -count=1 -run '^TestSIMDQ4(Block|Range)Exact$' -v -timeout=45s . > exact.log 2>&1
CGO_ENABLED=0 go test -c -trimpath -o simd.test .
shasum -a 256 go.mod go.sum monolith.go kernel_test.go simd_test.go simd.test > build.sha256
go tool objdump -s '[.](simdQ4Block|dotQ4TwoRowOutputPair64)$' simd.test > blocks.s
for block in 0 1; do
  MONOLITH_SIMD_BLOCK="$block" MONOLITH_SIMD_OUT="$out/simd-$block.jsonl" \
    ./simd.test -test.run='^TestSIMDQ4Timing$' -test.timeout=3m
done
shasum -a 256 -c build.sha256
shasum -a 256 -c inputs.sha256 > /dev/null
