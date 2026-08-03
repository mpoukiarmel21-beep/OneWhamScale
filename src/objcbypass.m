/* ============================================================
 * objcbypass.m - Objective-C jailbreak detection bypass
 * Uses runtime swizzling (no CydiaSubstrate dependency)
 * Hooks: NSFileManager, UIApplication, NSURL, NSString, NSData,
 *        NSProcessInfo, NSBundle
 * ============================================================ */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "utility.h"
#import "swizzle.h"

/* ============ NSFileManager ============ */

static BOOL (*orig_fileExistsAtPath)(id, SEL, NSString *);
static BOOL hook_fileExistsAtPath(id self, SEL _cmd, NSString *path) {
    if (path && isKnownBadPath([path UTF8String])) return NO;
    return orig_fileExistsAtPath(self, _cmd, path);
}

static BOOL (*orig_fileExistsAtPathIsDirectory)(id, SEL, NSString *, BOOL *);
static BOOL hook_fileExistsAtPathIsDirectory(id self, SEL _cmd, NSString *path, BOOL *isDir) {
    if (path && isKnownBadPath([path UTF8String])) return NO;
    return orig_fileExistsAtPathIsDirectory(self, _cmd, path, isDir);
}

static NSDictionary *(*orig_attributesOfItemAtPath)(id, SEL, NSString *, NSError **);
static NSDictionary *hook_attributesOfItemAtPath(id self, SEL _cmd, NSString *path, NSError **error) {
    if (path && isKnownBadPath([path UTF8String])) {
        if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        return nil;
    }
    return orig_attributesOfItemAtPath(self, _cmd, path, error);
}

static BOOL (*orig_isReadableFileAtPath)(id, SEL, NSString *);
static BOOL hook_isReadableFileAtPath(id self, SEL _cmd, NSString *path) {
    if (path && isKnownBadPath([path UTF8String])) return NO;
    return orig_isReadableFileAtPath(self, _cmd, path);
}

static BOOL (*orig_isWritableFileAtPath)(id, SEL, NSString *);
static BOOL hook_isWritableFileAtPath(id self, SEL _cmd, NSString *path) {
    if (path && isKnownBadPath([path UTF8String])) return NO;
    return orig_isWritableFileAtPath(self, _cmd, path);
}

static BOOL (*orig_isExecutableFileAtPath)(id, SEL, NSString *);
static BOOL hook_isExecutableFileAtPath(id self, SEL _cmd, NSString *path) {
    if (path && isKnownBadPath([path UTF8String])) return NO;
    return orig_isExecutableFileAtPath(self, _cmd, path);
}

static NSArray *(*orig_contentsOfDirectoryAtPath)(id, SEL, NSString *, NSError **);
static NSArray *hook_contentsOfDirectoryAtPath(id self, SEL _cmd, NSString *path, NSError **error) {
    if (path && isKnownBadPath([path UTF8String])) {
        if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        return nil;
    }
    return orig_contentsOfDirectoryAtPath(self, _cmd, path, error);
}

static NSArray *(*orig_subpathsOfDirectoryAtPath)(id, SEL, NSString *, NSError **);
static NSArray *hook_subpathsOfDirectoryAtPath(id self, SEL _cmd, NSString *path, NSError **error) {
    if (path && isKnownBadPath([path UTF8String])) {
        if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        return nil;
    }
    return orig_subpathsOfDirectoryAtPath(self, _cmd, path, error);
}

static NSData *(*orig_contentsAtPath)(id, SEL, NSString *);
static NSData *hook_contentsAtPath(id self, SEL _cmd, NSString *path) {
    if (path && isKnownBadPath([path UTF8String])) return nil;
    return orig_contentsAtPath(self, _cmd, path);
}

