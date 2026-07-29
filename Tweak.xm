// OneWhamScale - Tweak de spoofing & bypass
// Apps cibles: Tinder, Badoo, Bumble, Hily, Fruitz, Feels

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <substrate.h>
#import <dlfcn.h>
#import <Security/Security.h>

// ============================================================
// CONFIGURATION
// ============================================================
#define kContainerBase @"Documents/OneWhamScale"
#define kKeychainService @"onewhamscale"

// ============================================================
// DEVICE FINGERPRINT SPOOFER
// ============================================================

@interface OWSDeviceSpoofer : NSObject
+ (instancetype)sharedInstance;
@property (nonatomic, strong) NSDictionary *overrides;
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;
- (void)applySpoofs;
- (void)setSpoofValue:(id)value forKey:(NSString *)key;
@end

@implementation OWSDeviceSpoofer

static OWSDeviceSpoofer *shared = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init {
    if ((self = [super init])) {
        _overrides = @{
            @"deviceModel": @"iPhone16,2",
            @"deviceName": @"iPhone",
            @"kernelVersion": @"Darwin 24.0.0",
            @"softwareVersion": @"18.0",
            @"carrier": @"T-Mobile",
            @"locale": @"en_US",
            @"timeZone": @"America/New_York",
            @"batteryLevel": @0.85,
            @"batteryState": @"charging",
            @"brightness": @0.75,
            @"lowPowerMode": @NO,
            @"orientation": @1,
            @"processorCount": @8,
            @"memorySize": @"8589934592",
            @"storageCapacity": @"274877906944",
            @"proximity": @NO,
            @"jailbroken": @NO,
            @"simulator": @NO,
            @"debugger": @NO,
        };
        _enabled = YES;
    }
    return self;
}
@end

// ============================================================
// KEYCHAIN HOOKS
// ============================================================

static CFTypeRef (*orig_SecItemCopyMatching)(CFDictionaryRef query, CFTypeRef *result);
static OSStatus (*orig_SecItemAdd)(CFDictionaryRef attributes, CFTypeRef *result);
static OSStatus (*orig_SecItemDelete)(CFDictionaryRef query);
static OSStatus (*orig_SecItemUpdate)(CFDictionaryRef query, CFDictionaryRef attributesToUpdate);

CFTypeRef hooked_SecItemCopyMatching(CFDictionaryRef query, CFTypeRef *result) {
    NSMutableDictionary *modifiedQuery = [(__bridge NSDictionary *)query mutableCopy];
    
    NSString *service = modifiedQuery[(__bridge NSString *)kSecAttrService];
    if ([service containsString:@"jail"] || [service containsString:@"cydia"]) {
        return errSecItemNotFound;
    }
    
    if ([service containsString:@"identifier"] || [service containsString:@"device-id"]) {
        if (result) {
            NSString *spoofedID = [NSString stringWithFormat:@"%@", [[NSUUID UUID] UUIDString]];
            *result = CFBridgingRetain([spoofedID dataUsingEncoding:NSUTF8StringEncoding]);
            return errSecSuccess;
        }
    }
    
    return orig_SecItemCopyMatching((__bridge CFDictionaryRef)modifiedQuery, result);
}

// ============================================================
// NSUSERDEFAULTS HOOKS
// ============================================================

static NSString* (*orig_NSUserDefaults_objectForKey)(id self, SEL _cmd, NSString *key);
static BOOL (*orig_NSUserDefaults_boolForKey)(id self, SEL _cmd, NSString *key);

NSString* hooked_NSUserDefaults_objectForKey(id self, SEL _cmd, NSString *key) {
    if ([key containsString:@"jail"] || [key containsString:@"detection"] || [key containsString:@"JB"]) {
        return nil;
    }
    
    if ([key containsString:@"device"] && [[OWSDeviceSpoofer sharedInstance] isEnabled]) {
        NSDictionary *spoofs = [[OWSDeviceSpoofer sharedInstance] overrides];
        id value = spoofs[key];
        if (value) return value;
    }
    
    return orig_NSUserDefaults_objectForKey(self, _cmd, key);
}

