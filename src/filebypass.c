/* ============================================================
 * filebypass.c - File system bypass hooks (Substrate)
 * Hooks: stat, lstat, statfs, access, fopen, opendir, open, openat
 * ============================================================ */

#include "utility.h"
#include <substrate.h>
#include <dlfcn.h>
#include <errno.h>
#include <stdarg.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/mount.h>
#include <dirent.h>

static int (*orig_stat)(const char *path, struct stat *buf);
static int hook_stat(const char *path, struct stat *buf) {
    if (path && isKnownBadPath(path)) { errno = ENOENT; return -1; }
    return orig_stat(path, buf);
}

static int (*orig_lstat)(const char *path, struct stat *buf);
static int hook_lstat(const char *path, struct stat *buf) {
    if (path && isKnownBadPath(path)) { errno = ENOENT; return -1; }
    return orig_lstat(path, buf);
}

static int (*orig_statfs)(const char *path, struct statfs *buf);
static int hook_statfs(const char *path, struct statfs *buf) {
    if (path && isKnownBadPath(path)) { errno = ENOENT; return -1; }
    return orig_statfs(path, buf);
}

static int (*orig_access)(const char *path, int amode);
static int hook_access(const char *path, int amode) {
    if (path && isKnownBadPath(path)) { errno = ENOENT; return -1; }
    return orig_access(path, amode);
}

static FILE *(*orig_fopen)(const char *filename, const char *mode);
static FILE *hook_fopen(const char *filename, const char *mode) {
    if (filename && isKnownBadPath(filename)) { errno = ENOENT; return NULL; }
    return orig_fopen(filename, mode);
}

static DIR *(*orig_opendir)(const char *dirname);
static DIR *hook_opendir(const char *dirname) {
    if (dirname && isKnownBadPath(dirname)) { errno = ENOENT; return NULL; }
    return orig_opendir(dirname);
}

static int (*orig_open)(const char *path, int flags, ...);
static int hook_open(const char *path, int flags, ...) {
    if (path && isKnownBadPath(path)) { errno = ENOENT; return -1; }
    va_list args;
    va_start(args, flags);
    mode_t mode = (mode_t)va_arg(args, int);
    va_end(args);
    return orig_open(path, flags, mode);
}

static int (*orig_openat)(int fd, const char *path, int flags, ...);
static int hook_openat(int fd, const char *path, int flags, ...) {
    if (path && isKnownBadPath(path)) { errno = ENOENT; return -1; }
    va_list args;
    va_start(args, flags);
    mode_t mode = (mode_t)va_arg(args, int);
    va_end(args);
    return orig_openat(fd, path, flags, mode);
}

static int (*orig_fstatat)(int fd, const char *path, struct stat *buf, int flag);
static int hook_fstatat(int fd, const char *path, struct stat *buf, int flag) {
    if (path && isKnownBadPath(path)) { errno = ENOENT; return -1; }
    return orig_fstatat(fd, path, buf, flag);
}

void filebypass_init(void) {
    MSHookFunction((void *)stat, (void *)hook_stat, (void **)&orig_stat);
    MSHookFunction((void *)lstat, (void *)hook_lstat, (void **)&orig_lstat);
    MSHookFunction((void *)statfs, (void *)hook_statfs, (void **)&orig_statfs);
    MSHookFunction((void *)access, (void *)hook_access, (void **)&orig_access);
    MSHookFunction((void *)fopen, (void *)hook_fopen, (void **)&orig_fopen);
    MSHookFunction((void *)opendir, (void *)hook_opendir, (void **)&orig_opendir);
    MSHookFunction((void *)open, (void *)hook_open, (void **)&orig_open);
    void *sym;
    sym = dlsym(RTLD_DEFAULT, "openat");
    if (sym) MSHookFunction(sym, (void *)hook_openat, (void **)&orig_openat);
    sym = dlsym(RTLD_DEFAULT, "fstatat");
    if (sym) MSHookFunction(sym, (void *)hook_fstatat, (void **)&orig_fstatat);
}