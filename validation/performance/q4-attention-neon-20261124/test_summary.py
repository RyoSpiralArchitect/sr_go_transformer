# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
import json
from pathlib import Path
import tempfile
import unittest

import probe
from summarize import summarize
from verify_cli import stage_model


class AttentionReceiptTests(unittest.TestCase):
    def rows(self):
        return [json.loads(line) for line in (probe.HERE/"events.jsonl").read_text().splitlines()]

    def reject(self, rows, message):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory)/"events.jsonl"
            path.write_text("".join(json.dumps(row) + "\n" for row in rows))
            with self.assertRaisesRegex(ValueError, message):
                summarize(path)

    def test_archive(self):
        result = summarize(probe.HERE/"events.jsonl")
        self.assertEqual(result, json.loads((probe.HERE/"assessment.json").read_text()))
        allocated = [n for p in result["projections"].values() for samples in p["bytes_per_op"].values() for n in samples]
        self.assertEqual(len(allocated), 96)
        self.assertEqual(sorted(n for n in allocated if n), [2, 2, 665])

    def test_cli_uses_only_verified_assets(self):
        with tempfile.TemporaryDirectory() as source, tempfile.TemporaryDirectory() as dest:
            source, dest = Path(source), Path(dest)
            (source/"model.safetensors").write_bytes(b"pinned")
            (source/"model.safetensors.index.json").write_text("{}")
            files = {"model.safetensors": probe.sha(source/"model.safetensors")}
            stage_model(source, dest, files)
            self.assertEqual({p.name for p in dest.iterdir()}, set(files))
            self.assertEqual((dest/"model.safetensors").read_bytes(), b"pinned")
            (source/"model.safetensors").write_bytes(b"other")
            with self.assertRaisesRegex(ValueError, "snapshot hash differs"):
                stage_model(source, dest, files)

    def test_wrong_route_or_artifact(self):
        rows = self.rows()
        next(r for r in rows if r["event"] == "ready" and r["arm"] == "B")["ready"]["routing"]["attention"] = 0
        self.reject(rows, "routing")
        rows = self.rows()
        rows[0]["sources"]["cmd/monolith/monolith.go"] = "0" * 64
        self.reject(rows, "identity")

    def test_order_and_completeness(self):
        rows = self.rows()
        index = next(i for i, r in enumerate(rows) if r["event"] == "sample")
        rows[index], rows[index+1] = rows[index+1], rows[index]
        self.reject(rows, "expected sample")
        self.reject(self.rows()[:-1], "expected complete")

    def test_missing_digest(self):
        rows = self.rows()
        next(r for r in rows if r["event"] == "sample")["sample"]["Signature"].pop("KV")
        self.reject(rows, "KV digest")
