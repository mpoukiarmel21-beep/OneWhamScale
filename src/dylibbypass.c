/* ============================================================
 * dylibbypass.c - Dylib/Image loading bypass hooks (Substrate)
 * Hooks: dlopen, _dyld_get_image_name, _dyld_image_count
 * ============================================================ */

#include "utility.h"
#include <substrate.h>
#include <dlfcn.h>
#include <mach-o/dyld.h>

static void *(*orig_dlopen)(const char *path, int mode);
static void *hook_dlopen(const char *path, int mode) {
    if (path && isKnownDylib(path)) return NULL;
    return orig_dlopen(path, mode);
}

static const char *(*orig__dyld_get_image_name)(uint32_t image_index);
static const char *hook__dyld_get_image_name(uint32_t image_index) {
    const char *retval = orig__dyld_get_image_name(image_index);
    if (retval && isKnownDylib(retval)) return "";
    return retval;
}

static uint32_t (*orig__dyld_image_count)(void);
static uint32_t hook__dyld_image_count(void) {
    uint32_t realCount = orig__dyld_image_count();
    uint32_t jbCount = 0;
    for (uint32_t i = 0; i < realCount; i++) {
        const char *name = orig__dyld_get_image_name(i);
        if (name && isKnownDylib(name)) jbCount++;
    }
    return realCount > jbCount ? realCount - jbCount : 1;
}

void dylibbypass_init(void) {
    MSHookFunction((void *)dlopen, (void *)hook_dlopen, (void **)&orig_dlopen);
    MSHookFunction((void *)_dyld_get_image_name, (void *)hook__dyld_get_image_name, (void **)&orig__dyld_get_image_name);
    MSHookFunction((void *)_dyld_image_count, (void *)hook__dyld_image_count, (void **)&orig__dyld_image_count);
}