# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
import json
from pathlib import Path
import tempfile
import unittest

from assess import HERE, assess


class ReceiptTests(unittest.TestCase):
    def events(self):
        return [json.loads(line) for line in (HERE / "events.jsonl").read_text().splitlines()]

    def expect_rejection(self, rows, message):
        with tempfile.TemporaryDirectory() as out:
            path = Path(out) / "events.jsonl"
            path.write_text("".join(json.dumps(row) + "\n" for row in rows))
            with self.assertRaisesRegex(ValueError, message):
                assess(path)

    def test_archived_assessment(self):
        self.assertEqual(assess(HERE / "events.jsonl"), json.loads((HERE / "assessment.json").read_text()))

    def test_build_identity(self):
        for field in ("binary", "sources"):
            with self.subTest(field=field):
                rows = self.events()
                del rows[0][field]
                self.expect_rejection(rows, "measured build")
        rows = self.events()
        rows[0]["sources"]["cmd/monolith/resident_test.go"] = "0" * 64
        self.expect_rejection(rows, "measured build")

    def test_identically_incomplete_hashes_are_rejected(self):
        rows = self.events()
        for row in rows:
            if row["event"] == "sample":
                row["sample"]["Signature"].pop("Logits")
            elif row["event"] == "warm":
                row["neon"].pop("Logits")
                row["go"]["decode"].pop("Logits")
        self.expect_rejection(rows, "Logits digest")

    def test_numeric_fields_keep_their_types(self):
        for field in ("KVBytes", "Workspace"):
            with self.subTest(field=field):
                rows = self.events()
                sig = next(r["sample"]["Signature"] for r in rows if r["event"] == "sample")
                sig[field] = float(sig[field])
                self.expect_rejection(rows, "byte count")


if __name__ == "__main__":
    unittest.main()
