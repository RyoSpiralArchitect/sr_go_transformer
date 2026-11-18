#!/bin/sh
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
set -eu

record=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
timing=$(CDPATH='' cd -- "$1" && pwd)
mkdir -- "$2"
out=$(CDPATH='' cd -- "$2" && pwd)
cd "$timing"
shasum -a 256 -c build.sha256
cp go.mod go.sum monolith.go generated_test.go probe_test.go runtime_probe_test.go "$out/"
cp "$record/long_test.go.txt" "$out/long_test.go"
cd "$out"
export GOENV=off GOWORK=off GOFLAGS='' GOTOOLCHAIN=local GOMAXPROCS=4 GOPROXY=off GOSUMDB=off
test "$(go version)" = 'go version go1.27.1 darwin/arm64'
go test -race -count=1 -run '^TestUpWriteback(LongAttention|Exact)$' -timeout=2m -v
