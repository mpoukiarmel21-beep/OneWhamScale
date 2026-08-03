/* ============================================================
 * biometricbypass.xm - Behavioral biometric bypass (Logos)
 * Hooks: UITouch (location jitter), CMMotionManager (spoof)
 * ============================================================ */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

%hook UITouch
- (CGPoint)locationInView:(UIView *)view {
    CGPoint pt = %orig;
    float jitter = 0.4f;
    pt.x += ((float)arc4random_uniform(100) / 100.0f - 0.5f) * jitter;
    pt.y += ((float)arc4random_uniform(100) / 100.0f - 0.5f) * jitter;
    return pt;
}
%end

%hook CMMotionManager
- (BOOL)isAccelerometerActive { return NO; }
- (BOOL)isGyroActive { return NO; }
- (BOOL)isDeviceMotionActive { return NO; }
- (void)startAccelerometerUpdates { }
- (void)startAccelerometerUpdatesToQueue:(NSOperationQueue *)queue withHandler:(void (^)(id, NSError *))handler {
    if (handler) {
        id accelData = [[NSClassFromString(@"CMAccelerometerData") alloc] init];
        [queue addOperationWithBlock:^{ handler(accelData, nil); }];
    }
}
- (void)startGyroUpdates { }
- (void)startGyroUpdatesToQueue:(NSOperationQueue *)queue withHandler:(void (^)(id, NSError *))handler {
    if (handler) {
        id gyroData = [[NSClassFromString(@"CMGyroData") alloc] init];
        [queue addOperationWithBlock:^{ handler(gyroData, nil); }];
    }
}
- (void)startDeviceMotionUpdatesToQueue:(NSOperationQueue *)queue withHandler:(void (^)(id, NSError *))handler {
    if (handler) {
        id deviceMotion = [[NSClassFromString(@"CMDeviceMotion") alloc] init];
        [queue addOperationWithBlock:^{ handler(deviceMotion, nil); }];
    }
}
%end

void biometricbypass_init(void) {}