import os
import time
from pathlib import Path


def optional(path):
    try:
        return Path(path).read_text().strip()
    except (FileNotFoundError, PermissionError, OSError):
        return None


def machine(cpus):
    frequencies = {str(cpu): {key: optional(f"/sys/devices/system/cpu/cpu{cpu}/cpufreq/{key}")
                              for key in ("scaling_cur_freq", "cpuinfo_max_freq", "scaling_governor")}
                   for cpu in cpus}
    thermal = {}
    for directory in Path("/sys/class/hwmon").glob("hwmon*"):
        if optional(directory / "name") == "coretemp":
            for value in directory.glob("temp*_input"):
                thermal[str(value)] = {"millidegrees_C": optional(value), "label": optional(value.with_name(value.name.replace("_input", "_label")))}
    return {"monotonic_ns": time.perf_counter_ns(), "cpufreq_kHz": frequencies, "coretemp": thermal,
            "cpu_core_pmu_cpus": optional("/sys/bus/event_source/devices/cpu_core/cpus"),
            "cpu_atom_pmu_cpus": optional("/sys/bus/event_source/devices/cpu_atom/cpus"),
            "loadavg": os.getloadavg(), "proc_stat": optional("/proc/stat"),
            "memory_pressure": optional("/proc/pressure/memory"), "cpu_pressure": optional("/proc/pressure/cpu")}


def snapshot(helper, pid):
    raw = Path(f"/proc/{pid}/stat").read_text()
    fields = raw[raw.rfind(")") + 2:].split()
    io = {key: int(value) for key, value in (line.split(":") for line in Path(f"/proc/{pid}/io").read_text().splitlines())}
    affinity = sorted(os.sched_getaffinity(pid))
    return {"pid": pid, "start_ticks": int(fields[19]), "clock_ticks_per_second": os.sysconf("SC_CLK_TCK"),
            "user_ticks": int(fields[11]), "system_ticks": int(fields[12]), "minor_faults": int(fields[7]),
            "major_faults": int(fields[9]), "threads": int(fields[17]), "io": io, "affinity": affinity,
            "thread_affinities": {path.name: sorted(os.sched_getaffinity(int(path.name))) for path in Path(f"/proc/{pid}/task").iterdir()},
            "machine": machine(affinity), "raw_proc_stat": raw, "observed_monotonic_ns": time.perf_counter_ns()}


def difference(before, after, wall_ns):
    if (before["pid"], before["start_ticks"], before["clock_ticks_per_second"]) != (after["pid"], after["start_ticks"], after["clock_ticks_per_second"]):
        raise ValueError("process identity/clock changed")
    if before["affinity"] != after["affinity"] or any(value != snapshot["affinity"] for snapshot in (before, after) for value in snapshot["thread_affinities"].values()):
        raise ValueError("thread CPU affinity changed")
    delta = {key: after[key] - before[key] for key in ("user_ticks", "system_ticks", "minor_faults", "major_faults")}
    if min(delta.values()) < 0 or wall_ns <= 0:
        raise ValueError("invalid process counters/wall time")
    cpu_seconds = (delta["user_ticks"] + delta["system_ticks"]) / before["clock_ticks_per_second"]
    return {"raw_delta": delta, "cpu_seconds": cpu_seconds, "mean_cpu_parallelism": cpu_seconds * 1e9 / wall_ns,
            "io_delta": {key: after["io"][key] - before["io"][key] for key in before["io"]},
            "hardware_counters": "Unavailable: perf_event_paranoid=4; no policy/capability changes"}
