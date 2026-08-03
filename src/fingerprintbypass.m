/* ============================================================
 * fingerprintbypass.m - Hardware/environment fingerprint bypass
 * Hooks: MobileGestalt (deep), UIDevice, UIScreen, UIWebView fonts
 * Spoofs TrueDevice ID components: screen, model, battery, fonts, sensors
 * ============================================================ */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "swizzle.h"

/* UIDevice: model, systemName, systemVersion, name, identifierForVendor */

static NSString *(*orig_deviceModel)(id, SEL);
static NSString *hook_deviceModel(id self, SEL _cmd) { return @"iPhone14,2"; }

static NSString *(*orig_systemName)(id, SEL);
static NSString *hook_systemName(id self, SEL _cmd) { return @"iOS"; }

static NSString *(*orig_systemVersion)(id, SEL);
static NSString *hook_systemVersion(id self, SEL _cmd) { return @"17.1.1"; }

static NSString *(*orig_deviceName)(id, SEL);
static NSString *hook_deviceName(id self, SEL _cmd) { return @"iPhone"; }

static NSUUID *(*orig_identifierForVendor)(id, SEL);
static NSUUID *hook_identifierForVendor(id self, SEL _cmd) {
    return [[NSUUID alloc] initWithUUIDString:@"550E8400-E29B-41D4-A716-446655440000"];
}

static UIDeviceBatteryState (*orig_batteryState)(id, SEL);
static UIDeviceBatteryState hook_batteryState(id self, SEL _cmd) { return UIDeviceBatteryStateUnplugged; }

static float (*orig_batteryLevel)(id, SEL);
static float hook_batteryLevel(id self, SEL _cmd) { return 0.85f; }

static void swizzleUIDeviceFingerprint(void) {
    Class cls = [UIDevice class];
    Method m;
    m = class_getInstanceMethod(cls, @selector(model));
    orig_deviceModel = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_deviceModel);
    m = class_getInstanceMethod(cls, @selector(systemName));
    orig_systemName = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_systemName);
    m = class_getInstanceMethod(cls, @selector(systemVersion));
    orig_systemVersion = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_systemVersion);
    m = class_getInstanceMethod(cls, @selector(name));
    orig_deviceName = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_deviceName);
    m = class_getInstanceMethod(cls, @selector(identifierForVendor));
    orig_identifierForVendor = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_identifierForVendor);
    m = class_getInstanceMethod(cls, @selector(batteryState));
    orig_batteryState = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_batteryState);
    m = class_getInstanceMethod(cls, @selector(batteryLevel));
    orig_batteryLevel = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_batteryLevel);
}

/* UIScreen: bounds, scale, nativeBounds, nativeScale */

static CGRect (*orig_screenBounds)(id, SEL);
static CGRect hook_screenBounds(id self, SEL _cmd) { return CGRectMake(0, 0, 390, 844); }

static CGFloat (*orig_screenScale)(id, SEL);
static CGFloat hook_screenScale(id self, SEL _cmd) { return 3.0; }

static CGRect (*orig_nativeBounds)(id, SEL);
static CGRect hook_nativeBounds(id self, SEL _cmd) { return CGRectMake(0, 0, 1170, 2532); }

static CGFloat (*orig_nativeScale)(id, SEL);
static CGFloat hook_nativeScale(id self, SEL _cmd) { return 3.0; }

static void swizzleUIScreenFingerprint(void) {
    Class cls = [UIScreen class];
    Method m;
    m = class_getClassMethod(cls, @selector(mainScreen));
    if (m) {
        UIScreen *main = [UIScreen mainScreen];
        Method mm;
        mm = class_getInstanceMethod([main class], @selector(bounds));
        orig_screenBounds = (void *)method_getImplementation(mm); method_setImplementation(mm, (IMP)hook_screenBounds);
        mm = class_getInstanceMethod([main class], @selector(scale));
        orig_screenScale = (void *)method_getImplementation(mm); method_setImplementation(mm, (IMP)hook_screenScale);
        mm = class_getInstanceMethod([main class], @selector(nativeBounds));
        orig_nativeBounds = (void *)method_getImplementation(mm); method_setImplementation(mm, (IMP)hook_nativeBounds);
        mm = class_getInstanceMethod([main class], @selector(nativeScale));
        orig_nativeScale = (void *)method_getImplementation(mm); method_setImplementation(mm, (IMP)hook_nativeScale);
    }
}

/* Font list spoof: UIFont +familyNames */

static NSArray *(*orig_familyNames)(id, SEL);
static NSArray *hook_familyNames(id self, SEL _cmd) {
    return @[@"San Francisco", @"Helvetica", @"Courier", @"Times New Roman", @"Arial"];
}

static void swizzleFonts(void) {
    Class cls = [UIFont class];
    Method m = class_getClassMethod(cls, @selector(familyNames));
    if (m) {
        orig_familyNames = (void *)method_getImplementation(m);
        method_setImplementation(m, (IMP)hook_familyNames);
    }
}

/* NSProcessInfo: physicalMemory, processorCount, systemUptime */

static unsigned long long (*orig_physicalMemory)(id, SEL);
static unsigned long long hook_physicalMemory(id self, SEL _cmd) { return 4294967296ULL; }

static NSUInteger (*orig_processorCount)(id, SEL);
static NSUInteger hook_processorCount(id self, SEL _cmd) { return 6; }

static NSTimeInterval (*orig_systemUptime)(id, SEL);
static NSTimeInterval hook_systemUptime(id self, SEL _cmd) { return 12345.0; }

static void swizzleProcessInfo(void) {
    Class cls = [NSProcessInfo class];
    Method m;
    m = class_getInstanceMethod(cls, @selector(physicalMemory));
    orig_physicalMemory = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_physicalMemory);
    m = class_getInstanceMethod(cls, @selector(processorCount));
    orig_processorCount = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_processorCount);
    m = class_getInstanceMethod(cls, @selector(systemUptime));
    orig_systemUptime = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_systemUptime);
}

void fingerprintbypass_init(void) {
    swizzleUIDeviceFingerprint();
    swizzleUIScreenFingerprint();
    swizzleFonts();
    swizzleProcessInfo();
}