BOOL hooked_NSUserDefaults_boolForKey(id self, SEL _cmd, NSString *key) {
    if ([key containsString:@"jail"] || [key containsString:@"detection"] || 
        [key containsString:@"JB"] || [key containsString:@"isJailbroken"]) {
        return NO;
    }
    
    return orig_NSUserDefaults_boolForKey(self, _cmd, key);
}

// ============================================================
// FILE MANAGER HOOKS
// ============================================================

static BOOL (*orig_NSFileManager_fileExistsAtPath)(id self, SEL _cmd, NSString *path);

BOOL hooked_NSFileManager_fileExistsAtPath(id self, SEL _cmd, NSString *path) {
    NSArray *jbPaths = @[
        @"/Applications/Cydia.app",
        @"/Applications/Sileo.app",
        @"/Applications/Zebra.app",
        @"/Library/MobileSubstrate",
        @"/var/jb",
        @"/var/lib/cydia",
        @"/bin/bash",
        @"/usr/sbin/sshd",
        @"/etc/apt",
        @"/private/var/lib/apt",
    ];
    
    for (NSString *jbPath in jbPaths) {
        if ([path hasPrefix:jbPath]) {
            return NO;
        }
    }
    
    return orig_NSFileManager_fileExistsAtPath(self, _cmd, path);
}

// ============================================================
// STAT HOOKS
// ============================================================

#include <sys/stat.h>

static int (*orig_stat)(const char *path, struct stat *buf);

int hooked_stat(const char *path, struct stat *buf) {
    NSString *nsPath = [NSString stringWithUTF8String:path];
    NSArray *jbPaths = @[@"/Applications/Cydia.app", @"/var/jb", @"/bin/bash"];
    
    for (NSString *jbPath in jbPaths) {
        if ([nsPath hasPrefix:jbPath]) {
            errno = ENOENT;
            return -1;
        }
    }
    
    return orig_stat(path, buf);
}

// ============================================================
// DYLD CHECK HOOK
// ============================================================

#include <mach-o/dyld.h>

static uint32_t (*orig_dyld_image_count)(void);
static const char* (*orig_dyld_get_image_name)(uint32_t index);

uint32_t hooked_dyld_image_count(void) {
    uint32_t count = orig_dyld_image_count();
    uint32_t result = 0;
    
    for (uint32_t i = 0; i < count; i++) {
        const char *name = orig_dyld_get_image_name(i);
        NSString *nsName = [NSString stringWithUTF8String:name];
        
        if ([nsName containsString:@"OneWhamScale"] || 
            [nsName containsString:@"Substrate"]) {
            continue;
        }
        result++;
    }
    
    return result;
}

const char* hooked_dyld_get_image_name(uint32_t index) {
    uint32_t count = orig_dyld_image_count();
    uint32_t actualIndex = 0;
    
    for (uint32_t i = 0; i < count; i++) {
        const char *name = orig_dyld_get_image_name(i);
        NSString *nsName = [NSString stringWithUTF8String:name];
        
        if ([nsName containsString:@"OneWhamScale"] || 
            [nsName containsString:@"Substrate"]) {
            continue;
        }
        
        if (actualIndex == index) {
            return name;
        }
        actualIndex++;
    }
    
    return orig_dyld_get_image_name(index);
}

// ============================================================
// CAN OPEN URL HOOK
// ============================================================

static BOOL (*orig_UIApplication_canOpenURL)(id self, SEL _cmd, NSURL *url);

BOOL hooked_UIApplication_canOpenURL(id self, SEL _cmd, NSURL *url) {
    NSString *scheme = [url scheme];
    NSArray *jbSchemes = @[@"cydia", @"sileo", @"zebra", @"installer"];
    
    for (NSString *jbScheme in jbSchemes) {
        if ([[scheme lowercaseString] isEqualToString:jbScheme]) {
            return NO;
        }
    }
    
    return orig_UIApplication_canOpenURL(self, _cmd, url);
}