static void swizzleFileManager(void) {
    Class cls = [NSFileManager class];
    Method m;

    m = class_getClassMethod(cls, @selector(contentsAtPath:));
    orig_contentsAtPath = (void *)method_getImplementation(m);
    method_setImplementation(m, (IMP)hook_contentsAtPath);

    m = class_getInstanceMethod(cls, @selector(fileExistsAtPath:));
    orig_fileExistsAtPath = (void *)method_getImplementation(m);
    method_setImplementation(m, (IMP)hook_fileExistsAtPath);

    m = class_getInstanceMethod(cls, @selector(fileExistsAtPath:isDirectory:));
    orig_fileExistsAtPathIsDirectory = (void *)method_getImplementation(m);
    method_setImplementation(m, (IMP)hook_fileExistsAtPathIsDirectory);

    m = class_getInstanceMethod(cls, @selector(attributesOfItemAtPath:error:));
    orig_attributesOfItemAtPath = (void *)method_getImplementation(m);
    method_setImplementation(m, (IMP)hook_attributesOfItemAtPath);

    m = class_getInstanceMethod(cls, @selector(isReadableFileAtPath:));
    orig_isReadableFileAtPath = (void *)method_getImplementation(m);
    method_setImplementation(m, (IMP)hook_isReadableFileAtPath);

    m = class_getInstanceMethod(cls, @selector(isWritableFileAtPath:));
    orig_isWritableFileAtPath = (void *)method_getImplementation(m);
    method_setImplementation(m, (IMP)hook_isWritableFileAtPath);

    m = class_getInstanceMethod(cls, @selector(isExecutableFileAtPath:));
    orig_isExecutableFileAtPath = (void *)method_getImplementation(m);
    method_setImplementation(m, (IMP)hook_isExecutableFileAtPath);

    m = class_getInstanceMethod(cls, @selector(contentsOfDirectoryAtPath:error:));
    orig_contentsOfDirectoryAtPath = (void *)method_getImplementation(m);
    method_setImplementation(m, (IMP)hook_contentsOfDirectoryAtPath);

    m = class_getInstanceMethod(cls, @selector(subpathsOfDirectoryAtPath:error:));
    orig_subpathsOfDirectoryAtPath = (void *)method_getImplementation(m);
    method_setImplementation(m, (IMP)hook_subpathsOfDirectoryAtPath);
}

/* ============ UIApplication (canOpenURL) ============ */

static BOOL (*orig_canOpenURL)(id, SEL, NSURL *);
static BOOL hook_canOpenURL(id self, SEL _cmd, NSURL *url) {
    NSArray *schemes = @[@"cydia", @"sileo", @"undecimus", @"zebra", @"filza",
                         @"activator", @"openssh", @"cydia+", @"sbsettings", @"rockapp"];
    for (NSString *s in schemes) {
        if ([[url scheme] isEqualToString:s]) return NO;
    }
    return orig_canOpenURL(self, _cmd, url);
}

static void swizzleUIApplication(void) {
    Class cls = [UIApplication class];
    Method m = class_getInstanceMethod(cls, @selector(canOpenURL:));
    orig_canOpenURL = (void *)method_getImplementation(m);
    method_setImplementation(m, (IMP)hook_canOpenURL);
}

/* ============ NSURL ============ */

static id (*orig_URLWithString)(id, SEL, NSString *);
static id hook_URLWithString(id self, SEL _cmd, NSString *URLString) {
    NSArray *schemes = @[@"cydia://", @"sileo://", @"undecimus://", @"zebra://", @"filza://"];
    for (NSString *s in schemes) {
        if ([URLString hasPrefix:s]) return nil;
    }
    return orig_URLWithString(self, _cmd, URLString);
}

static BOOL (*orig_checkResourceIsReachable)(id, SEL, NSError **);
static BOOL hook_checkResourceIsReachable(id self, SEL _cmd, NSError **error) {
    NSString *path = [self path];
    if (path && isKnownBadPath([path UTF8String])) {
        if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        return NO;
    }
    return orig_checkResourceIsReachable(self, _cmd, error);
}

static void swizzleNSURL(void) {
    Class cls = [NSURL class];
    Method m = class_getClassMethod(cls, @selector(URLWithString:));
    orig_URLWithString = (void *)method_getImplementation(m);
    method_setImplementation(m, (IMP)hook_URLWithString);

    m = class_getInstanceMethod(cls, @selector(checkResourceIsReachableAndReturnError:));
    orig_checkResourceIsReachable = (void *)method_getImplementation(m);
    method_setImplementation(m, (IMP)hook_checkResourceIsReachable);
}

