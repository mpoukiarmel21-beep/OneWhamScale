/* ============================================================
 * datingappbypass.m - App-specific jailbreak detection bypass
 * Hooks via runtime swizzling (no CydiaSubstrate dependency):
 *   IOSSecuritySuite (Hily, Badoo, Tinder advanced)
 *   FlutterJailbreakDetectionPlugin (Fruitz)
 *   UIDevice.isJailbroken
 * ============================================================ */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "swizzle.h"

/* ============ UIDevice.isJailbroken ============ */

static BOOL (*orig_UIDevice_isJailbroken)(id, SEL);
static BOOL hook_UIDevice_isJailbroken(id self, SEL _cmd) { return NO; }

static void swizzleUIDevice(void) {
    Class cls = [UIDevice class];
    Method m = class_getInstanceMethod(cls, @selector(isJailbroken));
    if (m) {
        orig_UIDevice_isJailbroken = (void *)method_getImplementation(m);
        method_setImplementation(m, (IMP)hook_UIDevice_isJailbroken);
    }
}

/* ============ IOSSecuritySuite class methods ============ */

static BOOL hook_IOSS_amIJailbroken(id self, SEL _cmd) { return NO; }
static BOOL hook_IOSS_amIJailbrokenMsg(id self, SEL _cmd, NSString **msg) { return NO; }
static BOOL hook_IOSS_amIReverseEngineered(id self, SEL _cmd) { return NO; }
static BOOL hook_IOSS_amIReverseMsg(id self, SEL _cmd, NSString **msg) { return NO; }
static BOOL hook_IOSS_amIDebugged(id self, SEL _cmd) { return NO; }
static BOOL hook_IOSS_amIDebuggedMsg(id self, SEL _cmd, NSString **msg) { return NO; }
static BOOL hook_IOSS_performChecks(id self, SEL _cmd) { return YES; }
static BOOL hook_IOSS_runtimeHooked(id self, SEL _cmd) { return NO; }
static BOOL hook_IOSS_runtimeHookedMsg(id self, SEL _cmd, NSString **msg) { return NO; }
static BOOL hook_IOSS_reverseErr(id self, SEL _cmd, NSError **error) { return NO; }

static void swizzleIOSSecuritySuite(void) {
    Class cls = NSClassFromString(@"IOSSecuritySuite");
    if (!cls) return;
    Class meta = objc_getMetaClass(class_getName(cls));

    struct { SEL sel; IMP imp; } methods[] = {
        { @selector(amIJailbroken), (IMP)hook_IOSS_amIJailbroken },
        { @selector(amIJailbrokenWithFailMessage:), (IMP)hook_IOSS_amIJailbrokenMsg },
        { @selector(amIReverseEngineered), (IMP)hook_IOSS_amIReverseEngineered },
        { @selector(amIReverseEngineeredWithFailMessage:), (IMP)hook_IOSS_amIReverseMsg },
        { @selector(amIDebugged), (IMP)hook_IOSS_amIDebugged },
        { @selector(amIDebuggedWithFailMessage:), (IMP)hook_IOSS_amIDebuggedMsg },
        { @selector(performChecks), (IMP)hook_IOSS_performChecks },
        { @selector(amIRuntimeHookedWithDyldImageCount), (IMP)hook_IOSS_runtimeHooked },
        { @selector(amIRuntimeHookedWithDyldImageCountWithFailMessage:), (IMP)hook_IOSS_runtimeHookedMsg },
        { @selector(amIReverseEngineeredWithCheckError:), (IMP)hook_IOSS_reverseErr },
    };

    for (size_t i = 0; i < sizeof(methods) / sizeof(methods[0]); i++) {
        Method m = class_getClassMethod(cls, methods[i].sel);
        if (m) method_setImplementation(m, methods[i].imp);
    }
    (void)meta;
}

/* ============ FlutterJailbreakDetectionPlugin ============ */

static void swizzleFlutterDetection(void) {
    Class cls = NSClassFromString(@"FlutterJailbreakDetectionPlugin");
    if (!cls) return;

    Method m = class_getInstanceMethod(cls, @selector(isJailbroken));
    if (m) method_setImplementation(m, (IMP)hook_UIDevice_isJailbroken);
}

/* ============ INIT ============ */

void datingappbypass_init(void) {
    swizzleUIDevice();
    swizzleIOSSecuritySuite();
    swizzleFlutterDetection();
}