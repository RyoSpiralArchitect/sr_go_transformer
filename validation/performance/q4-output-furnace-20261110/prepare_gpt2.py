"""Verify the pre-existing GPT-2 asset directory against the repository catalog."""
import json
from pathlib import Path
from quant_quality import sha
root = Path(__file__).resolve().parent
catalog = json.loads((root/'model-profiles.json').read_text())
model = next(m for m in catalog['models'] if m['id']=='gpt2')
assets = Path.home()/'scratch/ltt-furnace-20261017/assets/base-gpt2-124m'
for name,digest in model['files'].items():
    if sha(assets/name)!=digest:
        raise ValueError('GPT-2 asset differs from catalog: '+name)
models = json.loads((root/'results/models.json').read_text())
models.append(dict(id='gpt2', repo=model['repo'], revision=model['revision'], files=model['files'],
                   asset_dir=str(assets), dimensions={'model_type':'gpt2','hidden_size':768,
                   'intermediate_size':3072,'num_hidden_layers':12,'vocab_size':50257}))
with (root/'results/models-extra.json').open('x') as f:
    json.dump(models,f,indent=2)
    f.write('\n')
