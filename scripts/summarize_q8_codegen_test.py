import tempfile
import unittest
from pathlib import Path

from summarize_q8_codegen import ROOT, inspect_assembly, summarize


class CodegenSummaryTests(unittest.TestCase):
    def test_retained_scalar_loop_evidence(self):
        for name, count, loads in [('before', 31, 0), ('rejected', 32, 1), ('compact', 32, 1), ('cached', 31, 0)]:
            with self.subTest(name=name):
                result = inspect_assembly(ROOT / f'validation/performance/q8-codegen-{name}-20261109.asm')
                self.assertEqual(result['frame_bytes'], 304)
                self.assertEqual(result['scalar_loop']['static_instructions'], count)
                self.assertEqual(len(result['scalar_loop']['stack_loads']), loads)

    def test_preserves_samples_and_pairs_modes(self):
        with tempfile.TemporaryDirectory() as directory:
            paths = [Path(directory) / str(i) for i in range(2)]
            paths[0].write_text('BenchmarkQ8/a/baseline-1 10 100 ns/op 112 B/op 1 allocs/op\nBenchmarkQ8/a/persistent-1 10 110 ns/op 0 B/op 0 allocs/op\n')
            paths[1].write_text('BenchmarkQ8/a/persistent-1 10 90 ns/op 0 B/op 0 allocs/op\nBenchmarkQ8/a/baseline-1 10 100 ns/op 112 B/op 1 allocs/op\n')
            case = summarize(paths, 2)['BenchmarkQ8/a']
            self.assertEqual(case['ratios'], [1.1, 0.9])
            self.assertEqual(case['median_ratio'], 1.0)
            self.assertEqual(len(case['baseline']), 2)
            self.assertEqual(case['persistent'][0]['allocs'], 0)

    def test_rejects_unpaired_modes(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'run'
            path.write_text('BenchmarkQ8/a/baseline-1 10 100 ns/op 112 B/op 1 allocs/op\nBenchmarkQ8/b/persistent-1 10 110 ns/op 0 B/op 0 allocs/op\n')
            with self.assertRaises(ValueError):
                summarize([path], 2)

    def test_rejects_changed_cases(self):
        with tempfile.TemporaryDirectory() as directory:
            paths = [Path(directory) / str(i) for i in range(2)]
            for i, path in enumerate(paths):
                path.write_text(f'BenchmarkQ8/{i}/baseline-1 10 100 ns/op 112 B/op 1 allocs/op\nBenchmarkQ8/{i}/persistent-1 10 110 ns/op 0 B/op 0 allocs/op\n')
            with self.assertRaises(ValueError):
                summarize(paths, 2)


if __name__ == '__main__':
    unittest.main()
