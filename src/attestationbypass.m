/* ============================================================
 * attestationbypass.m - Apple App Attest / DCAppAttestService bypass
 * Hooks: -[DCAppAttestService generateKeyWithCompletionHandler:]
 *        -[DCAppAttestService attestKey:clientDataHash:completionHandler:]
 *        -[DCAppAttestService generateAssertion:clientDataHash:completionHandler:]
 * Returns plausible mock tokens to pass server checks.
 * ============================================================ */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static NSString *kMockAttestKey = @"mock-attest-key-ows";
static NSString *kMockAttestation = @"bW9jay1hdHRlc3RhdGlvbi1kYXRh";
static NSString *kMockAssertion = @"bW9jay1hc3NlcnRpb24tZGF0YQ==";

static void (*orig_generateKey)(id, SEL, void (^)(NSString *, NSError *));
static void hook_generateKey(id self, SEL _cmd, void (^completion)(NSString *, NSError *)) {
    if (completion) completion(kMockAttestKey, nil);
}

static void (*orig_attestKey)(id, SEL, NSString *, NSData *, void (^)(NSData *, NSError *));
static void hook_attestKey(id self, SEL _cmd, NSString *keyId, NSData *clientDataHash, void (^completion)(NSData *, NSError *)) {
    if (completion) completion([kMockAttestation dataUsingEncoding:NSUTF8StringEncoding], nil);
}

static void (*orig_generateAssertion)(id, SEL, NSString *, NSData *, void (^)(NSData *, NSError *));
static void hook_generateAssertion(id self, SEL _cmd, NSString *keyId, NSData *clientDataHash, void (^completion)(NSData *, NSError *)) {
    if (completion) completion([kMockAssertion dataUsingEncoding:NSUTF8StringEncoding], nil);
}

static BOOL (*orig_isSupported)(id, SEL);
static BOOL hook_isSupported(id self, SEL _cmd) { return YES; }

void attestationbypass_init(void) {
    Class cls = NSClassFromString(@"DCAppAttestService");
    if (!cls) cls = NSClassFromString(@"DCAppAttestService");
    if (!cls) return;

    Method m;
    m = class_getInstanceMethod(cls, @selector(generateKeyWithCompletionHandler:));
    if (m) { orig_generateKey = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_generateKey); }
    m = class_getInstanceMethod(cls, @selector(attestKey:clientDataHash:completionHandler:));
    if (m) { orig_attestKey = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_attestKey); }
    m = class_getInstanceMethod(cls, @selector(generateAssertion:clientDataHash:completionHandler:));
    if (m) { orig_generateAssertion = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_generateAssertion); }
    m = class_getClassMethod(cls, @selector(isSupported));
    if (m) { orig_isSupported = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_isSupported); }
}