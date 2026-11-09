import argparse
import json
import re
from statistics import median

from summarize_q4_invocation import ROOT, digest, read_bench


def summarize(paths, expected_cases=12):
    cases = {}
    for path in paths:
        rows = read_bench(path, expected_cases)
        baselines = {name.removesuffix('/baseline') for name in rows if name.endswith('/baseline')}
        candidates = {name.removesuffix('/persistent') for name in rows if name.endswith('/persistent')}
        if baselines != candidates or len(baselines) * 2 != len(rows):
            raise ValueError(f'{path}: missing or unexpected comparison modes')
        if cases and set(cases) != baselines:
            raise ValueError(f'{path}: mismatched case set')
        for name in sorted(baselines):
            before, after = rows[name + '/baseline'], rows[name + '/persistent']
            case = cases.setdefault(name, {'baseline': [], 'persistent': [], 'ratios': []})
            case['baseline'].append(before)
            case['persistent'].append(after)
            case['ratios'].append(after['ns'] / before['ns'])
    for case in cases.values():
        case['median_ratio'] = median(case['ratios'])
    return cases


def inspect_assembly(path):
    text = path.read_text()
    instructions = []
    for line in text.splitlines():
        match = re.search(r'\s+(0x[0-9a-f]+)\s+[0-9a-f]{8}\s+(.+)', line)
        if match:
            instructions.append((int(match[1], 16), match[2].strip()))
    loops = []
    for address, instruction in instructions:
        branch = re.fullmatch(r'BHI -(\d+)\(PC\)', instruction)
        if not branch:
            continue
        start = address - int(branch[1]) * 4
        body = [op for pc, op in instructions if start <= pc <= address]
        if all(sum(op.startswith(mnemonic + ' ') for op in body) == 4 for mnemonic in ('FMADDS', 'SCVTFWS', 'MOVB')):
            loops.append({
                'start': hex(start), 'backedge': hex(address),
                'static_instructions': len(body),
                'stack_loads': [op for op in body if re.match(r'MOVD \d+\(RSP\),', op)],
            })
    if len(loops) != 1:
        raise ValueError(f'{path}: expected one four-term scalar loop, got {len(loops)}')
    frames = re.findall(r'SUB \$(\d+), RSP, R20', text)
    if len(frames) != 1:
        raise ValueError(f'{path}: expected one frame')
    return {
        'sha256': digest(path), 'frame_bytes': int(frames[0]),
        'panic_bounds_call_sites': text.count('CALL runtime.panicBounds(SB)'),
        'scalar_loop': loops[0],
        'scope': 'Static disassembly only; not retired instruction counts, hardware counters or a causal timing estimate.',
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--prefix', required=True)
    parser.add_argument('--binary', required=True)
    parser.add_argument('--probe-patch', required=True)
    parser.add_argument('--assembly', action='append', default=[])
    parser.add_argument('--cases', type=int, default=12)
    parser.add_argument('--runs', type=int, default=3)
    args = parser.parse_args()
    if args.cases < 2 or args.runs < 1:
        parser.error('positive runs and at least two cases required')
    paths = [ROOT / 'validation/performance' / f'{args.prefix}-20261109-run{run}.txt' for run in range(1, args.runs + 1)]
    result = {
        'protocol': 'q8-codegen-same-binary-kernel-v1',
        'scope': 'Kernel probes only, not generation. Cold probe/callback construction excluded. See selection receipt for process order, GOMAXPROCS and attribution limitations.',
        'binary': args.binary,
        'binary_sha256': digest(ROOT / args.binary),
        'probe_patch': args.probe_patch,
        'probe_patch_sha256': digest(ROOT / args.probe_patch),
        'raw_file_sha256': {path.name: digest(path) for path in paths},
        'cases': summarize(paths, args.cases),
        'assembly': {path: inspect_assembly(ROOT / path) for path in args.assembly},
    }
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
