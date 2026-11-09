import argparse
import json
import subprocess
import sys
import time
from contextlib import suppress
from pathlib import Path

COUNTERS = ("ri_user_time", "ri_system_time", "ri_user_ptime", "ri_system_ptime", "ri_instructions", "ri_cycles",
            "ri_pinstructions", "ri_pcycles", "ri_runnable_time", "ri_pageins", "ri_diskio_bytesread", "ri_diskio_byteswritten")


def snapshot(helper, pid):
    value = json.loads(subprocess.check_output([str(helper), str(pid)]))
    if value["pid"] != pid or value["timebase_numer"] <= 0 or value["timebase_denom"] <= 0:
        raise ValueError("invalid process snapshot identity/timebase")
    value["observed_monotonic_ns"] = time.perf_counter_ns()
    return value


def difference(before, after, wall_ns):
    if before["pid"] != after["pid"] or (before["timebase_numer"], before["timebase_denom"]) != (after["timebase_numer"], after["timebase_denom"]):
        raise ValueError("process identity/timebase changed")
    keys = (*COUNTERS, *(key for key in before if key.startswith("ri_cpu_time_qos_")))
    delta = {key: after[key] - before[key] for key in keys}
    if any(value < 0 for value in delta.values()) or wall_ns <= 0:
        raise ValueError("nonmonotonic counters or invalid wall time")
    ticks = delta["ri_user_time"] + delta["ri_system_time"]
    cpu_ns = ticks * before["timebase_numer"] / before["timebase_denom"]
    if cpu_ns <= 0 or delta["ri_instructions"] <= 0 or delta["ri_cycles"] <= 0:
        raise ValueError("CPU/instruction/cycle counters unavailable")
    return {"raw_delta": delta, "cpu_seconds": cpu_ns / 1e9, "mean_cpu_parallelism": cpu_ns / wall_ns,
            "performance_cpu_fraction": (delta["ri_user_ptime"] + delta["ri_system_ptime"]) / ticks,
            "performance_instruction_fraction": delta["ri_pinstructions"] / delta["ri_instructions"],
            "cycles_per_instruction": delta["ri_cycles"] / delta["ri_instructions"],
            "cycles_per_cpu_ns": delta["ri_cycles"] / cpu_ns,
            "qos_cpu_fractions": {key: value / ticks for key, value in delta.items() if key.startswith("ri_cpu_time_qos_")}}


def calibrate(helper):
    code = """import json,sys,time
print('ready',flush=True)
sys.stdin.readline()
start=time.process_time_ns()
stop=start+500000000
value=0
while time.process_time_ns()<stop:
    value+=1
elapsed=time.process_time_ns()-start
print(json.dumps({'cpu_ns':elapsed,'value':value}),flush=True)
sys.stdin.readline()
"""
    with subprocess.Popen([sys.executable, "-c", code], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True) as process:
        try:
            if process.stdout.readline().strip() != "ready":
                raise RuntimeError("calibration child failed")
            before = snapshot(helper, process.pid)
            clock = time.perf_counter_ns()
            process.stdin.write("go\n")
            process.stdin.flush()
            reported = json.loads(process.stdout.readline())
            wall_ns = time.perf_counter_ns() - clock
            after = snapshot(helper, process.pid)
            delta = difference(before, after, wall_ns)
            ratio = delta["cpu_seconds"] * 1e9 / reported["cpu_ns"]
            if not 0.95 <= ratio <= 1.10:
                raise ValueError("Mach timebase conversion disagrees with process_time_ns")
            return {"before": before, "after": after, "derived": delta, "reported": reported, "cpu_conversion_ratio": ratio}
        finally:
            with suppress(BrokenPipeError):
                process.stdin.write("exit\n")
                process.stdin.flush()
            with suppress(BrokenPipeError):
                process.stdin.close()
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()
                raise RuntimeError("calibration child did not exit")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--helper", type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(calibrate(args.helper.resolve()), indent=2))


if __name__ == "__main__":
    main()
