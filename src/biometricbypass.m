/* ============================================================
 * biometricbypass.m - Behavioral biometric bypass
 * Hooks: UIEvent, UITouch, UIPanGestureRecognizer
 * Adds realistic noise to touches and spoofs motion sensors
 * ============================================================ */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <objc/runtime.h>

/* Add jitter to touch location to avoid linear/perfect patterns */

static CGPoint (*orig_locationInView)(id, SEL, UIView *);
static CGPoint hook_locationInView(id self, SEL _cmd, UIView *view) {
    CGPoint pt = orig_locationInView(self, _cmd, view);
    float jitter = 0.4f;
    pt.x += ((float)arc4random_uniform(100) / 100.0f - 0.5f) * jitter;
    pt.y += ((float)arc4random_uniform(100) / 100.0f - 0.5f) * jitter;
    return pt;
}

static void swizzleTouch(void) {
    Class cls = [UITouch class];
    Method m = class_getInstanceMethod(cls, @selector(locationInView:));
    if (m) { orig_locationInView = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_locationInView); }
}

/* Spoof CoreMotion sensors (CMMotionManager) */

static NSOperationQueue *motionQueue;

static BOOL (*orig_isAccelerometerActive)(id, SEL);
static BOOL hook_isAccelerometerActive(id self, SEL _cmd) { return NO; }

static BOOL (*orig_isGyroActive)(id, SEL);
static BOOL hook_isGyroActive(id self, SEL _cmd) { return NO; }

static BOOL (*orig_isDeviceMotionActive)(id, SEL);
static BOOL hook_isDeviceMotionActive(id self, SEL _cmd) { return NO; }

static void (*orig_startAccelerometerUpdatesToQueue)(id, SEL, NSOperationQueue *, id);
static void hook_startAccelerometerUpdatesToQueue(id self, SEL _cmd, NSOperationQueue *queue, id handler) {
    motionQueue = queue;
    /* Feed realistic synthetic data */
    if (handler) {
        id accelData = [[NSClassFromString(@"CMAccelerometerData") alloc] init];
        [queue addOperationWithBlock:^{
            void (^block)(id, NSError *) = handler;
            block(accelData, nil);
        }];
    }
}

static void (*orig_startAccelerometerUpdates)(id, SEL);
static void hook_startAccelerometerUpdates(id self, SEL _cmd) {
    /* Silently suppress */
}

static void (*orig_startGyroUpdatesToQueue)(id, SEL, NSOperationQueue *, id);
static void hook_startGyroUpdatesToQueue(id self, SEL _cmd, NSOperationQueue *queue, id handler) {
    motionQueue = queue;
    if (handler) {
        id gyroData = [[NSClassFromString(@"CMGyroData") alloc] init];
        [queue addOperationWithBlock:^{
            void (^block)(id, NSError *) = handler;
            block(gyroData, nil);
        }];
    }
}

static void (*orig_startGyroUpdates)(id, SEL);
static void hook_startGyroUpdates(id self, SEL _cmd) {
    /* Silently suppress */
}

static void (*orig_startDeviceMotionUpdatesToQueue)(id, SEL, NSOperationQueue *, id);
static void hook_startDeviceMotionUpdatesToQueue(id self, SEL _cmd, NSOperationQueue *queue, id handler) {
    motionQueue = queue;
    if (handler) {
        id deviceMotion = [[NSClassFromString(@"CMDeviceMotion") alloc] init];
        [queue addOperationWithBlock:^{
            void (^block)(id, NSError *) = handler;
            block(deviceMotion, nil);
        }];
    }
}

static void swizzleMotionManager(void) {
    Class cls = NSClassFromString(@"CMMotionManager");
    if (!cls) return;
    Method m;
    m = class_getInstanceMethod(cls, @selector(isAccelerometerActive));
    if (m) { orig_isAccelerometerActive = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_isAccelerometerActive); }
    m = class_getInstanceMethod(cls, @selector(isGyroActive));
    if (m) { orig_isGyroActive = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_isGyroActive); }
    m = class_getInstanceMethod(cls, @selector(isDeviceMotionActive));
    if (m) { orig_isDeviceMotionActive = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_isDeviceMotionActive); }
    m = class_getInstanceMethod(cls, @selector(startAccelerometerUpdates));
    if (m) { orig_startAccelerometerUpdates = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_startAccelerometerUpdates); }
    m = class_getInstanceMethod(cls, @selector(startAccelerometerUpdatesToQueue:withHandler:));
    if (m) { orig_startAccelerometerUpdatesToQueue = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_startAccelerometerUpdatesToQueue); }
    m = class_getInstanceMethod(cls, @selector(startGyroUpdates));
    if (m) { orig_startGyroUpdates = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_startGyroUpdates); }
    m = class_getInstanceMethod(cls, @selector(startGyroUpdatesToQueue:withHandler:));
    if (m) { orig_startGyroUpdatesToQueue = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_startGyroUpdatesToQueue); }
    m = class_getInstanceMethod(cls, @selector(startDeviceMotionUpdatesToQueue:withHandler:));
    if (m) { orig_startDeviceMotionUpdatesToQueue = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_startDeviceMotionUpdatesToQueue); }
}

void biometricbypass_init(void) {
    swizzleTouch();
    swizzleMotionManager();
}