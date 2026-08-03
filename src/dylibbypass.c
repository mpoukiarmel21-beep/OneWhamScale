/* ============================================================
 * dylibbypass.c - Dylib/Image loading bypass hooks (fishhook)
 * Hooks: dlopen, dlsym, _dyld_get_image_name, _dyld_image_count
 * Hides jailbreak dylibs loaded into process
 * ============================================================ */

#include "utility.h"
#include "fishhook.h"
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <string.h>

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
    uint32_t result = realCount > jbCount ? realCount - jbCount : 1;
    return result;
}

/* ---- INIT ---- */
void dylibbypass_init(void) {
    struct rebinding rebindings[] = {
        {"dlopen", (void *)hook_dlopen, (void **)&orig_dlopen},
        {"_dyld_get_image_name", (void *)hook__dyld_get_image_name, (void **)&orig__dyld_get_image_name},
        {"_dyld_image_count", (void *)hook__dyld_image_count, (void **)&orig__dyld_image_count},
    };
    rebind_symbols(rebindings, sizeof(rebindings) / sizeof(struct rebinding));
}