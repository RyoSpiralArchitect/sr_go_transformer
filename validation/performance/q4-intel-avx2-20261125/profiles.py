#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Export portable profiles and verify the full decoded stacks and sample counts."""
import argparse
from collections import Counter
import json
from pathlib import Path
import re
import subprocess

from assess import HERE, assess, probe


def export(model, run, binary, dest, go):
    result = assess(run/"events.jsonl", model)
    if probe.sha(binary) != json.loads((HERE/"build.json").read_text())["binary"]:
        raise ValueError("wrong profile executable")
    dest.mkdir(parents=True, exist_ok=True)
    def pprof(*options):
        return subprocess.check_output([go, "tool", "pprof", *options], cwd=binary.parent)

    archive = {}
    for key, expected in result["profile_sha256"].items():
        original = run/f"{key}.pprof"
        if probe.sha(original) != expected:
            raise ValueError("wrong profile input")
        published = dest/f"{model}-{key}.pb.gz"
        # Supplying the basename replaces the host-specific executable mapping.
        pprof("-proto", "-output", str(published), binary.name, original)
        if pprof("-raw", binary.name, original) != pprof("-raw", binary.name, published):
            raise ValueError("published stacks or samples differ")
        report = pprof("-top", "-flat", "-unit=ms", "-nodefraction=0", "-nodecount=0", binary.name, published).decode()
        total = int(re.search(r"Total samples = (\d+)ms", report)[1])
        flat = Counter()
        for line in report.splitlines():
            parts = line.split(maxsplit=5)
            if len(parts) == 6 and re.fullmatch(r"\d+ms", parts[0]):
                flat[parts[5].removesuffix(" (inline)")] += int(parts[0][:-2])
        if sum(flat.values()) != total or total <= 0:
            raise ValueError("incomplete flat sample counts")
        archive[key] = dict(original_sha256=expected, published_sha256=probe.sha(published), total_cpu_ms=total,
                            flat_cpu_ms=dict(flat.most_common()))
    (dest/f"{model}.json").write_text(json.dumps(archive, indent=2)+"\n")


if __name__ == "__main__":
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("model")
    for name in ("run", "binary", "destination"):
        cli.add_argument(name, type=lambda p: Path(p).resolve())
    cli.add_argument("--go", default="go")
    args = cli.parse_args()
    export(args.model, args.run, args.binary, args.destination, args.go)
