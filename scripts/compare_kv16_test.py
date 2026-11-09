import json
from pathlib import Path
import tempfile
import unittest

from compare_kv16 import read_quality_report


class ReportRetentionTests(unittest.TestCase):
    def test_partial_final_report_remains_available_without_parse_exception(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory)/'quality.json'
            raw = b'{"format":"monolith-kv16-quality-v1","rows":['
            path.write_bytes(raw)
            report, error = read_quality_report(path)
            self.assertIsNone(report)
            self.assertTrue(error)
            self.assertEqual(path.read_bytes(), raw)

    def test_missing_and_wrong_format_are_report_errors(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory)/'quality.json'
            self.assertIsNotNone(read_quality_report(path)[1])
            for value in ([], {}, {'format': 'wrong'}):
                path.write_text(json.dumps(value))
                self.assertIsNotNone(read_quality_report(path)[1])

    def test_complete_report_is_preserved(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory)/'quality.json'
            expected = {'format': 'monolith-kv16-quality-v1', 'rows': [], 'numerical_gates': {'mean_kl': False}}
            path.write_text(json.dumps(expected))
            self.assertEqual(read_quality_report(path), (expected, None))
