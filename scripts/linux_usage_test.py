import unittest

import linux_usage as usage


class LinuxUsageTests(unittest.TestCase):
    def fixture(self):
        return {"pid": 12, "start_ticks": 1000, "clock_ticks_per_second": 100,
                "user_ticks": 100, "system_ticks": 10, "minor_faults": 4, "major_faults": 0,
                "affinity": [4, 5, 6, 7], "thread_affinities": {"12": [4, 5, 6, 7]},
                "io": {"read_bytes": 0, "write_bytes": 0}}

    def test_ticks_and_affinity(self):
        before = self.fixture()
        after = {**before, "user_ticks": 400}
        result = usage.difference(before, after, 1000000000)
        self.assertEqual(result["cpu_seconds"], 3)
        self.assertEqual(result["mean_cpu_parallelism"], 3)

    def test_rejects_before_snapshot_thread_escape(self):
        before = {**self.fixture(), "thread_affinities": {"12": [0, 4, 5, 6, 7]}}
        with self.assertRaisesRegex(ValueError, "affinity"):
            usage.difference(before, self.fixture(), 1000)

    def test_rejects_reuse_negative_ticks_and_thread_escape(self):
        before = self.fixture()
        for changes in ({"start_ticks": 1001}, {"user_ticks": 0}, {"thread_affinities": {"12": [0, 4, 5, 6, 7]}}):
            with self.subTest(changes=changes):
                with self.assertRaises(ValueError):
                    usage.difference(before, {**before, **changes}, 1000)
