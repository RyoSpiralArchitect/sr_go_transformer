import copy
import unittest

import measure_q8_resident as measure


def metrics():
    values = dict.fromkeys((*measure.IDLE, *measure.DELTAS), 0.0)
    values.update(monolith_kernel_workers=4.0, monolith_prefix_hits_total=0.0, monolith_prefix_bytes=0.0,
                  monolith_gc_cycles_total=0.0, monolith_gc_pause_seconds_total=0.0)
    return values


class ResidentMeasurementTests(unittest.TestCase):
    def test_parses_scalar_metrics_and_ignores_histogram_buckets(self):
        values = metrics()
        raw = "# TYPE sample histogram\nsample_bucket{le=\"1\"} 1\n"
        raw += "".join(f"{key} {value}\n" for key, value in values.items())
        self.assertEqual(measure.parse_metrics(raw.encode()), values)
        with self.assertRaisesRegex(ValueError, "duplicate"):
            measure.parse_metrics((raw + "monolith_active 0\n").encode())
        with self.assertRaisesRegex(ValueError, "missing"):
            measure.parse_metrics(b"monolith_active 0\n")

    def test_requires_gc_metrics(self):
        for key in ("monolith_gc_cycles_total", "monolith_gc_pause_seconds_total"):
            values = metrics()
            del values[key]
            raw = "".join(f"{name} {value}\n" for name, value in values.items())
            with self.subTest(key=key), self.assertRaisesRegex(ValueError, "missing metric " + key):
                measure.parse_metrics(raw.encode())

    def test_completion_checks_all_tokens_and_metadata(self):
        value = {"completion_tokens": 2, "token_ids": [11, 12], "finish_reason": "length", "text": "ok", "prompt_tokens": 3}
        measure.validate_completion(value, 2, None)
        measure.validate_completion(value, 2, copy.deepcopy(value))
        for key, changed in (("completion_tokens", 1), ("token_ids", [11, 13]), ("finish_reason", "eos"), ("text", "changed"), ("prompt_tokens", 4)):
            with self.subTest(key=key):
                bad = {**value, key: changed}
                with self.assertRaises(ValueError):
                    measure.validate_completion(bad, 2, value)

    def test_accounting_and_reference_deltas(self):
        before = metrics()
        after = {**before, "monolith_completed_total": 1, "monolith_generated_tokens_total": 64,
                 "monolith_first_token_seconds_count": 1, "monolith_batch_compute_seconds_sum": 10.5,
                 "monolith_batch_compute_seconds_count": 64, "monolith_first_token_seconds_sum": 0.1}
        delta = measure.metric_delta(before, after, 64)
        self.assertEqual(delta["monolith_batch_compute_seconds_sum"], 10.5)
        for key, changed in (("monolith_active", 1), ("monolith_prefix_hits_total", 1),
                             ("monolith_kernel_workers", 1), ("monolith_completed_total", 2),
                             ("monolith_generated_tokens_total", 63), ("monolith_first_token_seconds_count", 0)):
            with self.subTest(key=key):
                with self.assertRaises(ValueError):
                    measure.metric_delta(before, {**after, key: changed}, 64)
