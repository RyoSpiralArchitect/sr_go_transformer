#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Run the missing direct comparison, without changing the recorded screen."""

import argparse
import json
from pathlib import Path

from pairs import RECORD, run


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("--model", type=Path, required=True)
    cli.add_argument("--builds", type=Path, required=True)
    cli.add_argument("--output", type=Path, required=True)
    args = cli.parse_args()
    alternate = json.loads((RECORD/"direct.json").read_text())
    spec = json.loads((RECORD/alternate["base_protocol"]).read_text())
    spec.update(blocks=[], timebox_seconds=alternate["timebox_seconds"], direct={k:alternate[k] for k in
                ("left","right","cases","rounds","reverse")})
    run(args.model.resolve(), args.builds.resolve(), args.output.resolve(), spec)


if __name__ == "__main__":
    main()