// ============================================================
// FORK DETECTION HOOK
// ============================================================

#include <unistd.h>

static pid_t (*orig_fork)(void);

pid_t hooked_fork(void) {
    errno = EPERM;
    return -1;
}

// ============================================================
// SYSCTL HOOK
// ============================================================

#include <sys/sysctl.h>

static int (*orig_sysctl)(int *name, u_int namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen);

int hooked_sysctl(int *name, u_int namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen) {
    if (namelen >= 2 && name[0] == CTL_KERN && name[1] == KERN_PROC) {
        return orig_sysctl(name, namelen, oldp, oldlenp, newp, newlen);
    }
    
    return orig_sysctl(name, namelen, oldp, oldlenp, newp, newlen);
}

// ============================================================
// JAILBREAK DETECTION BYPASS
// ============================================================

static BOOL (*orig_amIJailbroken)(id self, SEL _cmd);
BOOL hooked_amIJailbroken(id self, SEL _cmd) {
    return NO;
}

static BOOL (*orig_isJailbroken)(id self, SEL _cmd);
BOOL hooked_isJailbroken(id self, SEL _cmd) {
    return NO;
}

// ============================================================
// INIT
// ============================================================

%ctor {
    @autoreleasepool {
        NSLog(@"[OneWhamScale] Initialisation v1.0.0");
        
        MSHookFunction((void *)SecItemCopyMatching, (void *)hooked_SecItemCopyMatching, (void **)&orig_SecItemCopyMatching);
        
        MSHookMessageEx([NSUserDefaults class], @selector(objectForKey:), (IMP)hooked_NSUserDefaults_objectForKey, (IMP *)&orig_NSUserDefaults_objectForKey);
        MSHookMessageEx([NSUserDefaults class], @selector(boolForKey:), (IMP)hooked_NSUserDefaults_boolForKey, (IMP *)&orig_NSUserDefaults_boolForKey);
        
        MSHookMessageEx([NSFileManager class], @selector(fileExistsAtPath:), (IMP)hooked_NSFileManager_fileExistsAtPath, (IMP *)&orig_NSFileManager_fileExistsAtPath);
        
        MSHookFunction((void *)stat, (void *)hooked_stat, (void **)&orig_stat);
        
        MSHookFunction((void *)_dyld_image_count, (void *)hooked_dyld_image_count, (void **)&orig_dyld_image_count);
        MSHookFunction((void *)_dyld_get_image_name, (void *)hooked_dyld_get_image_name, (void **)&orig_dyld_get_image_name);
        
        MSHookMessageEx([UIApplication class], @selector(canOpenURL:), (IMP)hooked_UIApplication_canOpenURL, (IMP *)&orig_UIApplication_canOpenURL);
        
        MSHookFunction((void *)fork, (void *)hooked_fork, (void **)&orig_fork);
        
        MSHookFunction((void *)sysctl, (void *)hooked_sysctl, (void **)&orig_sysctl);
        
        Class jailDetectClass1 = NSClassFromString(@"JailbreakDetection");
        if (jailDetectClass1) {
            MSHookMessageEx(jailDetectClass1, @selector(isJailbroken), (IMP)hooked_isJailbroken, (IMP *)&orig_isJailbroken);
        }
        
        Class jailDetectClass2 = NSClassFromString(@"IOSSecuritySuite");
        if (jailDetectClass2) {
            MSHookMessageEx(jailDetectClass2, @selector(amIJailbroken), (IMP)hooked_amIJailbroken, (IMP *)&orig_amIJailbroken);
        }
        
        NSLog(@"[OneWhamScale] Hooks installés avec succès");
        
        [[OWSDeviceSpoofer sharedInstance] applySpoofs];
    }
}