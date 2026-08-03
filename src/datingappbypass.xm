/* ============================================================
 * datingappbypass.xm - App-specific jailbreak detection bypass (Logos)
 * Hooks: IOSSecuritySuite, FlutterJailbreakDetectionPlugin, UIDevice
 * ============================================================ */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

%hook IOSSecuritySuite

+ (BOOL)amIJailbroken { return NO; }
+ (BOOL)amIJailbrokenWithFailMessage:(NSString **)failMessage { return NO; }
+ (BOOL)amIReverseEngineered { return NO; }
+ (BOOL)amIReverseEngineeredWithFailMessage:(NSString **)failMessage { return NO; }
+ (BOOL)amIDebugged { return NO; }
+ (BOOL)amIDebuggedWithFailMessage:(NSString **)failMessage { return NO; }
+ (BOOL)performChecks { return YES; }
+ (BOOL)amIRuntimeHookedWithDyldImageCount { return NO; }
+ (BOOL)amIRuntimeHookedWithDyldImageCountWithFailMessage:(NSString **)failMessage { return NO; }
+ (BOOL)amIReverseEngineeredWithCheckError:(NSError **)error { return NO; }

%end

%hook FlutterJailbreakDetectionPlugin
- (BOOL)isJailbroken { return NO; }
- (BOOL)isDebugged { return NO; }
%end

%hook UIDevice
- (BOOL)isJailbroken { return NO; }
%end

void datingappbypass_init(void) {}