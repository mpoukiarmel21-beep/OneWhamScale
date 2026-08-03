/* ============================================================
 * Tweak.m - Main entry point (constructor)
 * OneWhamScale v3.0 - Anti-detect dating app suite
 * No CydiaSubstrate dependency; uses fishhook + runtime swizzling.
 * ============================================================ */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/* C modules init */
void filebypass_init(void);
void spawnbypass_init(void);
void dylibbypass_init(void);
void sysctlbypass_init(void);
void mgspoof_init(void);

/* ObjC modules init */
void objcbypass_init(void);
void datingappbypass_init(void);
void tinderhooks_init(void);
void fingerprintbypass_init(void);
void biometricbypass_init(void);
void attestationbypass_init(void);
void mediabypass_init(void);
void recaptchabypass_init(void);

static BOOL isTargetApp(NSString *bundleID) {
    static NSSet *targets = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        targets = [NSSet setWithObjects:
            @"com.cardify.tinder",        // Tinder
            @"com.tinder.Tinder",         // Tinder alt
            @"com.bumble.Bumble",         // Bumble
            @"com.badoo.Badoo",           // Badoo
            @"com.hily.Hily",             // Hily
            @"com.feels.Feels",           // Feels
            @"com.fruitz.Fruitz",         // Fruitz
            @"com.burbn.instagram",       // Instagram
            @"com.burbn.barcelona",       // Threads
            @"com.atebits.Tweetie2",      // Twitter/X alt
            @"com.google.Twitter",        // Twitter
            nil];
    });
    return [targets containsObject:bundleID];
}

__attribute__((constructor))
static void oneWhamScaleConstructor(void) {
    @autoreleasepool {
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
        if (!bundleID || !isTargetApp(bundleID)) return;

        /* C / fishhook hooks first */
        filebypass_init();
        spawnbypass_init();
        dylibbypass_init();
        sysctlbypass_init();
        mgspoof_init();

        /* ObjC / swizzling hooks */
        objcbypass_init();
        datingappbypass_init();
        fingerprintbypass_init();
        biometricbypass_init();
        attestationbypass_init();
        mediabypass_init();
        recaptchabypass_init();

        /* Tinder-specific UI/features */
        tinderhooks_init();
    }
}