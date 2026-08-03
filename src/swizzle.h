/* ============================================================
 * swizzle.h - Objective-C runtime swizzling helpers
 * No CydiaSubstrate dependency (works on sideloaded iOS)
 * ============================================================ */

#import <objc/runtime.h>
#import <Foundation/Foundation.h>

static inline BOOL OWS_SwizzleInstance(Class cls, SEL origSel, SEL newSel) {
    Method origMethod = class_getInstanceMethod(cls, origSel);
    Method newMethod = class_getInstanceMethod(cls, newSel);
    if (!origMethod || !newMethod) return NO;
    class_addMethod(cls, origSel,
                    method_getImplementation(origMethod),
                    method_getTypeEncoding(origMethod));
    method_exchangeImplementations(origMethod, newMethod);
    return YES;
}

static inline BOOL OWS_SwizzleClass(Class cls, SEL origSel, SEL newSel) {
    Method origMethod = class_getClassMethod(cls, origSel);
    Method newMethod = class_getClassMethod(cls, newSel);
    if (!origMethod || !newMethod) return NO;
    class_addMethod(objc_getMetaClass(class_getName(cls)), origSel,
                    method_getImplementation(origMethod),
                    method_getTypeEncoding(origMethod));
    method_exchangeImplementations(origMethod, newMethod);
    return YES;
}

/* Macro to invoke the original implementation after swizzle */
#define OWS_ORIG(returnType, cls, sel, ...) \
    ((returnType (*)(id, SEL, ...))method_getImplementation(class_getInstanceMethod(cls, sel)))(self, sel, ##__VA_ARGS__)