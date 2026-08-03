/* ============================================================
 * objcbypass.xm - Objective-C jailbreak detection bypass (Logos)
 * Hooks: NSFileManager, UIApplication, NSURL, NSString, NSData,
 *        NSProcessInfo, NSBundle
 * ============================================================ */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "utility.h"

%hook NSFileManager

- (BOOL)fileExistsAtPath:(NSString *)path {
    if (path && isKnownBadPath([path UTF8String])) return NO;
    return %orig;
}

- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory {
    if (path && isKnownBadPath([path UTF8String])) return NO;
    return %orig;
}

- (NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError **)error {
    if (path && isKnownBadPath([path UTF8String])) {
        if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        return nil;
    }
    return %orig;
}

- (BOOL)isReadableFileAtPath:(NSString *)path {
    if (path && isKnownBadPath([path UTF8String])) return NO;
    return %orig;
}

- (BOOL)isWritableFileAtPath:(NSString *)path {
    if (path && isKnownBadPath([path UTF8String])) return NO;
    return %orig;
}

- (BOOL)isExecutableFileAtPath:(NSString *)path {
    if (path && isKnownBadPath([path UTF8String])) return NO;
    return %orig;
}

- (NSArray *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error {
    if (path && isKnownBadPath([path UTF8String])) {
        if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        return nil;
    }
    return %orig;
}

- (NSArray *)subpathsOfDirectoryAtPath:(NSString *)path error:(NSError **)error {
    if (path && isKnownBadPath([path UTF8String])) {
        if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        return nil;
    }
    return %orig;
}

+ (NSData *)contentsAtPath:(NSString *)path {
    if (path && isKnownBadPath([path UTF8String])) return nil;
    return %orig;
}

%end

%hook UIApplication
- (BOOL)canOpenURL:(NSURL *)url {
    NSArray *schemes = @[@"cydia", @"sileo", @"undecimus", @"zebra", @"filza",
                         @"activator", @"openssh", @"cydia+", @"sbsettings", @"rockapp"];
    for (NSString *s in schemes) {
        if ([[url scheme] isEqualToString:s]) return NO;
    }
    return %orig;
}
%end

%hook NSURL
+ (instancetype)URLWithString:(NSString *)URLString {
    NSArray *schemes = @[@"cydia://", @"sileo://", @"undecimus://", @"zebra://", @"filza://"];
    for (NSString *s in schemes) {
        if ([URLString hasPrefix:s]) return nil;
    }
    return %orig;
}
- (BOOL)checkResourceIsReachableAndReturnError:(NSError **)error {
    NSString *path = [self path];
    if (path && isKnownBadPath([path UTF8String])) {
        if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        return NO;
    }
    return %orig;
}
%end

%hook NSString
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error {
    if (path && isRestrictedSystemPath([path UTF8String])) {
        if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteNoPermissionError userInfo:nil];
        return NO;
    }
    return %orig;
}
- (NSString *)stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error {
    if (path && isKnownBadPath([path UTF8String])) {
        if (error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        return nil;
    }
    return %orig;
}
%end

%hook NSData
+ (id)dataWithContentsOfFile:(NSString *)path {
    if (path && isKnownBadPath([path UTF8String])) return nil;
    return %orig;
}
- (id)initWithContentsOfFile:(NSString *)path {
    if (path && isKnownBadPath([path UTF8String])) return nil;
    return %orig;
}
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile {
    if (path && isRestrictedSystemPath([path UTF8String])) return NO;
    return %orig;
}
%end

%hook NSProcessInfo
- (NSDictionary *)environment {
    NSDictionary *origEnv = %orig;
    NSMutableDictionary *env = [origEnv mutableCopy];
    [env removeObjectForKey:@"DYLD_INSERT_LIBRARIES"];
    return env;
}
%end

%hook NSBundle
- (NSDictionary *)infoDictionary {
    NSString *bPath = [self bundlePath];
    if (bPath && isKnownBadPath([bPath UTF8String])) return nil;
    return %orig;
}
%end

void objcbypass_init(void) {}