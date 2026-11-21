#!/bin/sh
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
set -eu
if [ "$#" -ne 2 ]; then
  printf '%s\n' "usage: $0 pair|shared NEW-DIRECTORY" >&2
  exit 2
fi
case "$1" in
  pair) shared=false ;;
  shared) shared=true ;;
  *) exit 2 ;;
esac
mode=$1
record=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
root=$(git -C "$record" rev-parse --show-toplevel)
mkdir -- "$2"
target=$(CDPATH='' cd -- "$2" && pwd)
baseline=$(python3 -S -c 'import json,sys; print(json.load(open(sys.argv[1]))["baseline"])' "$record/protocol.json")
git -C "$root" archive "$baseline" | tar -x -C "$target"
python3 -S "$record/variants.py" "$target" "$mode"
engine="cmd/monolith/monolith.go"
expected=$(python3 -S -c 'import json,sys; print(json.load(open(sys.argv[1]))["runtime_sha256"][sys.argv[2]])' "$record/protocol.json" "$mode")
cd "$target"
test "$(shasum -a 256 "$engine" | cut -d' ' -f1)" = "$expected"
cp "$record/verify_test.go.txt" cmd/monolith/q8_compact_test.go
printf '\nconst compactHeadShared = %s\n' "$shared" >> cmd/monolith/q8_compact_test.go
export GOENV=off GOWORK=off GOFLAGS='' GOTOOLCHAIN=local GOMAXPROCS=4 PYTHONDONTWRITEBYTECODE=1
gofmt -w cmd/monolith/q8_compact_test.go
test -z "$(gofmt -l .)"
go test -race -count=1 -run '^(TestCompactHeadTransitions|TestProjectionDescriptorFootprint|TestQ4Invocation.*)$' -v ./cmd/monolith
