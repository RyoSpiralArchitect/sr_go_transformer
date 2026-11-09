import json
import tempfile
import unittest
from pathlib import Path

import summarize_q8_resident as summary


class ResidentSummaryTests(unittest.TestCase):
    def test_excludes_warmup_and_preserves_samples(self):
        records = [{"warmup": warmup, "wall_ns": wall * 1000000000,
                    "delta": {"monolith_batch_compute_seconds_sum": compute}}
                   for warmup, wall, compute in ((True, 999, 998), (False, 1, 0.5), (False, 3, 2))]
        self.assertEqual(summary.aggregate(records), {
            "wall_seconds": [1, 3], "compute_seconds": [0.5, 2],
            "mean_wall_seconds": 2, "mean_compute_seconds": 1.25,
        })

    def test_rejects_empty_or_nonpositive_measurements(self):
        for records in ([], [{"warmup": False, "wall_ns": 0, "delta": {"monolith_batch_compute_seconds_sum": 1}}]):
            with self.subTest(records=records):
                with self.assertRaises(ValueError):
                    summary.aggregate(records)

    def test_rejects_raw_artifact_escape_and_modification(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "protocol.json").write_text(json.dumps({"schedule": ["before", "after", "after", "before"]}))
            (root / "artifact").write_text("raw")
            for name in ("../escape", "artifact"):
                with self.subTest(name=name):
                    (root / "result.json").write_text(json.dumps({"legs": [None] * 4, "raw_file_sha256": {name: "wrong"}}))
                    with self.assertRaisesRegex(ValueError, "changed or unsafe"):
                        summary.summarize(root)
