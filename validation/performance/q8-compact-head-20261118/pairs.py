#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Use the hashed resident binaries with only two active model processes."""

import argparse
from contextlib import ExitStack
import json
from pathlib import Path
import signal
import subprocess
import time

from run import RECORD, ROOT, Worker, isolated_go_environment, memory, sha


def layout(spec):
    for block, part in enumerate(spec["blocks"]):
        for mode in part["right"]:
            yield (block, "baseline", mode, part["cases"], part["reverse"], spec["rounds_per_block"])
    part = spec["direct"]
    yield (len(spec["blocks"]), part["left"], part["right"], part["cases"], part["reverse"], part["rounds"])


def prefill_or_decode(case, reverse):
    phases = case["phases"]
    return phases[::-1] if reverse else phases


def order(reverse, case_index, stage_index, round_):
    left_first = (case_index + stage_index + round_ + reverse) % 2 == 0
    return ("left", "right") if left_first else ("right", "left")


def run(snapshot, build_root, output, spec):
    common = json.loads((RECORD/spec["common"]).read_text())
    source = build_root/"events.jsonl"
    first = json.loads(source.open().readline())
    if first["event"] != "start" or first["revision"] != common["model_revision"]:
        raise ValueError("invalid build receipt")
    inputs = {ROOT/f: digest for f,digest in first["inputs"].items()}
    assets = {snapshot/f: digest for f,digest in first["model_files"].items()}

    def verify(files):
        if any(sha(f) != h for f,h in files.items()):
            raise ValueError("source, model or binary hash mismatch")

    binaries, builds = {}, {}
    for mode, build in first["builds"].items():
        directory = build_root/"build"/mode
        if build["sources"]["cmd/monolith/monolith.go"] != common["runtime_sha256"][mode]:
            raise ValueError("runtime hash differs from frozen version")
        binaries[mode] = directory/"resident.test"
        builds[binaries[mode]] = build["binary_sha256"]
        builds.update({directory/f: digest for f,digest in build["sources"].items()})
    verify(inputs | assets | builds)
    local = {p: sha(p) for p in (Path(__file__).resolve(), RECORD/"pairs.json")}
    env = isolated_go_environment()
    env.update(MONOLITH_RESIDENT_MODEL=str(snapshot), MONOLITH_RESIDENT_CORPUS=str(ROOT/"validation/quality/corpus.json"))
    output.mkdir(parents=True, exist_ok=False)
    start_memory = memory()
    if start_memory["free_percent"] < spec["start_min_free_percent"]:
        raise ValueError("host memory below the entry minimum")

    def interrupt(*_):
        raise TimeoutError("bounded resident comparison reached its time limit")

    signal.signal(signal.SIGALRM, interrupt)
    signal.alarm(spec["timebox_seconds"])
    try:
        with (output/"events.jsonl").open("x", buffering=1) as log, ExitStack() as owned:
            def event(kind, **data):
                log.write(json.dumps(dict(event=kind, **data), allow_nan=False)+"\n")
            event("start", build=first, build_journal_sha256=sha(source), memory=start_memory,
                  inputs={str(p.relative_to(ROOT)): h for p,h in local.items()})

            def checkpoint():
                point = memory()
                if (point["free_percent"] < spec["group_min_free_percent"] or
                        point["swapouts"]-start_memory["swapouts"] > spec["one_side_swapout_pages_max"]):
                    event("memory_stop", memory=point)
                    raise ValueError("resident memory bound crossed")
                return point

            contract = None

            def launch(stack, name, mode):
                nonlocal contract
                worker = Worker(binaries[mode], env, stack.enter_context((output/f"{name}.log").open("xb")))
                stack.callback(worker.stop)
                ready = worker.receive(180)
                if ready["executor_bytes"] != common["executor_bytes"] or ready["ready"]["weight_format"] != common["weights"]:
                    raise ValueError("unexpected footprint or weight type")
                if contract is None:
                    contract = ready
                if ready != contract:
                    raise ValueError("resident workers disagree on load plan")
                event("ready", worker=name, mode=mode, reply=ready, memory=checkpoint())
                return worker

            def quit_worker(w):
                if w.ask("quit", seconds=10) != {"stopped": True} or w.proc.wait(10) != 0:
                    raise ValueError("resident worker did not shut down cleanly")

            owner = owned.enter_context(ExitStack())
            left_mode = "baseline"
            left = launch(owner, "reference", left_mode)
            known = {}
            for group, (block, lmode, rmode, cases, reverse, rounds) in enumerate(layout(spec)):
                if lmode != left_mode:
                    quit_worker(left)
                    owner.close()
                    owner = owned.enter_context(ExitStack())
                    left = launch(owner, "pair-direct", lmode)
                    left_mode = lmode
                with ExitStack() as temporary:
                    right = launch(temporary, f"right-{group}", rmode)
                    event("group", group=group, block=block, left=lmode, right=rmode, memory=checkpoint())
                    for i, idx in enumerate(cases):
                        case = spec["cases"][idx]
                        case_id = case["id"]
                        arms = {"left": left, "right": right}
                        context_order = order(reverse, i, 0, 0)
                        for arm in context_order:
                            warm = arms[arm].ask("prepare", case, seconds=180)
                            event("warm", group=group, case=case_id, arm=arm, signatures=warm)
                            if known.setdefault(case_id, warm) != warm:
                                raise ValueError("prefix, warm-up outputs or capacities diverged")
                        for s, stage in enumerate(prefill_or_decode(case, reverse)):
                            phase = []
                            for r in range(rounds):
                                times = {}
                                for arm in order(reverse, i, s, r):
                                    a = arms[arm].ask(stage)
                                    event("sample", group=group, case=case_id, phase=stage, round=r, arm=arm, sample=a)
                                    if a["Signature"] != warm[stage]:
                                        raise ValueError("sample diverged from frozen warm-up signature")
                                    times[arm] = sum(a["Ns"])
                                phase.append(times["right"]/times["left"])
                            event("checkpoint", group=group, case=case_id, phase=stage, memory=checkpoint())
                            print(f"{group+1} {lmode}/{rmode} {case_id} {stage}: {len(phase)} pairs ready", flush=True)
                    event("end_group", group=group, memory=checkpoint(), rss_kib=[left.rss_kib(), right.rss_kib()])
                    quit_worker(right)
            quit_worker(left)
            verify(inputs | builds | assets | local)
            event("complete", memory=checkpoint())
    finally:
        signal.alarm(0)


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("--model", type=Path, required=True)
    cli.add_argument("--builds", type=Path, required=True, help="directory from the previous four-process build")
    cli.add_argument("--output", type=Path, required=True)
    args = cli.parse_args()
    run(args.model.resolve(), args.builds.resolve(), args.output.resolve(),
        json.loads((RECORD/"pairs.json").read_text()))


if __name__ == "__main__":
    main()
