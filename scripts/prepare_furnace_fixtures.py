import json
import subprocess
import tarfile
from pathlib import Path

from measure_q8_furnace import file_sha


def main():
    root = Path(__file__).resolve().parent
    build = json.loads((root / "q8-furnace-build-20261109.json").read_text())
    archive = root / "furnace-fixtures-base-20261109.tar.gz"
    results = {}
    for label in ("before", "after"):
        directory = root / f"fixture-{label}"
        directory.mkdir(exist_ok=False)
        with tarfile.open(archive) as source:
            source.extractall(directory, filter="data")
        patch = root / ("furnace-q4-baseline-20261109.patch" if label == "before" else "q8-cached-invocation-candidate-20261109.patch")
        subprocess.run(["git", "apply", str(patch)], cwd=directory, check=True)
        if label == "before":
            subprocess.run(["git", "apply", "--include=cmd/monolith/post_singleexp_profile_test.go",
                            str(root / "q8-cached-invocation-candidate-20261109.patch")], cwd=directory, check=True)
        actual = file_sha(directory / "cmd/monolith/monolith.go")
        if actual != build["source_sha256"][label]:
            raise ValueError("fixture runtime identity differs from compiled runtime")
        results[label] = {"directory": str(directory), "source_sha256": actual}
    (root / "fixtures.json").write_text(json.dumps({"archive_sha256": file_sha(archive), "fixtures": results}, indent=2) + "\n")
    print(json.dumps(results))


if __name__ == "__main__":
    main()
