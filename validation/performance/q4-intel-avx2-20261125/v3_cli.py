#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Compare full-vocabulary Linux v3 CLI outputs against the preceding release."""
import argparse
from array import array
import hashlib
import json
import math
import os
from pathlib import Path
import platform
import sys
import subprocess
from tempfile import TemporaryDirectory

from measure import SPEC, SWITCH, probe, references, stage
from verify_cli import build_cli

PREVIOUS = "89c5fc1839b47b3278fd0e4880102b62a1775e10"


def build(out, go):
    spec = json.loads(SPEC.read_text())
    env = dict(probe.isolated_go_environment(), GOOS="linux", GOARCH="amd64", GOAMD64="v3")
    if probe.command(go, "version", env=env) != spec["toolchain"]:
        raise ValueError("unexpected compiler")
    out.mkdir(parents=True, exist_ok=False)
    catalog = probe.pinned(spec["runtime"], probe.CATALOG.relative_to(probe.ROOT))
    builds = dict(toolchain=spec["toolchain"], target="linux/amd64/v3", catalog_sha256=hashlib.sha256(catalog).hexdigest())
    for label, ref in (("previous", PREVIOUS), ("current", spec["runtime"])):
        binary = build_cli(ref, out/label, go, env)
        binary.rename(out/label/"monolith-v3")
        builds[label] = dict(revision=ref, sha256=probe.sha(out/label/"monolith-v3"))
    (out/"v3-build.json").write_text(json.dumps(builds, indent=2)+"\n")


# Record both historical prefill chunk sizes before comparing the new modes.
CASES = (("previous","1",1), ("previous","1",2), ("current","1",2),
         ("current","all",2), ("current","all+attention",2), ("current","all+attention",1))


def compare(values, reference):
    actual_bits = memoryview(values).cast("B").cast("I")
    ref_bits = memoryview(reference).cast("B").cast("I")
    return dict(different_floats=sum(a != b for a,b in zip(actual_bits, ref_bits)),
                max_abs=max(abs(a-b) for a,b in zip(values, reference)))


def verify(rows):
    if [(r["arm"], r["mode"], r["chunk"]) for r in rows] != list(CASES):
        raise ValueError("incomplete CLI comparisons")
    if any(r["ids"] != rows[0]["ids"] for r in rows):
        raise ValueError("greedy IDs differ")
    for current, reference in ((2,1), (4,3), (5,0)):
        if rows[current]["logits_sha256"] != rows[reference]["logits_sha256"]:
            raise ValueError(f"expected exact full logits for {CASES[current]} and {CASES[reference]}")


def check(args):
    spec = json.loads(SPEC.read_text())
    builds = json.loads(args.manifest.read_text())
    if (platform.machine(), sorted(os.sched_getaffinity(0))) != ("x86_64", spec["cores"]):
        raise ValueError("unexpected architecture or affinity")
    if (builds["toolchain"], builds["target"], builds["catalog_sha256"]) != (spec["toolchain"], "linux/amd64/v3", probe.sha(probe.CATALOG)):
        raise ValueError("unexpected compiler, target or model catalog")
    for label, ref in (("previous", PREVIOUS), ("current", spec["runtime"])):
        if builds[label] != {"revision":ref, "sha256":probe.sha(getattr(args, label))}:
            raise ValueError("CLI identity differs")
    model = next(m for m in json.loads(probe.CATALOG.read_text())["models"] if m["id"] == args.model)
    ready, _ = references(probe.ROOT/spec["models"][args.model])
    ids, vocab = ready["prompts"][0][:8], ready["ready"]["config"]["vocab"]
    if sys.byteorder != "little" or array("f").itemsize != 4:
        raise ValueError("expected little-endian FP32 on Linux amd64")
    options = ["-context", "128", "-weight-mib", "8192", "-weight-format", "q4-mixed", "-kv-format", "f16",
               "-threads", "4", "-max-tokens", "4", "-ids", ",".join(map(str, ids)), "-logits"]
    previous, records = {}, []
    with args.output.open("x") as log, TemporaryDirectory(dir=args.output.parent) as work:
        stage(args.snapshot, Path(work), model["files"])
        for label, mode, chunk in CASES:
            flags = [*options, "-prefill-chunk", str(chunk)]
            env = dict(probe.isolated_go_environment(), **{SWITCH:mode})
            cmd = [getattr(args, label), "infer-hf", "-hf-model", work, *flags]
            result = json.loads(subprocess.check_output(cmd, env=env, timeout=240))
            rows = result["logits"]
            if (len(rows) != 4 or len(result["token_ids"]) != len(rows)
                    or any(len(row) != vocab or not all(map(math.isfinite, row)) for row in rows)):
                raise ValueError("incomplete or nonfinite logits")
            values = array("f", (value for row in rows for value in row))
            if label == "previous":
                previous[chunk] = values
            record = dict(model=args.model, revision=model["revision"], flags=flags, builds=builds,
                          arm=label, mode=mode, chunk=chunk, vocab=vocab, ids=result["token_ids"],
                          logits_sha256=hashlib.sha256(values).hexdigest(),
                          vs_previous={str(k):compare(values, ref) for k,ref in previous.items()})
            records.append(record)
            print(json.dumps(record), file=log, flush=True)
    verify(records)


if __name__ == "__main__":
    cli = argparse.ArgumentParser(description=__doc__)
    modes = cli.add_subparsers(dest="action", required=True)
    builder = modes.add_parser("build")
    builder.add_argument("output", type=Path)
    builder.add_argument("--go", default="go")
    checker = modes.add_parser("check")
    checker.add_argument("model", choices=json.loads(SPEC.read_text())["models"])
    for key in ("snapshot", "previous", "current", "manifest", "output"):
        checker.add_argument(key, type=lambda p: Path(p).resolve())
    args = cli.parse_args()
    if args.action == "build":
        build(args.output.resolve(), args.go)
    else:
        check(args)
