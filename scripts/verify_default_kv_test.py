import copy
import unittest
from verify_default_kv import reference_signature


class PredecessorBindingTests(unittest.TestCase):
    def fixture(self):
        report=dict(plan={},threads=4,kernel_workers=4,context=128,prefill_tokens_per_session=8,
            decode_steps=7,generated_ids_per_session=8,cases=[dict(sessions=1,prompt_ids=[[1]],trials=[dict(logits_sha256='a',kv_sha256='b',token_ids=[[2]])])])
        return dict(numerical_identity=True,builds={'after':{'inputs_sha256':{'monolith.go':'runtime','inference_perf_test.go':'harness'}}},reports=[dict(variant='after',report=report)])

    def test_wrong_source_cannot_supply_parity(self):
        with self.assertRaises(ValueError):reference_signature(self.fixture(),'different','harness')
        with self.assertRaises(ValueError):reference_signature(self.fixture(),'runtime','different')

    def test_disagreement_and_failed_reference_rejected(self):
        receipt=self.fixture();receipt['numerical_identity']=False
        with self.assertRaises(ValueError):reference_signature(receipt,'runtime','harness')
        receipt=self.fixture();other=copy.deepcopy(receipt['reports'][0]);other['report']['cases'][0]['trials'][0]['kv_sha256']='different';receipt['reports'].append(other)
        with self.assertRaises(ValueError):reference_signature(receipt,'runtime','harness')

    def test_bound_reference_returns_signature(self):
        self.assertEqual(reference_signature(self.fixture(),'runtime','harness')['threads'],4)
