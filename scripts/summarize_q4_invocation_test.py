import contextlib
import io
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import summarize_q4_invocation as summary


def bench_line(ns=100):
    return f"BenchmarkFixture/workers1/prefix33/tokens128-10 7 {ns} ns/op 123 B/op 2 allocs/op\n"


class Q4InvocationSummaryTests(unittest.TestCase):
    def test_reads_expected_cases_without_cpu_suffix(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "sample.txt"
            path.write_text("goos: darwin\n" + bench_line() + "PASS\n")
            self.assertEqual(summary.read_bench(path, 1), {
                "BenchmarkFixture/workers1/prefix33/tokens128": {
                    "ns": 100.0, "bytes": 123, "allocs": 2,
                },
            })

    def test_reads_omitted_gomaxprocs_one_suffix(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "sample.txt"
            path.write_text(bench_line().replace("-10 ", " "))
            rows = summary.read_bench(path, 1)
            self.assertEqual(rows["BenchmarkFixture/workers1/prefix33/tokens128"]["ns"], 100.0)
            path.write_text(bench_line() + bench_line().replace("-10 ", " "))
            with self.assertRaisesRegex(ValueError, "duplicate case"):
                summary.read_bench(path, 1)

    def test_rejects_duplicates_and_missing_cases(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "sample.txt"
            path.write_text(bench_line() + bench_line(200))
            with self.assertRaisesRegex(ValueError, "duplicate case"):
                summary.read_bench(path, 1)
            path.write_text(bench_line())
            with self.assertRaisesRegex(ValueError, "expected 2 cases"):
                summary.read_bench(path, 2)

    def test_keeps_samples_and_declared_historical_source_identities(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            perf = root / "validation/performance"
            perf.mkdir(parents=True)
            harness = root / "cmd/monolith/post_singleexp_profile_test.go"
            harness.parent.mkdir(parents=True)
            harness.write_text("fixture harness")
            (root / "before.test").write_bytes(b"baseline")
            (root / "after.test").write_bytes(b"candidate")
            for run, times in enumerate(((100, 110), (200, 100)), start=1):
                for mode, ns in zip(("before", "after"), times):
                    (perf / f"fixture-generation-{mode}-20261109-run{run}.txt").write_text(bench_line(ns))
            argv = ["summary", "--prefix", "fixture", "--cases", "1", "--runs", "2",
                    "--benchtime", "1s", "--before-binary", "before.test", "--after-binary", "after.test",
                    "--before-source", "1" * 64, "--after-source", "2" * 64]
            output = io.StringIO()
            with patch.object(summary, "ROOT", root), patch.object(summary, "PERF", perf), \
                    patch("sys.argv", argv), contextlib.redirect_stdout(output):
                summary.main()
            result = json.loads(output.getvalue())
            row = result["cases"]["BenchmarkFixture/workers1/prefix33/tokens128"]
            self.assertEqual([item["ns"] for item in row["before"]], [100, 200])
            self.assertEqual([item["ns"] for item in row["after"]], [110, 100])
            self.assertEqual(row["ratios"], [1.1, 0.5])
            self.assertAlmostEqual(row["median_process_ratio"], 0.8)
            self.assertEqual(result["process_order"], [["before", "after"], ["after", "before"]])
            self.assertEqual(result["declared_source_sha256"], {"before": "1" * 64, "after": "2" * 64})
            self.assertEqual(len(result["raw_file_sha256"]), 4)
            self.assertIn("1s", result["measurement"])


if __name__ == "__main__":
    unittest.main()
