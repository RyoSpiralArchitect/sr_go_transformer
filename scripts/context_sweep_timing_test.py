import copy
from pathlib import Path
import tempfile
import unittest

from context_sweep_timing import instrument_context_sweep, summarize_stages


class ContextStageTests(unittest.TestCase):
    def test_only_the_copied_inference_function_is_instrumented(self):
        root = Path(__file__).resolve().parents[1]
        original = (root/'cmd/monolith/monolith.go').read_text()
        start = original.index('func (m *Model) prefillSelected(')
        end = original.index('\nfunc (m *Model) Step(', start)
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory)/'monolith.go'
            source.write_text(original)
            instrument_context_sweep(source)
            modified = source.read_text()
            self.assertTrue(modified.startswith(original[:start]))
            self.assertTrue(modified.endswith(original[end:]))
            self.assertEqual(modified.count('contextSweepTimedProjection(timing, false,'), 7)
            self.assertEqual(modified.count('contextSweepTimedProjection(timing, true,'), 1)
            self.assertEqual(modified.count('contextSweepTimedAttention(timing,'), 1)
            with self.assertRaises(ValueError):
                instrument_context_sweep(source)

    @staticmethod
    def samples():
        rows = []
        for enabled in (False, True, True, False, True, False, False, True):
            row = dict(exact=True, decode={'decode_step_seconds': [.002]*7})
            if enabled:
                row['timing'] = {
                    'layer_projections': dict(elapsed_ns=7_000_000, calls=196),
                    'attention': dict(elapsed_ns=3_500_000, calls=28),
                    'output_projection': dict(elapsed_ns=1_750_000, calls=7),
                }
            rows.append(row)
        return rows

    def test_sample_partition_and_timer_overhead_are_separate(self):
        summary = summarize_stages(self.samples())
        self.assertEqual(summary['control_ms_per_call'], 2)
        self.assertEqual(summary['timed_ms_per_call'], 2)
        self.assertEqual(summary['timed_over_control'], 1)
        self.assertEqual(summary['stage_ms_per_call'], dict(
            layer_projections=1, attention=.5, output_projection=.25, other=.25))

    def test_incomplete_misordered_or_nonfinite_samples_fail(self):
        data = self.samples()
        invalid = [data[:-1]]
        bad = copy.deepcopy(data)
        bad[0]['timing'] = bad[1]['timing']
        invalid.append(bad)
        for value in (0, float('inf'), float('nan')):
            bad = copy.deepcopy(data)
            bad[0]['decode']['decode_step_seconds'][0] = value
            invalid.append(bad)
        bad = copy.deepcopy(data)
        bad[1]['timing']['attention']['elapsed_ns'] = 99_000_000
        invalid.append(bad)
        bad = copy.deepcopy(data)
        bad[1]['exact'] = False
        invalid.append(bad)
        for rows in invalid:
            with self.assertRaises(ValueError):
                summarize_stages(rows)


if __name__ == '__main__':
    unittest.main()
