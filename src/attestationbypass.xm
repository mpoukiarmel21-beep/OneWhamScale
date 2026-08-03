/* ============================================================
 * attestationbypass.xm - Apple App Attest / DCAppAttestService bypass (Logos)
 * ============================================================ */

#import <Foundation/Foundation.h>

%hook DCAppAttestService

+ (BOOL)isSupported { return YES; }

- (void)generateKeyWithCompletionHandler:(void (^)(NSString *, NSError *))completion {
    if (completion) completion(@"mock-attest-key-ows", nil);
}

- (void)attestKey:(NSString *)keyId clientDataHash:(NSData *)clientDataHash completionHandler:(void (^)(NSData *, NSError *))completion {
    if (completion) completion([@"bW9jay1hdHRlc3RhdGlvbi1kYXRh" dataUsingEncoding:NSUTF8StringEncoding], nil);
}

- (void)generateAssertion:(NSString *)keyId clientDataHash:(NSData *)clientDataHash completionHandler:(void (^)(NSData *, NSError *))completion {
    if (completion) completion([@"bW9jay1hc3NlcnRpb24tZGF0YQ==" dataUsingEncoding:NSUTF8StringEncoding], nil);
}

%end

void attestationbypass_init(void) {}