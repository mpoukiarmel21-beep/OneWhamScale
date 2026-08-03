/* ============================================================
 * OneWhamScale - Jailbreak Tweak (Anti-Detect + Tinder features)
 * Version 4.0.0
 *
 * Output: .deb package for Cydia/Sileo/Zebra
 * Uses: Logos %hook + Substrate MSHookFunction
 * ============================================================ */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/* C module init functions */
void filebypass_init(void);
void spawnbypass_init(void);
void dylibbypass_init(void);
void sysctlbypass_init(void);
void mgspoof_init(void);

%ctor {
    @autoreleasepool {
        /* Initialize C-level Substrate hooks */
        filebypass_init();
        spawnbypass_init();
        dylibbypass_init();
        sysctlbypass_init();
        mgspoof_init();

        /* Objective-C Logos hooks are auto-initialized per-file */
    }
}