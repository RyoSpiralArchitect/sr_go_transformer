#!/bin/sh
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
set -eu
record=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
root=$(git -C "$record" rev-parse --show-toplevel)
mkdir -- "$1"
out=$(CDPATH='' cd -- "$1" && pwd)
cd "$out"
for f in go.mod go.sum cmd/monolith/monolith.go; do
  git -C "$root" show 68810f7a59d85944575d4a5fa3100e85d1ca8789:"$f" > "$(basename -- "$f")"
done
test "$(shasum -a 256 monolith.go | cut -d' ' -f1)" = 553feda2ba5630c2ba5c6683141d677c21045172cd9a59ae30f447893ab69342
cp "$record/gate_up_test.go.txt" gate_up_test.go
export GOENV=off GOWORK=off GOFLAGS='' GOTOOLCHAIN=local GOMAXPROCS=4
test "$(go version)" = 'go version go1.27.1 darwin/arm64'
test "$(sysctl -n machdep.cpu.brand_string)" = 'Apple M4'
export GOPROXY=off GOSUMDB=off
go test -race -run '^TestGateUpTileExact$' -count=1 -v > exact.log 2>&1
CGO_ENABLED=0 go test -c -trimpath -o gate-up.test .
shasum -a 256 "$record/protocol.json" go.mod go.sum monolith.go gate_up_test.go gate-up.test > sources.sha256
MONOLITH_GATE_UP_OUT="$out/samples.jsonl" ./gate-up.test -test.run='^TestGateUpTileTiming$' -test.timeout=3m
