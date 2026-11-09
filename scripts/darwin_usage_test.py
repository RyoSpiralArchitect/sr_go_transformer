import unittest
from unittest.mock import patch

import darwin_usage as usage


class DarwinUsageTests(unittest.TestCase):
    def test_dead_calibration_child_preserves_original_error(self):
        popen = usage.subprocess.Popen

        def failed_child(*args, **kwargs):
            return popen([usage.sys.executable, "-c", "pass"], **kwargs)

        with patch.object(usage.subprocess, "Popen", side_effect=failed_child):
            with self.assertRaisesRegex(RuntimeError, "calibration child failed"):
                usage.calibrate(None)

    def test_timebase_and_performance_fractions(self):
        before = dict.fromkeys(usage.COUNTERS, 0)
        before.update(pid=12, timebase_numer=125, timebase_denom=3)
        after = {**before, "ri_user_time": 24000000, "ri_user_ptime": 12000000,
                 "ri_instructions": 1000, "ri_cycles": 2000, "ri_pinstructions": 600}
        result = usage.difference(before, after, 500000000)
        self.assertEqual(result["cpu_seconds"], 1)
        self.assertEqual(result["mean_cpu_parallelism"], 2)
        self.assertEqual(result["performance_cpu_fraction"], 0.5)
        self.assertEqual(result["performance_instruction_fraction"], 0.6)

    def test_rejects_identity_change_and_counter_decrease(self):
        before = dict.fromkeys(usage.COUNTERS, 1)
        before.update(pid=12, timebase_numer=125, timebase_denom=3)
        for changes in ({"pid": 13}, {"timebase_denom": 1}, {"ri_cycles": 0}):
            with self.subTest(changes=changes):
                with self.assertRaises(ValueError):
                    usage.difference(before, {**before, **changes}, 1000)
