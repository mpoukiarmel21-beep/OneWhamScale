/* ============================================================
 * spawnbypass.c - Spawn/fork/process bypass hooks (fishhook)
 * Hooks: fork, vfork, posix_spawn, posix_spawnp, system
 * Blocks jailbreak tool detection via forking
 * ============================================================ */

#include "utility.h"
#include "fishhook.h"
#include <spawn.h>
#include <errno.h>
#include <stdarg.h>
#include <unistd.h>

static pid_t (*orig_fork)(void);
static pid_t hook_fork(void) { return -1; }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
static pid_t (*orig_vfork)(void);
static pid_t hook_vfork(void) { return -1; }
#pragma clang diagnostic pop

static int (*orig_posix_spawn)(pid_t *pid, const char *path,
    const posix_spawn_file_actions_t *file_actions,
    const posix_spawnattr_t *attrp,
    char *const argv[], char *const envp[]);
static int hook_posix_spawn(pid_t *pid, const char *path,
    const posix_spawn_file_actions_t *file_actions,
    const posix_spawnattr_t *attrp,
    char *const argv[], char *const envp[]) {
    if (path && isKnownSpawnPath(path)) { errno = EACCES; return -1; }
    if (path && isKnownJailbreakApp(path)) { errno = EACCES; return -1; }
    return orig_posix_spawn(pid, path, file_actions, attrp, argv, envp);
}

static int (*orig_posix_spawnp)(pid_t *pid, const char *file,
    const posix_spawn_file_actions_t *file_actions,
    const posix_spawnattr_t *attrp,
    char *const argv[], char *const envp[]);
static int hook_posix_spawnp(pid_t *pid, const char *file,
    const posix_spawn_file_actions_t *file_actions,
    const posix_spawnattr_t *attrp,
    char *const argv[], char *const envp[]) {
    if (file && isKnownSpawnPath(file)) { errno = EACCES; return -1; }
    if (file && isKnownJailbreakApp(file)) { errno = EACCES; return -1; }
    return orig_posix_spawnp(pid, file, file_actions, attrp, argv, envp);
}

/* ---- INIT ---- */
void spawnbypass_init(void) {
    struct rebinding rebindings[] = {
        {"fork", (void *)hook_fork, (void **)&orig_fork},
        {"vfork", (void *)hook_vfork, (void **)&orig_vfork},
        {"posix_spawn", (void *)hook_posix_spawn, (void **)&orig_posix_spawn},
        {"posix_spawnp", (void *)hook_posix_spawnp, (void **)&orig_posix_spawnp},
    };
    rebind_symbols(rebindings, sizeof(rebindings) / sizeof(struct rebinding));
}