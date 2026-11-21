#!/bin/sh
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
set -eu

record=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
root=$(git -C "$record" rev-parse --show-toplevel)
mkdir -- "$1"
out=$(CDPATH='' cd -- "$1" && pwd)
cd "$out"
export GOENV=off GOWORK=off GOFLAGS='' GOTOOLCHAIN=local GOMAXPROCS=4 GOPROXY=off GOSUMDB=off
test "$(go version)" = 'go version go1.27.1 darwin/arm64'
test "$(sysctl -n machdep.cpu.brand_string)" = 'Apple M4'
for f in go.mod go.sum cmd/monolith/monolith.go; do
  git -C "$root" show 68810f7a59d85944575d4a5fa3100e85d1ca8789:"$f" > "$(basename -- "$f")"
done
test "$(shasum -a 256 monolith.go | cut -d' ' -f1)" = 553feda2ba5630c2ba5c6683141d677c21045172cd9a59ae30f447893ab69342
cp "$record/probe_test.go.txt" probe_test.go
test -z "$(gofmt -l *.go)"
go test -race -run '^TestSwiGLUPlacement(Exact|Dispatch)$' -count=1 -timeout=45s -v > exact.log 2>&1
CGO_ENABLED=0 go test -c -trimpath -o probe.test .
shasum -a 256 go.mod go.sum monolith.go probe_test.go probe.test > build.sha256
shasum -a 256 "$record/probe_test.go.txt" "$record/protocol.json" "$record/run.sh" > inputs.sha256
for b in 0 1; do
  MONOLITH_SWIGLU_BLOCK="$b" MONOLITH_SWIGLU_OUT="$out/block-$b.jsonl" \
    ./probe.test -test.run='^TestSwiGLUPlacementTiming$' -test.timeout=4m
done
shasum -a 256 -c build.sha256
shasum -a 256 -c inputs.sha256 > /dev/null
