import argparse
import hashlib
import json
import math
import re
import signal
import socket
import subprocess
import time
from datetime import datetime, timezone
from pathlib import Path
from urllib.error import URLError
from urllib.request import ProxyHandler, Request, build_opener

import darwin_usage
import linux_usage

ROOT = Path(__file__).resolve().parents[1]
BINARIES = {
    "before": ("runs/q4-refined-20261109", "1fa2fd0f7bdf074a4a6db0280bd660a13216d1dc9a29ae69318d308856e287d8"),
    "after": ("runs/q8-cached-invocation-20261109", "e9ca0f3ad6fd84c48bb2504cb829466af30963a17f2e5eae210e9bc88dae119c"),
}
IDLE = ("monolith_active", "monolith_queue_depth", "monolith_computing_sessions", "monolith_admission_used", "monolith_kv_reserved_bytes")
DELTAS = ("monolith_completed_total", "monolith_generated_tokens_total", "monolith_batch_compute_seconds_sum",
          "monolith_batch_compute_seconds_count", "monolith_first_token_seconds_sum", "monolith_first_token_seconds_count")


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def stamp():
    return datetime.now(timezone.utc).isoformat()


def save(path, data):
    with path.open("x") as file:
        json.dump(data, file, indent=2)
        file.write("\n")


def parse_metrics(raw):
    values = {}
    for line in raw.decode().splitlines():
        match = re.fullmatch(r"([a-zA-Z_:][a-zA-Z0-9_:]*) ([0-9.eE+\-]+)", line)
        if not match:
            continue
        key, value = match.group(1), float(match.group(2))
        if key in values or not math.isfinite(value):
            raise ValueError("duplicate or invalid metric")
        values[key] = value
    for key in (*IDLE, *DELTAS, "monolith_kernel_workers", "monolith_prefix_hits_total", "monolith_prefix_bytes", "monolith_gc_cycles_total", "monolith_gc_pause_seconds_total"):
        if key not in values:
            raise ValueError(f"missing metric {key}")
    return values


def validate_completion(value, tokens, reference):
    if value.get("completion_tokens") != tokens or len(value.get("token_ids", [])) != tokens or value.get("finish_reason") != "length":
        raise ValueError("unexpected completion length or finish reason")
    if not isinstance(value.get("text"), str) or any(type(token) is not int for token in value["token_ids"]):
        raise ValueError("invalid text or token IDs")
    if reference is not None and value != reference:
        raise ValueError("completion/token IDs changed")


def metric_delta(before, after, tokens):
    if any(after[key] != 0 for key in IDLE) or after["monolith_kernel_workers"] != 4:
        raise ValueError("server is not idle with four kernel workers")
    if after["monolith_prefix_hits_total"] != 0 or after["monolith_prefix_bytes"] != 0:
        raise ValueError("unexpected prefix caching")
    delta = {key: after[key] - before[key] for key in DELTAS}
    if delta["monolith_completed_total"] != 1 or delta["monolith_generated_tokens_total"] != tokens:
        raise ValueError("unexpected request/token accounting")
    if any(value < 0 for value in delta.values()) or delta["monolith_first_token_seconds_count"] != 1:
        raise ValueError("invalid metric delta")
    return delta


