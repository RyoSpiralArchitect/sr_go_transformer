"""Independently check retained Furnace probes and write compact ratios."""
import collections
import hashlib
import json
from pathlib import Path
import re
from statistics import median
import sys

root = Path(sys.argv[1])
def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def synthetic(filename, name, variants):
    source = root/filename
    values = collections.defaultdict(list)
    match = re.compile(r'BenchmarkQ4'+name+r'/(in\d+/out\d+/w\d+)/sample(\d+)/(\w+)-4\s+(\d+)\s+(\d+) ns/op\s+\d+ B/op\s+(\d+) allocs/op')
    for line in source.read_text().splitlines():
        m = match.match(line)
        if m:
            values[m[1]].append((int(m[2]),m[3],int(m[5]),int(m[6])))
    order = [0,1,2,3,3,2,1,0,2,0,3,1,1,3,0,2]
    assert len(values)==8
    rows = []
    for cell,samples in values.items():
        assert [(n,v) for n,v,_,_ in samples] == [(i,variants[j]) for i,j in enumerate(order)]
        medians = {v:median(ns for _,kind,ns,_ in samples if kind==v) for v in variants}
        rows.append(dict(cell=cell,median_ns=medians,
                         vs_pair={v:ns/medians['pair'] for v,ns in medians.items()},
                         all_reported_zero_allocs=all(n==0 for _,_,_,n in samples)))
    return dict(sha256=digest(source),cells=rows)

def model(id_):
    source = root/(id_+'-receipt.json')
    d = json.loads(source.read_text())
    meta = {'model':d['model'],'candidate':d['candidate'],'complete':d['complete'],
            'failure':d['failure'],'receipt_sha256':digest(source)}
    assert d['schedule']==[['before',[1,2]],['after',[1,2]],['after',[2,1]],['before',[2,1]]]
    ref = {}
    by = collections.defaultdict(list)
    for row in d['reports']:
        variant, idx, report = (row['variant'],row['process_index'],row['report'])
        assert report['case_order']==d['schedule'][idx][1]
        assert variant==d['schedule'][idx][0] and report['threads']==report['kernel_workers']==4
        for case in report['cases']:
            n = case['sessions']
            assert len(case['trials'])==3
            signature = (case['prompt_ids'],[{k:t[k] for k in ('logits_sha256','kv_sha256','token_ids')} for t in case['trials']])
            assert ref.setdefault(n,signature)==signature
            by[variant,n]+=case['trials']
    overlap = sum(s.get('cpu') in d['cpu_affinity'] and s.get('busy_seconds',0)>=.2 for report in d['background_samples'] for s in report['samples'])
    meta.update(numerical_identity=d['numerical_identity'],affinity=d['cpu_affinity'],background_overlap_samples=overlap)
    if d['complete'] and d['numerical_identity']:
        metrics = {}
        for n,name in [(1,'single'),(2,'two')]:
            a,b = [by[v,n] for v in ('before','after')]
            assert len(a)==len(b)==6
            for key in ('decode','prefill'):
                before,after = (median(t[key+'_seconds'] for t in trials) for trials in (a,b))
                limit = .95 if n==1 and key=='decode' else 1.05
                metrics[name+'_'+key] = dict(before_median_seconds=before,after_median_seconds=after,
                                            ratio=after/before,gate=after/before<=limit)
        meta.update(trial_count=24, metrics=metrics,
                    gate=not overlap and all(x['gate'] for x in metrics.values()),
                    peak_rss_bytes={v:max(r['resources']['peak_rss_bytes'] for r in d['reports'] if r['variant']==v) for v in ('before','after')})
    return meta

pvariants = ['pair','quad','pairDirect','quadDirect']
svariants = ['pair','quadSplit','pairDirect','quadDirect']
synthetics = {
    'p_core_diagnostic':synthetic('p-core-micro.txt','DirectLUT',pvariants),
    'e_core':synthetic('e-core-micro.txt','Split',svariants),
    'mac':synthetic('m4-split-micro.txt','Split',svariants),
    'gpt2_dimensions':synthetic('gpt2-shapes-micro.txt','Split',svariants)
}
def passes(rows,v):
    return all(x['all_reported_zero_allocs'] and x['vs_pair'][v]<=1.05 for x in rows) and sum(x['cell'].endswith('w4') and x['vs_pair'][v]<=.95 for x in rows)>=3
for name in ('e_core','gpt2_dimensions'):
    cells = synthetics[name]['cells']
    synthetics[name]['passes_vs_pair'] = {v:passes(cells,v) for v in svariants if v!='pair'}
data = dict(synthetic=synthetics,models=[model(id_) for id_ in ('gpt2','llama32-3b','mistral-7b-v03')])
(root/'decision.json').write_text(json.dumps(data,indent=2)+'\n')
for m in data['models']:
    print(m['model']['id'],m['complete'],m['numerical_identity'],m.get('gate'),m['background_overlap_samples'],
          {k:round(v['ratio'],5) for k,v in m.get('metrics',{}).items()})
print('Synthetic gates', {k:v.get('passes_vs_pair') for k,v in synthetics.items()})
