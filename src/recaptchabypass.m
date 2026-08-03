/* ============================================================
 * recaptchabypass.m - Recaptcha / SafetyNet bypass helpers
 * Hooks: RecaptchaEnterprise, RecaptchaVerify, WebView recaptcha callbacks
 * Prevents Recaptcha challenge popups for Fruitz etc.
 * ============================================================ */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

static void (*orig_recaptchaVerify)(id, SEL, NSString *, void (^)(NSString *, NSError *));
static void hook_recaptchaVerify(id self, SEL _cmd, NSString *siteKey, void (^completion)(NSString *, NSError *)) {
    if (completion) completion(@"mock-recaptcha-token-ows", nil);
}

static void (*orig_executeRecaptcha)(id, SEL, void (^)(NSString *, NSError *));
static void hook_executeRecaptcha(id self, SEL _cmd, void (^completion)(NSString *, NSError *)) {
    if (completion) completion(@"mock-recaptcha-token-ows", nil);
}

static void swizzleRecaptcha(void) {
    Class cls = NSClassFromString(@"RecaptchaEnterprise");
    if (!cls) cls = NSClassFromString(@"Recaptcha");
    if (!cls) return;
    Method m;
    m = class_getInstanceMethod(cls, @selector(verifyWithSiteKey:completion:));
    if (m) { orig_recaptchaVerify = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_recaptchaVerify); }
    m = class_getInstanceMethod(cls, @selector(executeWithCompletion:));
    if (m) { orig_executeRecaptcha = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_executeRecaptcha); }
}

/* Block known recaptcha challenge URLs in WKWebView */

static void (*orig_webView_decidePolicy)(id, SEL, WKNavigationAction *, void (^)(WKNavigationActionPolicy));
static void hook_webView_decidePolicy(id self, SEL _cmd, WKNavigationAction *navigationAction, void (^decisionHandler)(WKNavigationActionPolicy)) {
    NSURL *url = navigationAction.request.URL;
    if (url && ([url.host containsString:@"recaptcha"] || [url.host containsString:@"google.com"])) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    orig_webView_decidePolicy(self, _cmd, navigationAction, decisionHandler);
}

static void swizzleWebView(void) {
    Class cls = [WKWebView class];
    Method m = class_getInstanceMethod(cls, @selector(webView:decidePolicyForNavigationAction:decisionHandler:));
    if (m) { orig_webView_decidePolicy = (void *)method_getImplementation(m); method_setImplementation(m, (IMP)hook_webView_decidePolicy); }
}

void recaptchabypass_init(void) {
    swizzleRecaptcha();
    swizzleWebView();
}