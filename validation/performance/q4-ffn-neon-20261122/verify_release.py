#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Check the shipping binary with its switch unset and enabled on the same offline model."""
import argparse
from contextlib import ExitStack
import json
from pathlib import Path
import runpy
import shutil
import subprocess

HERE = Path(__file__).resolve().parent
PRODUCTION = "c9202a838c1646b8a1220e833bfe2739040aeb9d"
SWITCH = "MONOLITH_Q4_FFN_NEON"
runtime = runpy.run_path(str(HERE / "run.py"))
assessment = runpy.run_path(str(HERE / "assess.py"))
sha = runtime["sha"]


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("model", type=Path)
    cli.add_argument("events", type=Path)
    cli.add_argument("output", type=Path)
    args = cli.parse_args()
    model, out = args.model.resolve(), args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    events = [json.loads(line) for line in args.events.read_text().splitlines()]
    start = events[0]
    spec = json.loads((HERE / "protocol.json").read_text())
    assessment["verify_start"](start, spec)
    case = dict(prefix=128, sessions=2, kv="f16")
    warm = {e["arm"]: e["result"] for e in events if e["event"] == "warm" and e["case"] == case}
    if set(warm) != {"A", "B"} or warm["A"] != warm["B"]:
        raise ValueError("requires matching 128-token two-session reference signatures")
    env = runtime["isolated_go_environment"]()
    env.pop(SWITCH, None)
    go = shutil.which("go", path=env["PATH"])
    if not go or runtime["command"](go, "version", env=env) != spec["go"]:
        raise ValueError("use the recorded Go version")
    for path, h in start["assets"].items():
        if sha(model / path) != h:
            raise ValueError(f"unexpected model asset: {path}")

    stage = out / "package"
    probe, build = runtime["build"](stage, None, go, env)
    fixture = "cmd/monolith/resident_test.go"
    expected = {p:assessment["digest"](PRODUCTION, assessment["FIXTURE"] if p == fixture else p)
                for p in start["builds"]["B"]["sources"]}
    if build["sources"] != expected:
        raise ValueError("release package or fixture differs from its commit")
    binary = stage / "monolith"
    subprocess.run([go, "build", "-trimpath", "-o", binary, "./cmd/monolith"], cwd=stage, env=env, check=True)
    result = dict(production=PRODUCTION, go=spec["go"], model=start["repo"], revision=start["revision"],
                  reference_events_sha256=sha(args.events), build=build, cli_sha256=sha(binary), case=case, runs={})
    env.update(MONOLITH_RESIDENT_MODEL=str(model), MONOLITH_RESIDENT_CORPUS=str(runtime["CORPUS"]))
    for mode in ("default", "neon"):
        if mode == "neon":
            env[SWITCH] = "1"
        args_cli = [binary, "infer", "local", "-path", model, "-context", "128", "-weight-format", "q4-mixed",
                    "-weight-mib", "2048", "generate", "-prompt", "Hi", "-max-tokens", "3",
                    "-temperature", "0", "-seed", "19", "-json"]
        reply = json.loads(subprocess.check_output(args_cli, env=env, timeout=180))
        if reply["prompt_tokens"] != 2 or reply["token_ids"] != [11, 358, 2846]:
            raise ValueError(f"two-token CLI result differs in {mode}")
        with ExitStack() as stack:
            worker = runtime["Worker"](probe, env, stack.enter_context((out / f"{mode}.log").open("xb")))
            stack.callback(worker.stop)
            ready = worker.receive(180)
            if ready != next(e["ready"] for e in events if e["event"] == "ready" and e["arm"] == "A"):
                raise ValueError(f"load plan or prompt differs in {mode}")
            prepared = worker.ask("prepare", case, seconds=240)
            signature = worker.ask("decode", case, seconds=90)["Signature"]
            if prepared != warm["A"] or signature != warm["A"]["decode"]:
                raise ValueError(f"two-session forward differs in {mode}")
            if worker.ask("quit", seconds=10) != {"stopped": True} or worker.proc.wait(10):
                raise ValueError("unclean worker exit")
        result["runs"][mode] = dict(cli=reply, signature=signature)
        print(f"{mode}: CLI and two-session forward matched", flush=True)
    if result["runs"]["default"] != result["runs"]["neon"]:
        raise ValueError("release modes differ")
    if sha(binary) != result["cli_sha256"] or sha(probe) != build["binary_sha256"]:
        raise ValueError("release executable changed during validation")
    (out / "release.json").write_text(json.dumps(result, indent=2) + "\n")


if __name__ == "__main__":
    main()