def run_leg(label, index, args, output, reference):
    relative, expected = BINARIES[label]
    binary = ROOT / relative
    if sha(binary) != expected:
        raise ValueError("saved binary identity changed")
    with socket.socket() as sock:
        sock.bind(("127.0.0.1", 0))
        port = sock.getsockname()[1]
    base = f"http://127.0.0.1:{port}"
    opener = build_opener(ProxyHandler({}))
    directory = output / f"leg{index}-{label}"
    directory.mkdir()
    command = [str(binary), "serve", "-addr", f"127.0.0.1:{port}", "-hf-model", str(args.model.resolve()),
               "-weight-format", "q8", "-weight-mib", "14000", "-context", "2048", "-kv-mib", "512",
               "-threads", "4", "-kernel-workers", "4", "-max-batch", "1", "-queue", "1", "-prefill-chunk", "16",
               "-prefix-cache-mib", "0"]
    metadata = {"label": label, "index": index, "command": command, "binary_sha256": expected, "started_utc": stamp()}
    save(directory / "start.json", metadata)
    with (directory / "stdout.log").open("xb") as stdout, (directory / "stderr.log").open("xb") as stderr:
        process = subprocess.Popen(command, stdin=subprocess.DEVNULL, stdout=stdout, stderr=stderr)
        observer = linux_usage if getattr(args, "linux_observer", False) else darwin_usage
        observe = bool(args.usage_helper) or getattr(args, "linux_observer", False)
        records = []
        try:
            deadline = time.monotonic() + 180
            while True:
                if process.poll() is not None:
                    raise RuntimeError("server exited before readiness; see stderr.log")
                try:
                    with opener.open(base + "/healthz", timeout=1) as response:
                        health = json.load(response)
                    if health.get("status") == "ok" and health.get("parameters", 0) > 3000000000:
                        break
                except (URLError, TimeoutError):
                    pass
                if time.monotonic() > deadline:
                    raise TimeoutError("model readiness timed out")
                time.sleep(0.25)
            metadata["ready_utc"] = stamp()
            save(directory / "health.json", health)

            def idle_metrics():
                deadline = time.monotonic() + 10
                while True:
                    if process.poll() is not None:
                        raise RuntimeError("server exited during measurement")
                    with opener.open(base + "/metrics", timeout=5) as response:
                        raw = response.read()
                    values = parse_metrics(raw)
                    if all(values[key] == 0 for key in IDLE) and values["monolith_kernel_workers"] == 4:
                        return raw, values
                    if time.monotonic() > deadline:
                        raise TimeoutError("server did not become idle")
                    time.sleep(0.01)

            for trial in range(args.repeats + args.warmups):
                prefix = directory / f"request{trial}"
                raw_before, before = idle_metrics()
                prefix.with_suffix(".before.prom").write_bytes(raw_before)
                body = {"prompt": "Write a detailed history of the city of Tokyo.", "max_tokens": args.tokens,
                        "temperature": 0, "top_k": 40, "top_p": 0.95, "repeat_penalty": 1.1, "seed": 1, "stream": False}
                save(prefix.with_suffix(".input.json"), body)
                request = Request(base + "/v1/completions", json.dumps(body).encode(), {"Content-Type": "application/json"})
                started = stamp()
                usage_before = observer.snapshot(args.usage_helper, process.pid) if observe else None
                clock = time.perf_counter_ns()
                with opener.open(request, timeout=140) as response:
                    raw = response.read()
                wall_ns = time.perf_counter_ns() - clock
                usage = None
                if observe:
                    usage_after = observer.snapshot(args.usage_helper, process.pid)
                    usage = {"kind": "linux-proc-v1" if observer is linux_usage else "darwin-rusage-v6",
                             "before": usage_before, "after": usage_after,
                             "derived": observer.difference(usage_before, usage_after, wall_ns)}
                prefix.with_suffix(".response.json").write_bytes(raw)
                completion = json.loads(raw)
                validate_completion(completion, args.tokens, reference)
                if reference is None:
                    reference = completion
                    save(output / "reference.json", reference)
                raw_after, after = idle_metrics()
                prefix.with_suffix(".after.prom").write_bytes(raw_after)
                delta = metric_delta(before, after, args.tokens)
                record = {"trial": trial, "warmup": trial < args.warmups, "started_utc": started, "finished_utc": stamp(),
                          "wall_ns": wall_ns, "delta": delta, "completion_tokens": completion["completion_tokens"],
                          "prompt_tokens": completion["prompt_tokens"], "response_sha256": hashlib.sha256(raw).hexdigest()}
                if usage is not None:
                    record["usage"] = usage
                record["gc_delta"] = {key: after[key] - before[key] for key in ("monolith_gc_cycles_total", "monolith_gc_pause_seconds_total")}
                save(prefix.with_suffix(".timing.json"), record)
                records.append(record)
                print(json.dumps({"leg": index, "label": label, **record}), flush=True)
        finally:
            if process.poll() is None:
                process.send_signal(signal.SIGINT)
            try:
                returncode = process.wait(timeout=15)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()
                raise RuntimeError("owned benchmark server failed to shut down")
    if returncode != 0:
        raise RuntimeError(f"server exited with status {returncode}")
    metadata.update({"finished_utc": stamp(), "returncode": returncode, "records": records})
    save(directory / "result.json", metadata)
    return metadata, reference


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--tokens", type=int, default=64)
    parser.add_argument("--repeats", type=int, default=2)
    parser.add_argument("--warmups", type=int, default=1)
    parser.add_argument("--usage-helper", type=Path)
    args = parser.parse_args()
    if args.usage_helper:
        args.usage_helper = args.usage_helper.resolve()
    if not 1 <= args.tokens <= 128 or not 1 <= args.repeats <= 8 or not 1 <= args.warmups <= 8:
        parser.error("tokens must be1..128 and repeats/warmups1..8")
    output = args.output.resolve()
    output.mkdir(exist_ok=False)
    schedule = ["before", "after", "after", "before"]
    save(output / "protocol.json", {"schedule": schedule, "tokens": args.tokens, "repeats": args.repeats,
         "warmups_per_leg": args.warmups, "script_sha256": sha(Path(__file__)),
         "usage_helper_sha256": sha(args.usage_helper) if args.usage_helper else None,
         "usage_module_sha256": sha(Path(darwin_usage.__file__)), "scope": "resident HTTP generation including prompt prefill, scheduling and response transfer; excludes startup/model loading"})
    legs, reference = [], None
    for index, label in enumerate(schedule):
        leg, reference = run_leg(label, index, args, output, reference)
        legs.append(leg)
    hashes = {str(path.relative_to(output)): sha(path) for path in sorted(output.rglob("*")) if path.is_file()}
    save(output / "result.json", {"legs": legs, "reference": reference, "raw_file_sha256": hashes})


if __name__ == "__main__":
    main()
