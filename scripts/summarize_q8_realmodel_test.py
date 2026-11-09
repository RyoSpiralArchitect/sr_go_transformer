import tempfile
import unittest
from pathlib import Path

import summarize_q8_realmodel as summary


SAMPLE = "real 52.76\nuser 158.10\nsys 1.09\n 3524804608 maximum resident set size\n 3949925355636 instructions retired\n 529612779303 cycles elapsed\n"


class Q8RealModelSummaryTests(unittest.TestCase):
    def test_reads_darwin_time_without_converting_rss_units(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "sample.time"
            path.write_text(SAMPLE)
            row = summary.read_time(path)
            self.assertEqual(row["real"], 52.76)
            self.assertEqual(row["user"], 158.10)
            self.assertEqual(row["sys"], 1.09)
            self.assertEqual(row["maximum resident set size"], 3524804608)
            self.assertEqual(row["instructions retired"], 3949925355636)
            self.assertEqual(row["cycles elapsed"], 529612779303)

    def test_rejects_repeated_timing_or_counter(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "sample.time"
            for extra in ("real 1.00\n", " 100 maximum resident set size\n"):
                with self.subTest(extra=extra):
                    path.write_text(SAMPLE + extra)
                    with self.assertRaisesRegex(ValueError, "duplicate"):
                        summary.read_time(path)

    def test_rejects_missing_invalid_or_zero_values(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "sample.time"
            for text in ("", SAMPLE.replace("real 52.76", "real 0.00"),
                         SAMPLE.replace("user 158.10", "user NaN"),
                         SAMPLE.replace("3524804608", "0")):
                with self.subTest(text=text):
                    path.write_text(text)
                    with self.assertRaisesRegex(ValueError, "missing or nonpositive"):
                        summary.read_time(path)

    def test_preserves_pairs_and_all_ratios(self):
        rows = {name: {"time": {"real": value}} for name, value in
                (("b1", 100), ("a1", 200), ("b2", 200), ("a2", 100))}
        pairs = [("b1", "a1"), ("b2", "a2")]
        self.assertEqual(summary.paired_result(rows, pairs), {
            "pairs": pairs, "ratios": [2.0, 0.5], "median_ratio": 1.25,
        })
