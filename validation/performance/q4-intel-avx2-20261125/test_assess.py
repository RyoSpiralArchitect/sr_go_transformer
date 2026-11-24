# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
import json
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

from assess import HERE, assess, probe


class IntelReceiptTests(unittest.TestCase):
    def test_archived_models(self):
        for model in ("olmo2-1b", "llama32-3b"):
            with self.subTest(model=model):
                result = assess(HERE/f"{model}.jsonl", model)
                self.assertEqual(result, json.loads((HERE/f"{model}.json").read_text()))
                for case in result["sessions"].values():
                    self.assertEqual(case["exact_replays"], 32)
                profiles = json.loads((HERE/"profiles"/f"{model}.json").read_text())
                for label, digest in result["profile_sha256"].items():
                    profile = profiles[label]
                    self.assertEqual(digest, profile["original_sha256"])
                    self.assertEqual(probe.sha(HERE/"profiles"/f"{model}-{label}.pb.gz"), profile["published_sha256"])
                    self.assertEqual(sum(profile["flat_cpu_ms"].values()), profile["total_cpu_ms"])

    def rows(self):
        return [json.loads(s) for s in (HERE/"olmo2-1b.jsonl").read_text().splitlines()]

    def test_v3_cli_outputs(self):
        for model, vocab in (("olmo2-1b", 100352), ("llama32-3b", 128256)):
            rows = [json.loads(s) for s in (HERE/f"v3-{model}.jsonl").read_text().splitlines()]
            self.assertEqual([(r["arm"], r["mode"]) for r in rows],
                             [("previous","1"), ("current","1"), ("current","all"), ("current","all+attention")])
            for row in rows:
                self.assertEqual((row["model"], row["vocab"], row["builds"]["target"]), (model, vocab, "linux/amd64/v3"))
                self.assertEqual(row["builds"], rows[0]["builds"])
                self.assertEqual(row["ids"], rows[0]["ids"])
                self.assertEqual(len(row["ids"]), 4)
                self.assertRegex(row["logits_sha256"], "^[0-9a-f]{64}$")
                self.assertEqual(row["logits_sha256"], rows[0]["logits_sha256"])

    def reject(self, rows, reason):
        with TemporaryDirectory() as directory:
            path = Path(directory)/"events.jsonl"
            path.write_text("".join(json.dumps(row)+"\n" for row in rows))
            with self.assertRaisesRegex(ValueError, reason):
                assess(path, "olmo2-1b")

    def test_wrong_hook_or_matrix(self):
        rows = self.rows()
        next(row for row in rows if row["event"] == "ready" and row["arm"] == "F")["result"]["quad"] = False
        self.reject(rows, "routing")
        rows = self.rows()
        next(row for row in rows if row["event"] == "ready" and row["arm"] == "B")["result"]["routing"]["attention"] = 0
        self.reject(rows, "routing")

    def test_schedule_and_signatures(self):
        rows = self.rows()
        first = next(i for i, row in enumerate(rows) if row["event"] == "sample")
        rows[first], rows[first+1] = rows[first+1], rows[first]
        self.reject(rows, "expected sample")
        rows = self.rows()
        next(row for row in rows if row["event"] == "sample")["result"]["Signature"]["Logits"] = "0"*64
        self.reject(rows, "decode signature")
        self.reject(self.rows()[:-1], "expected complete")
