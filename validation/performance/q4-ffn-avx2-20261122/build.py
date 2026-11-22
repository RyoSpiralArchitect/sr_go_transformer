"""Cross-build the two ordinary runtime packages with the same resident probe."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[3]
BASE = "c665cb3c75baf29ec942c1781e6e8a89afd4a50a"
FIXTURE = "validation/performance/q8-compact-head-20261118/resident_test.go.txt"


def sha(path):
    with path.open("rb") as f:
        return hashlib.file_digest(f, "sha256").hexdigest()


def build(args):
    args.output.mkdir(parents=True, exist_ok=False)
    env = dict(os.environ, GOOS="linux", GOARCH="amd64", GOAMD64="v1", GOENV="off", GOWORK="off",
               CGO_ENABLED="0", GOTOOLCHAIN="local", GOFLAGS="", GOEXPERIMENT="", GOPROXY="off", GOSUMDB="off")
    manifest = dict(baseline=args.baseline, go=subprocess.check_output([args.go, "version"], text=True, env=env).strip(),
                    target="linux/amd64 GOAMD64=v1 CGO_ENABLED=0")
    for arm, rev in (("scalar", args.baseline), ("native", args.candidate)):
        ref = subprocess.check_output(["git", "rev-parse", "--verify", rev+"^{commit}"], cwd=ROOT, text=True).strip()
        stage = args.output/arm
        package = stage/"cmd/monolith"
        package.mkdir(parents=True)
        files = subprocess.check_output(["git", "ls-tree", "-r", "--name-only", ref, "--", "cmd/monolith"],
                                        cwd=ROOT, text=True).splitlines()
        for name in ["go.mod", "go.sum", *(n for n in files if n.endswith((".go", ".s")) and not n.endswith("_test.go"))]:
            (stage/name).write_bytes(subprocess.check_output(["git", "show", f"{ref}:{name}"], cwd=ROOT))
        shutil.copyfile(ROOT/FIXTURE, package/"resident_test.go")
        shutil.copyfile(ROOT/"cmd/monolith/inference_perf_test.go", package/"inference_perf_test.go")
        binary = args.output/(arm+".test")
        subprocess.run([args.go, "test", "-c", "-trimpath", "-o", binary, "./cmd/monolith"], cwd=stage, env=env, check=True)
        manifest[arm] = dict(commit=ref, binary_sha256=sha(binary), sources={str(p.relative_to(stage)):sha(p)
                             for p in sorted(stage.rglob("*")) if p.is_file()})
    (args.output/"builds.json").write_text(json.dumps(manifest, indent=2)+"\n")


if __name__ == "__main__":
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("candidate")
    cli.add_argument("output", type=lambda path: Path(path).resolve())
    cli.add_argument("--go", default="go")
    cli.add_argument("--baseline", default=BASE, help="use the candidate commit to compare opt-in versus opt-out")
    build(cli.parse_args())