/* ============ NSString ============ */

static BOOL (*orig_writeToFileAtomicallyEncoding)(id, SEL, NSString *, BOOL, NSStringEncoding, NSError **);
static BOOL hook_writeToFileAtomicallyEncoding(id self, SEL _cmd, NSString *path, BOOL aux, NSStringEncoding enc, NSError **error) {
    if (path && isRestrictedSystemPath([path UTF8String])) {
        if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteNoPermissionError userInfo:nil];
        return NO;
    }
    return orig_writeToFileAtomicallyEncoding(self, _cmd, path, aux, enc, error);
}

static NSString *(*orig_stringWithContentsOfFile)(id, SEL, NSString *, NSStringEncoding, NSError **);
static NSString *hook_stringWithContentsOfFile(id self, SEL _cmd, NSString *path, NSStringEncoding enc, NSError **error) {
    if (path && isKnownBadPath([path UTF8String])) {
        if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        return nil;
    }
    return orig_stringWithContentsOfFile(self, _cmd, path, enc, error);
}

static void swizzleNSString(void) {
    Class cls = [NSString class];
    Method m;

    m = class_getInstanceMethod(cls, @selector(writeToFile:atomically:encoding:error:));
    orig_writeToFileAtomicallyEncoding = (void *)method_getImplementation(m);
    method_setImplementation(m, (IMP)hook_writeToFileAtomicallyEncoding);

    m = class_getInstanceMethod(cls, @selector(stringWithContentsOfFile:encoding:error:));
    orig_stringWithContentsOfFile = (void *)method_getImplementation(m);
    method_setImplementation(m, (IMP)hook_stringWithContentsOfFile);
}

/* ============ NSData ============ */

static id (*orig_dataWithContentsOfFile)(id, SEL, NSString *);
static id hook_dataWithContentsOfFile(id self, SEL _cmd, NSString *path) {
    if (path && isKnownBadPath([path UTF8String])) return nil;
    return orig_dataWithContentsOfFile(self, _cmd, path);
}

static void swizzleNSData(void) {
    Class cls = [NSData class];
    Method m = class_getClassMethod(cls, @selector(dataWithContentsOfFile:));
    orig_dataWithContentsOfFile = (void *)method_getImplementation(m);
    method_setImplementation(m, (IMP)hook_dataWithContentsOfFile);
}

/* ============ NSProcessInfo (hide DYLD_INSERT_LIBRARIES) ============ */

static NSDictionary *(*orig_environment)(id, SEL);
static NSDictionary *hook_environment(id self, SEL _cmd) {
    NSDictionary *origEnv = orig_environment(self, _cmd);
    NSMutableDictionary *env = [origEnv mutableCopy];
    [env removeObjectForKey:@"DYLD_INSERT_LIBRARIES"];
    return env;
}

static void swizzleNSProcessInfo(void) {
    Class cls = [NSProcessInfo class];
    Method m = class_getInstanceMethod(cls, @selector(environment));
    orig_environment = (void *)method_getImplementation(m);
    method_setImplementation(m, (IMP)hook_environment);
}

/* ============ NSBundle ============ */

static NSDictionary *(*orig_infoDictionary)(id, SEL);
static NSDictionary *hook_infoDictionary(id self, SEL _cmd) {
    NSString *bPath = [self bundlePath];
    if (bPath && isKnownBadPath([bPath UTF8String])) return nil;
    return orig_infoDictionary(self, _cmd);
}

static void swizzleNSBundle(void) {
    Class cls = [NSBundle class];
    Method m = class_getInstanceMethod(cls, @selector(infoDictionary));
    orig_infoDictionary = (void *)method_getImplementation(m);
    method_setImplementation(m, (IMP)hook_infoDictionary);
}

/* ============ INIT ============ */

void objcbypass_init(void) {
    swizzleFileManager();
    swizzleUIApplication();
    swizzleNSURL();
    swizzleNSString();
    swizzleNSData();
    swizzleNSProcessInfo();
    swizzleNSBundle();
}