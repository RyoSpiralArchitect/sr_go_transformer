#!/bin/sh
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
set -eu
record=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
frozen=$(CDPATH='' cd -- "$1" && pwd)
mkdir -- "$2"
out=$(CDPATH='' cd -- "$2" && pwd)
cd "$frozen"
shasum -a 256 -c source.sha256
cp go.mod go.sum monolith.go kernels_test.go probe_test.go "$out/"
cd "$out"
cp "$record/barrier_test.go.txt" barrier_test.go
export GOENV=off GOWORK=off GOFLAGS='' GOTOOLCHAIN=local GOMAXPROCS=4 GOPROXY=off GOSUMDB=off
test "$(go version)" = 'go version go1.27.1 darwin/arm64'
test "$(sysctl -n machdep.cpu.brand_string)" = 'Apple M4'
go test -race -count=1 -run '^TestGateUpWaveExact$' -timeout=30s -v > exact.log 2>&1
CGO_ENABLED=0 go test -c -trimpath -o waves.test .
shasum -a 256 go.mod go.sum monolith.go kernels_test.go probe_test.go barrier_test.go waves.test > source.sha256
MONOLITH_WAVE_OUT="$out/waves.jsonl" ./waves.test -test.run='^TestGateUpWaveTiming$' -test.timeout=3m
