/* ============================================================
 * OneWhamScale - Jailbreak Tweak (Anti-Detect + Tinder features)
 * Version 4.0.0
 *
 * Output: .deb package for Cydia/Sileo/Zebra
 * Uses: Logos %hook + Substrate MSHookFunction
 * ============================================================ */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "bypass.h"

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