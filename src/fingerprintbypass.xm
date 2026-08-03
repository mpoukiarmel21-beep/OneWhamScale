/* ============================================================
 * fingerprintbypass.xm - Hardware/environment fingerprint bypass (Logos)
 * Hooks: UIDevice, UIScreen, UIFont, NSProcessInfo
 * ============================================================ */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

%hook UIDevice
- (NSString *)model { return @"iPhone14,2"; }
- (NSString *)systemName { return @"iOS"; }
- (NSString *)systemVersion { return @"17.1.1"; }
- (NSString *)name { return @"iPhone"; }
- (NSUUID *)identifierForVendor {
    return [[NSUUID alloc] initWithUUIDString:@"550E8400-E29B-41D4-A716-446655440000"];
}
- (UIDeviceBatteryState)batteryState { return UIDeviceBatteryStateUnplugged; }
- (float)batteryLevel { return 0.85f; }
%end

%hook UIScreen
- (CGRect)bounds { return CGRectMake(0, 0, 390, 844); }
- (CGFloat)scale { return 3.0; }
- (CGRect)nativeBounds { return CGRectMake(0, 0, 1170, 2532); }
- (CGFloat)nativeScale { return 3.0; }
%end

%hook UIFont
+ (NSArray *)familyNames {
    return @[@"San Francisco", @"Helvetica", @"Courier", @"Times New Roman", @"Arial"];
}
%end

%hook NSProcessInfo
- (unsigned long long)physicalMemory { return 4294967296ULL; }
- (NSUInteger)processorCount { return 6; }
- (NSTimeInterval)systemUptime { return 12345.0; }
%end

void fingerprintbypass_init(void) {}