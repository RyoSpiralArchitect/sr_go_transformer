#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Compare ordinary offline binaries on GPT-2 and Qwen2.5 0.5B Instruct."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess

import probe


def build_cli(ref, out, go, env):
    (out / probe.PACKAGE).mkdir(parents=True)
    files = probe.command("git", "ls-tree", "-r", "--name-only", ref, "--", str(probe.PACKAGE), cwd=probe.ROOT).splitlines()
    names = ["go.mod", "go.sum"] + [n for n in files if n.endswith((".go", ".s")) and not n.endswith("_test.go")]
    for name in names:
        (out / name).write_bytes(probe.pinned(ref, name))
    binary = out / "monolith"
    subprocess.run([go, "build", "-buildvcs=false", "-trimpath", "-o", binary, "./cmd/monolith"], cwd=out, env=env, check=True)
    return binary


def run(qwen, gpt2, out):
    spec = json.loads(probe.SPEC.read_text())
    env = probe.isolated_go_environment()
    go = shutil.which("go", path=env["PATH"])
    if probe.command(go, "version", env=env) != spec["go"] or probe.command("/usr/sbin/sysctl", "-n", "machdep.cpu.brand_string") != spec["cpu"]:
        raise ValueError("host or Go version differs")
    out.mkdir(parents=True, exist_ok=False)
    binaries = {key: build_cli(spec[key], out/key, go, env) for key in ("previous", "runtime")}
    args = ["-context", "128", "-weight-format", "q4-mixed", "-weight-mib", "2048",
            "generate", "-prompt", "Hi", "-max-tokens", "6", "-temperature", "0", "-seed", "19", "-json"]
    result = dict(go=spec["go"], cpu=spec["cpu"], args=args, inputs={key:spec[key] for key in binaries},
                  binaries={key:probe.sha(binary) for key, binary in binaries.items()}, models={})
    catalog = json.loads(probe.CATALOG.read_text())["models"]
    for name, path in (("qwen25", qwen), ("gpt2", gpt2)):
        model = next(m for m in catalog if m["id"] == name)
        if any(probe.sha(path/n) != h for n, h in model["files"].items()):
            raise ValueError(f"{name} snapshot differs")
        outputs = {}
        for key, mode in (("previous", "all"), ("runtime", "all"), ("runtime", "all+attention")):
            cli = [binaries[key], "infer", "local", "-path", path, *args]
            response = json.loads(subprocess.check_output(cli, env=dict(env, **{probe.SWITCH:mode}), timeout=360))
            outputs[f"{key}/{mode}"] = {k:response[k] for k in ("prompt_tokens", "token_ids", "text")}
        result["models"][name] = dict(repo=model["repo"], revision=model["revision"], outputs=outputs)
        (out/"cli.json").write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n")
        if any(s != outputs["previous/all"] or len(s["token_ids"]) != 6 for s in outputs.values()):
            raise ValueError(f"{name} CLI output differs")
        print(name, outputs["previous/all"]["token_ids"], flush=True)


if __name__ == "__main__":
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("qwen", type=Path)
    cli.add_argument("gpt2", type=Path)
    cli.add_argument("output", type=Path)
    args = cli.parse_args()
    run(args.qwen.resolve(), args.gpt2.resolve(), args.output.resolve())
