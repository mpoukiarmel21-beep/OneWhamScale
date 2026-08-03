/* ============================================================
 * mediabypass.m - Media metadata bypass
 * Hooks: AVAsset metadata to strip suspicious creation software tags
 * (PHAsset / UIImagePicker cleaning can be added here in future)
 * ============================================================ */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

/* AVAsset metadata - remove suspicious creation software */

static NSArray *(*orig_metadataForFormat)(id, SEL, NSString *);
static NSArray *hook_metadataForFormat(id self, SEL _cmd, NSString *format) {
    NSArray *orig = orig_metadataForFormat(self, _cmd, format);
    NSMutableArray *filtered = [NSMutableArray array];
    for (id item in orig) {
        if ([item isKindOfClass:[AVMetadataItem class]]) {
            NSString *key = [item keyString];
            if ([key isEqualToString:@"software"] || [key isEqualToString:@"creation_date"]) continue;
        }
        [filtered addObject:item];
    }
    return filtered;
}

static void swizzleAVAsset(void) {
    Class cls = [AVAsset class];
    Method m = class_getInstanceMethod(cls, @selector(metadataForFormat:));
    if (m) { orig_metadataForFormat = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_metadataForFormat); }
}

void mediabypass_init(void) {
    swizzleAVAsset();
}