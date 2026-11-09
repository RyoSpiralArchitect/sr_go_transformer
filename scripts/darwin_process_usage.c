#include <errno.h>
#include <inttypes.h>
#include <limits.h>
#include <libproc.h>
#include <mach/mach_time.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/resource.h>
#include <unistd.h>

int main(int argc, char **argv) {
    char *end = NULL;
    long requested = argc == 1 ? getpid() : strtol(argv[1], &end, 10);
    if (argc > 2 || requested <= 0 || requested > INT_MAX || (argc == 2 && (!end || *end))) {
        fprintf(stderr, "usage: darwin_process_usage [pid]\n");
        return 2;
    }
    struct rusage_info_v6 info = {0};
    mach_timebase_info_data_t base;
    if (mach_timebase_info(&base) != KERN_SUCCESS || base.denom == 0) {
        fprintf(stderr, "mach timebase unavailable\n");
        return 1;
    }
    if (proc_pid_rusage((int)requested, RUSAGE_INFO_V6, (rusage_info_t *)&info) != 0) {
        perror("proc_pid_rusage");
        return 1;
    }
    printf("{\"pid\":%ld,\"timebase_numer\":%u,\"timebase_denom\":%u", requested, base.numer, base.denom);
#define EMIT(field) printf(",\"" #field "\":%" PRIu64, info.field)
    EMIT(ri_user_time);
    EMIT(ri_system_time);
    EMIT(ri_user_ptime);
    EMIT(ri_system_ptime);
    EMIT(ri_instructions);
    EMIT(ri_cycles);
    EMIT(ri_pinstructions);
    EMIT(ri_pcycles);
    EMIT(ri_runnable_time);
    EMIT(ri_pageins);
    EMIT(ri_diskio_bytesread);
    EMIT(ri_diskio_byteswritten);
    EMIT(ri_cpu_time_qos_default);
    EMIT(ri_cpu_time_qos_maintenance);
    EMIT(ri_cpu_time_qos_background);
    EMIT(ri_cpu_time_qos_utility);
    EMIT(ri_cpu_time_qos_legacy);
    EMIT(ri_cpu_time_qos_user_initiated);
    EMIT(ri_cpu_time_qos_user_interactive);
    EMIT(ri_phys_footprint);
    EMIT(ri_resident_size);
#undef EMIT
    printf("}\n");
    return 0;
}
