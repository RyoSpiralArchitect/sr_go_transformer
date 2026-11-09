import argparse
import hashlib
import json
import os
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ANCESTOR = "9af9a1c1bf8fc3b3797e8c0315031dc8fd270e50"
BASELINE_BLOB = "ab988164d9f4ae0eff0152d7026f06a9822dfcea"


def git(*args, cwd=ROOT):
    return subprocess.check_output(["git", *args], cwd=cwd)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def prepare(output, go=None):
    if not output.parent.is_dir():
        raise ValueError("output parent must already exist")
    output.mkdir(exist_ok=False)
    build = json.loads((ROOT / "validation/performance/q8-furnace-build-20261109.json").read_text())
    candidate = ROOT / "validation/performance/q8-cached-invocation-candidate-20261109.patch"
    for label in ("before", "after"):
        tree = output / f"build-{label}"
        git("worktree", "add", "--detach", str(tree), ANCESTOR)
        if label == "before":
            (tree / "cmd/monolith/monolith.go").write_bytes(git("cat-file", "blob", BASELINE_BLOB))
            (output / "furnace-q4-baseline-20261109.patch").write_bytes(git("diff", "--", "cmd/monolith/monolith.go", cwd=tree))
            git("apply", "--include=cmd/monolith/post_singleexp_profile_test.go", str(candidate), cwd=tree)
        else:
            git("apply", str(candidate), cwd=tree)
        if sha(tree / "cmd/monolith/monolith.go") != build["source_sha256"][label]:
            raise ValueError("historical runtime reconstruction failed")
        if go:
            version = subprocess.check_output([str(go), "version"], text=True)
            if not version.startswith("go version go1.27.3 "):
                raise ValueError("historical binary reproduction requires Go1.27.3")
            env = {**os.environ, "GOOS": "linux", "GOARCH": "amd64", "GOAMD64": "v1", "CGO_ENABLED": "0", "GOTOOLCHAIN": "local"}
            for kind, command in (("binaries", ["build"]), ("test_binaries", ["test", "-c"])):
                name, expected = build[kind][label]
                subprocess.run([str(go), *command, "-trimpath", "-o", str(output / name), "./cmd/monolith"], cwd=tree, env=env, check=True)
                if sha(output / name) != expected:
                    raise ValueError(f"historical binary differs: {name}")
    git("archive", "--format=tar.gz", f"--output={output / 'furnace-fixtures-base-20261109.tar.gz'}", ANCESTOR)
    for name in ("measure_q8_furnace.py", "measure_q8_resident.py", "linux_usage.py", "darwin_usage.py", "prepare_furnace_fixtures.py"):
        shutil.copy2(ROOT / "scripts" / name, output / name)
    for name in ("q8-furnace-build-20261109.json", "q8-furnace-gates-20261109.json", candidate.name):
        shutil.copy2(ROOT / "validation/performance" / name, output / name)
    manifest = {path.name: sha(path) for path in output.iterdir() if path.is_file()}
    (output / "bundle-manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    return {"output": str(output), "files": sorted(manifest),
            "scope": "Historical sources/binary hashes reproducible; current observer scripts include review fixes and are not byte-identical to historical measurement scripts. No model weights or raw runs included. Keep build-* worktrees local; transfer only listed files. Copy matching model assets into model/, run prepare_furnace_fixtures.py, then taskset -c4-7 python3 measure_q8_furnace.py --output NEW_DIRECTORY. No automatic remote execution or host policy changes."}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--go", type=Path, help="optional pinned Go1.27.3 executable; cross-build and verify historical binaries")
    args = parser.parse_args()
    print(json.dumps(prepare(args.output.resolve(), args.go.resolve() if args.go else None), indent=2))


if __name__ == "__main__":
    main()
