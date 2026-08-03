/* ============================================================
 * sysctlbypass.c - sysctl hook for process inspection (fishhook)
 * Blocks: CTL_KERN + KERN_PROC, KERN_PROCARGS, KERN_PROC_ALL
 * ============================================================ */

#include "fishhook.h"
#include <sys/sysctl.h>
#include <string.h>

static int (*orig_sysctl)(int *name, u_int namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen);

static int hook_sysctl(int *name, u_int namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen) {
    if (namelen >= 2 && name[0] == CTL_KERN) {
        if (name[1] == KERN_PROC && namelen >= 4 && name[2] == KERN_PROC_ALL) {
            if (oldp && oldlenp) {
                memset(oldp, 0, *oldlenp);
                *oldlenp = 0;
            }
            return 0;
        }
    }
    return orig_sysctl(name, namelen, oldp, oldlenp, newp, newlen);
}

/* ---- INIT ---- */
void sysctlbypass_init(void) {
    struct rebinding rebindings[] = {
        {"sysctl", (void *)hook_sysctl, (void **)&orig_sysctl},
    };
    rebind_symbols(rebindings, sizeof(rebindings) / sizeof(struct rebinding));
}