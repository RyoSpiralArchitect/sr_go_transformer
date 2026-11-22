"""Compare the local Go CLI with the offline CPU Transformers checkpoint."""
import argparse
import gc
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile
import time

import numpy as np
import torch
import transformers
import tokenizers
from transformers import AutoModelForCausalLM, AutoTokenizer

REV = "a1847dff35000b4271fa70afc5db10fd29fedbdf"
PROMPTS = ("The capital of France is", "Once upon a time,")
TOKENIZER_CASES = (*PROMPTS, "1234567 cats 🐈‍⬛\r\n  café", "We’ll go!  \n日本語", "<|endoftext|>word <|extra_id_0|>")


def sha(path):
    with path.open("rb") as f:
        return hashlib.file_digest(f, "sha256").hexdigest()


def verify(args, log):
    def record(kind, **fields):
        print(json.dumps(dict(event=kind, **fields), ensure_ascii=False, allow_nan=False), file=log, flush=True)

    if args.model.name != REV or sorted(os.sched_getaffinity(0)) != [4, 5, 6, 7]:
        raise ValueError("expected the pinned Furnace snapshot and cores 4-7")
    entry = next(m for m in json.loads(args.catalog.read_text())["models"] if m["revision"] == REV)
    for name, digest in entry["files"].items():
        if sha(args.model/name) != digest:
            raise ValueError("asset identity mismatch: " + name)
    flags = ["-hf-model", str(args.model), "-context", "128", "-weight-mib", "8192"]
    env = dict(os.environ, GOMAXPROCS="4", HF_HUB_OFFLINE="1", MONOLITH_Q4_FFN_AVX2="1")
    binary = str(args.binary.resolve())

    def call(command, *arguments):
        with tempfile.TemporaryFile(mode="w+") as mem:
            start = time.monotonic()
            out = subprocess.check_output(["/usr/bin/time", "-f", "%M", "-o", f"/proc/self/fd/{mem.fileno()}",
                  binary, command, *arguments], pass_fds=(mem.fileno(),), env=env, timeout=240)
            elapsed = time.monotonic()-start
            mem.seek(0)
            return json.loads(out), dict(cli_wall_seconds=elapsed, peak_rss_kib=int(mem.read().strip()))

    record("start", model=entry["repo"], revision=REV, assets=entry["files"], binary_sha256=sha(args.binary),
           driver_sha256=sha(Path(__file__)), torch=torch.__version__, transformers=transformers.__version__,
           tokenizers=tokenizers.__version__, affinity=sorted(os.sched_getaffinity(0)), device="cpu", threads=4,
           steps=8, max_abs_tolerance=.002)
    torch.set_num_threads(4)
    torch.set_num_interop_threads(1)
    tok = AutoTokenizer.from_pretrained(args.model, local_files_only=True, trust_remote_code=False)
    for prompt in TOKENIZER_CASES:
        expected = tok.encode(prompt, add_special_tokens=True)
        got, _ = call("tokenize-hf", "-hf-model", str(args.model), "-prompt", prompt)
        expected_text = tok.decode(expected, skip_special_tokens=True)
        match = got["token_ids"] == expected and got["text"] == expected_text
        record("tokenizer", prompt=prompt, ids=expected, match=match, go=got)
        if not match:
            raise ValueError("tokenizer disagreement")
    model = AutoModelForCausalLM.from_pretrained(args.model, dtype=torch.float32, attn_implementation="eager",
                                               local_files_only=True, trust_remote_code=False).cpu().eval()
    cases = []
    for prompt in PROMPTS:
        ids = tok.encode(prompt, add_special_tokens=True)
        inputs, past, expected, logits = torch.tensor([ids]), None, [], []
        with torch.inference_mode():
            for _ in range(8):
                result = model(inputs, past_key_values=past, use_cache=True)
                row = result.logits[0, -1].float().numpy().copy()
                token = int(row.argmax())
                expected.append(token)
                logits.append(row)
                if token == model.config.eos_token_id:
                    break
                inputs, past = torch.tensor([[token]]), result.past_key_values
        cases.append((prompt, ids, expected, np.stack(logits)))
    del model, result, past
    gc.collect()
    for prompt, ids, expected, logits in cases:
        for chunk in (1, 16):
            go, resources = call("infer-hf", *flags, "-kv-format", "f32", "-threads", "4", "-max-tokens", "8", "-ids",
                                 ",".join(map(str, ids)), "-prefill-chunk", str(chunk), "-logits")
            rows = np.asarray(go["logits"], dtype=np.float32)
            if rows.shape != logits.shape:
                raise ValueError(f"unexpected logits shape {rows.shape}")
            error = float(np.abs(rows-logits).max())
            match = go["token_ids"] == expected
            record("numerical", prompt=prompt, ids=ids, chunk=chunk, hf=expected, go=go["token_ids"],
                   logits_shape=list(rows.shape), max_abs_error=error, greedy_match=match, **resources)
            if not match or not np.isfinite(error) or error > .002:
                raise ValueError("FP32 numerical disagreement")
        for fmt in ("f32", "q4-mixed"):
            go, resources = call("generate", *flags, "-weight-format", fmt, "-kv-format", "f32", "-threads", "4",
                                 "-max-tokens", "8", "-temperature", "0", "-repeat-penalty", "1", "-prompt", prompt, "-json")
            match = go["token_ids"] == expected and go["text"] == tok.decode(expected, skip_special_tokens=True)
            record("completion", format=fmt, prompt=prompt, reference_ids=expected, equals_fp32=match, go=go, **resources)
            if go["prompt_tokens"] != len(ids) or fmt == "f32" and not match:
                raise ValueError("text generation disagreement")
    record("complete")


if __name__ == "__main__":
    cli = argparse.ArgumentParser(description=__doc__)
    for arg in ("model", "binary", "catalog", "output"):
        cli.add_argument(arg, type=Path)
    args = cli.parse_args()
    with args.output.open("x", buffering=1) as output:
        verify(args, output)
