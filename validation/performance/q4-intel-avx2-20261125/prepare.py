#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Build one Linux probe from the pinned runtime with the shared resident fixture."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "q4-attention-neon-20261124"))
import probe


def build(go, out):
    spec = json.loads((HERE / "protocol.json").read_text())
    env = dict(probe.isolated_go_environment(), GOOS="linux", GOARCH="amd64", GOAMD64="v1")
    if probe.command(go, "version", env=env) != spec["toolchain"]:
        raise ValueError("unexpected build toolchain")
    out.mkdir(parents=True, exist_ok=False)
    src = out / "src"
    (src / probe.PACKAGE).mkdir(parents=True)
    files = probe.sources(spec)
    key = str(probe.PACKAGE / "resident_test.go")
    ready = b'"routing": attentionProbeRoutes(m)'
    op = b'case "quit":'
    if files[key].count(ready) != 1 or files[key].count(op) != 1:
        raise ValueError("unexpected resident fixture")
    files[key] = files[key].replace(ready, ready + b', "pair": q4NativePairDot != nil, "quad": q4NativeQuadDot != nil')
    profile = f'case "profile":\n reply(profileDecode(t, ctx, c, req.Sessions, {spec["profile_replays"]}))\n'
    files[key] = files[key].replace(op, profile.encode() + op)
    files[str(probe.PACKAGE / "profile_test.go")] = (HERE / "profile_test.go.txt").read_bytes()
    for name, data in files.items():
        (src / name).write_bytes(data)
    binary = out / "resident.test"
    subprocess.run([go, "test", "-c", "-trimpath", "-buildvcs=false", "-o", binary, "./cmd/monolith"],
                   cwd=src, env=env, check=True)
    inputs = [HERE / name for name in ("protocol.json", "prepare.py", "profile_test.go.txt", "measure.py")]
    inputs += [probe.ROOT / path for path in spec["models"].values()]
    inputs += [probe.CATALOG, probe.CORPUS, probe.SHARED / "run.py", probe.PROBE, Path(probe.__file__)]
    manifest = dict(runtime=spec["runtime"], toolchain=spec["toolchain"], target=spec["target"],
                    binary=probe.sha(binary), sources=probe.digests(files),
                    inputs={str(p.relative_to(probe.ROOT)): probe.sha(p) for p in inputs})
    (out / "build.json").write_text(json.dumps(manifest, indent=2) + "\n")


if __name__ == "__main__":
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("output", type=Path)
    cli.add_argument("--go", default=shutil.which("go"))
    args = cli.parse_args()
    build(args.go, args.output.resolve())
