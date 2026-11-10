"""Run frozen Linux Q4 probes, one resident model per process."""
import argparse
import json
import os
import platform
from pathlib import Path
import subprocess
import threading
import time
from compare_inference import isolated_go_environment, numerical_signature, process_schedule, validate_case_order
from quant_quality import sha, run_measured

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--model-id', action='append', required=True)
parser.add_argument('--output', required=True)
parser.add_argument('--candidate', default='after')
parser.add_argument('--build', default='build.json')
parser.add_argument('--models', default='results/models.json')
args = parser.parse_args()
root = Path(__file__).resolve().parent
build = json.loads((root/args.build).read_text())
out = root/'results'/args.output
out.mkdir(exist_ok=False)
affinity = sorted(os.sched_getaffinity(0))
if affinity != [16,17,18,19]:
    raise RuntimeError('Expected affinity 16–19')
for name,digest in build['files'].items():
    if sha(root/name)!=digest:
        raise RuntimeError('build hash mismatch: '+name)
hub = Path.home()/'.cache/huggingface/hub'
env = isolated_go_environment()
env.update(CUDA_VISIBLE_DEVICES='', MONOLITH_PERF_CORPUS=str(root/'corpus.json'), MONOLITH_PERF_FORMAT='q4-mixed')
schedule = process_schedule('balanced')

def monitor(pid, halt, output):
    ticks = os.sysconf('SC_CLK_TCK')
    def sample():
        fields = Path(f'/proc/{pid}/stat').read_text().rsplit(')',1)[1].split()
        return (int(fields[11])+int(fields[12]), int(fields[36]), time.monotonic())
    try:
        prev = sample()
        while not halt.wait(1):
            now = sample()
            output.append(dict(cpu=now[1], busy_seconds=(now[0]-prev[0])/ticks,
                               sample_seconds=now[2]-prev[2]))
            prev = now
    except OSError:
        output.append({'process_unavailable': True})

plans = {m['id']:m for m in json.loads((root/args.models).read_text())}
for id_ in args.model_id:
    m = plans[id_]
    folder = hub/('models--'+m['repo'].replace('/','--'))/'snapshots'/m['revision']
    if 'asset_dir' in m:
        folder = Path(m['asset_dir'])
    d = out/id_
    d.mkdir()
    print(id_, 'start', flush=True)
    def verify():
        for name,digest in m['files'].items():
            if sha(folder/name)!=digest:
                raise ValueError('model hash mismatch: '+name)
    verify()
    env['MONOLITH_PERF_MODEL'] = str(folder)
    reports = []
    expected = None
    same = True
    failure = None
    monitored = []
    for index,(variant, order) in enumerate(schedule):
        label = 'before' if variant=='before' else args.candidate
        p = d/f'{index}-{label}'
        env['MONOLITH_PERF_OUTPUT'] = str(p.with_suffix('.json'))
        env['MONOLITH_PERF_CASE_ORDER'] = ','.join(map(str,order))
        stop = threading.Event()
        observations = []
        sampler = threading.Thread(target=monitor,args=(2189,stop,observations))
        sampler.start()
        try:
            with p.with_suffix('.log').open('x') as log:
                resources = run_measured([str(root/(label+'.test')),'-test.run=^TestHFInferencePerformance$',
                    '-test.v','-test.timeout=11m'],env=env,cwd=root,stdout=log,stderr=subprocess.STDOUT,
                    timeout=700,outcome_path=Path(str(p)+'.resources.json'))
            r = json.loads(p.with_suffix('.json').read_text())
            validate_case_order(r,order)
            if r['plan']['weight_format']!='q4-mixed':
                raise ValueError('unexpected weight format')
            signature = numerical_signature(r)
            if expected is None:
                expected = signature
            same = same and signature==expected
            reports.append(dict(variant=variant,process_index=index,report=r,resources=resources))
            print(id_,index,label,'complete',flush=True)
        except (subprocess.CalledProcessError,subprocess.TimeoutExpired,OSError,ValueError,RuntimeError) as exc:
            failure = str(exc)
            break
        finally:
            stop.set()
            sampler.join()
            monitored.append(dict(process_index=index,samples=observations))
    verify()
    for label in ('before',args.candidate):
        name = label+'.test'
        if sha(root/name)!=build['files'][name]:
            raise ValueError('binary changed: '+name)
    complete = len(reports)==4
    receipt = dict(format='monolith-furnace-q4-comparison-v1',model=m,build=build,
                   candidate=args.candidate,host=platform.system()+'/'+platform.machine(),
                   cpu_affinity=affinity,schedule=schedule,complete=complete,
                   numerical_identity=complete and same,failure=failure,reports=reports,
                   background_samples=monitored)
    with (d/'receipt.json').open('x') as f:
        json.dump(receipt,f,indent=2,allow_nan=False)
        f.write('\n')
    print(id_,'retained',complete,receipt['numerical_identity'],flush=True)
