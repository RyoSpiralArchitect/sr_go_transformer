#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Rebuild the frozen executables without launching the four-model screen."""

import argparse
import json
from pathlib import Path
import platform
import subprocess

from run import PATCH, RECORD, ROOT, RUNTIME, command, isolated_go_environment, make_variant, sha


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    output = args.output.resolve()
    protocol = json.loads((RECORD/"protocol.json").read_text())
    with (RECORD/"four-process/journal.jsonl").open() as file:
        start = json.loads(file.readline())
    expected = start["inputs"]
    if any(sha(ROOT/path) != digest for path,digest in expected.items()):
        raise ValueError("use the recorded baseline and tool sources")
    env = isolated_go_environment()
    goroot = Path(command(ROOT/"scripts/go.sh", "env", "GOROOT", cwd=ROOT, env=env))
    go = goroot/"bin/go"
    if (command(go,"version",env=env) != protocol["go_version"] or
            (platform.system(),platform.machine()) != ("Darwin","arm64") or
            command("/usr/sbin/sysctl","-n","machdep.cpu.brand_string") != protocol["cpu"]):
        raise ValueError("use the recorded toolchain and host type")
    output.mkdir(parents=True, exist_ok=False)
    builds = {}
    for mode, build in start["builds"].items():
        target = output/"build"/mode
        (target/RUNTIME.parent).mkdir(parents=True)
        for path in (RUNTIME, Path("go.mod"), Path("go.sum")):
            (target/path).write_bytes((ROOT/path).read_bytes())
        make_variant(target, mode)
        for source, name in ((RECORD/"resident_test.go.txt","resident_perf_test.go"),
                             (ROOT/"cmd/monolith/inference_perf_test.go","inference_perf_test.go")):
            (target/RUNTIME.parent/name).write_bytes(source.read_bytes())
        hashes = {str(p.relative_to(target)):sha(p) for p in target.rglob("*") if p.is_file()}
        if hashes != build["sources"]:
            raise ValueError(f"{mode} sources differ from measurement")
        binary = target/"resident.test"
        subprocess.run([go,"test","-c","-trimpath","-o",binary,"./cmd/monolith"], cwd=target, env=env,
                       check=True, timeout=300)
        builds[mode] = dict(sources=hashes, binary_sha256=sha(binary))
    recipe = dict(start, builds=builds,
                  note="Build inputs reproduced locally; no models were loaded for this build receipt.")
    recipe.pop("memory",None)
    (output/"events.jsonl").write_text(json.dumps(recipe,allow_nan=False)+"\n")


if __name__ == "__main__":
    main()
