#!/bin/sh
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
set -eu

record=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
experiment=$(CDPATH='' cd -- "$1" && pwd)
mkdir -- "$2"
out=$(CDPATH='' cd -- "$2" && pwd)
cp "$experiment/build/candidate/go.mod" "$experiment/build/candidate/go.sum" \
    "$experiment/build/candidate/monolith.go" "$out/"
cp "$record/compat_test.go.txt" "$out/compat_test.go"
export GOENV=off GOWORK=off GOFLAGS='' GOTOOLCHAIN=local GOMAXPROCS=4 GOPROXY=off GOSUMDB=off PYTHONDONTWRITEBYTECODE=1
test "$(go version)" = 'go version go1.27.1 darwin/arm64'
cd "$out"
test "$(shasum -a 256 monolith.go | cut -d' ' -f1)" = fa08aeeac256512f549bac77f6edf1c73d5fc1961128383c012f480cfc542eac
test "$(shasum -a 256 "$experiment/build/baseline/monolith.go" | cut -d' ' -f1)" = 553feda2ba5630c2ba5c6683141d677c21045172cd9a59ae30f447893ab69342
python3 -S "$record/long.py" "$experiment/build/baseline/monolith.go" "$out"
gofmt -w *_test.go
go test -race -count=1 -run '^TestSwiGLULive(Job|Fallback|LongAttention)$' -timeout=2m -v > exact.log 2>&1
cat exact.log
shasum -a 256 go.mod go.sum monolith.go *_test.go > build.sha256
