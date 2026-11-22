import contextlib
import io
import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from assess_dispatch_logs import log_header, main, read_samples
from quant_quality import sha


class DispatchLogTests(unittest.TestCase):
    def test_pass_requires_complete_nonzero_samples(self):
        row = 'BenchmarkFixture-4 100 125.5 ns/op 96 B/op 1 allocs/op\n'
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'log.txt'
            path.write_text(row + 'PASS\n')
            self.assertEqual(read_samples(path)[0]['ns_per_op'], 125.5)
            for text in (row, 'PASS\n', row + 'FAIL\nPASS\n',
                         row + 'PASS\npanic: bad\n', row.replace('125.5', '0') + 'PASS\n'):
                with self.subTest(text=text), self.assertRaises(ValueError):
                    path.write_text(text)
                    read_samples(path)

    def test_import_binds_native_sources_and_checks_shared_harness(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            before, after = root / 'before', root / 'after'
            for build in (before, after):
                build.mkdir()
                for name in ('monolith.go', 'go.mod', 'go.sum', 'probe_test.go', 'probe'):
                    (build / name).write_text(name)
            (after / 'leaf_arm64.go').write_text('native declaration')
            (after / 'leaf_arm64.s').write_text('assembly')
            for index, label in enumerate(('before', 'new', 'new', 'before')):
                for cohort in ('linear', 'generate', 'quant'):
                    row = f'Benchmark{cohort}-4 100 125.5 ns/op 0 B/op 0 allocs/op\n'
                    (root / f'case-{index}-{label}-{cohort}.txt').write_text(
                        'goos: linux\ngoarch: amd64\ncpu: fixture\n' + row * 2 + 'PASS\n')
            out = root / 'receipt.json'
            args = ['assess', '--logs', str(root), '--prefix', 'case', '--candidate', 'new',
                    '--before-build', str(before), '--after-build', str(after),
                    '--before-binary', str(before/'probe'), '--after-binary', str(after/'probe'),
                    '--output', str(out)]
            with patch.object(sys, 'argv', args), contextlib.redirect_stdout(io.StringIO()):
                main()
                builds = json.loads(out.read_text())['builds']
                self.assertEqual(builds['after']['inputs_sha256']['leaf_arm64.s'], sha(after/'leaf_arm64.s'))
                self.assertNotIn('leaf_arm64.s', builds['before']['inputs_sha256'])
                (after / 'probe_test.go').write_text('different harness')
                with self.assertRaisesRegex(ValueError, 'shared sources'):
                    main()

    def test_headers_must_be_present_once(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'log.txt'
            text = 'goos: linux\ngoarch: amd64\ncpu: fixture\n'
            path.write_text(text)
            self.assertEqual(log_header(path), dict(goos='linux', goarch='amd64', cpu='fixture'))
            for invalid in ('', text + 'cpu: duplicate\n', text.replace('goarch: amd64\n', '')):
                with self.subTest(text=invalid), self.assertRaises(ValueError):
                    path.write_text(invalid)
                    log_header(path)


if __name__ == '__main__':
    unittest.main()
