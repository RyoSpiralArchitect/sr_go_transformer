import copy
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import evaluate_q8_observed as evaluator


def fixture():
    record = {"warmup": False, "wall_ns": 1000000000,
              "gc_delta": {"monolith_gc_cycles_total": 0},
              "usage": {"derived": {"cpu_seconds": 3, "mean_cpu_parallelism": 3,
                        "performance_cpu_fraction": 0.99, "cycles_per_cpu_ns": 3,
                        "raw_delta": {"ri_instructions": 100, "ri_cycles": 100,
                                      "ri_pageins": 0, "ri_diskio_bytesread": 0}}}}
    data = {"legs": [{"index": index, "label": label, "records": [copy.deepcopy(record) for _ in range(3)]}
                     for index, label in enumerate(("before", "after", "after", "before"))]}
    summary = {"same_baseline_late_over_early": {"wall_ratio": 1}, "same_candidate_late_over_early": {"wall_ratio": 1}}
    return data, summary


class ObservedGateTests(unittest.TestCase):
    def run_evaluation(self, data, summary):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "result.json").write_text(json.dumps(data))
            with patch.object(evaluator.resident, "summarize", return_value=summary):
                return evaluator.evaluate(root)

    def test_stable_fixture_passes_and_retains_every_sample(self):
        data, summary = fixture()
        result = self.run_evaluation(data, summary)
        self.assertTrue(result["eligible_for_confirmation"])
        self.assertEqual(sum(len(leg["samples"]) for leg in result["legs"]), 12)

    def test_late_baseline_drift_fails(self):
        data, summary = fixture()
        summary["same_baseline_late_over_early"]["wall_ratio"] = 1.08
        result = self.run_evaluation(data, summary)
        self.assertFalse(result["eligible_for_confirmation"])
        self.assertIn("before: late/early mean wall exceeds3% screen", result["screen_failures"])

    def test_request_variation_and_gc_are_not_silently_dropped(self):
        data, summary = fixture()
        data["legs"][0]["records"][0]["wall_ns"] = 1200000000
        data["legs"][0]["records"][0]["gc_delta"]["monolith_gc_cycles_total"] = 1
        result = self.run_evaluation(data, summary)
        self.assertFalse(result["eligible_for_confirmation"])
        self.assertEqual(len(result["legs"][0]["samples"]), 3)
        self.assertEqual(len(result["screen_failures"]), 2)
