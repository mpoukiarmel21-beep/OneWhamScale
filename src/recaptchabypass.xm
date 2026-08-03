/* ============================================================
 * recaptchabypass.xm - Recaptcha / SafetyNet bypass helpers (Logos)
 * ============================================================ */

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

%hook RecaptchaEnterprise

- (void)verifyWithSiteKey:(NSString *)siteKey completion:(void (^)(NSString *, NSError *))completion {
    if (completion) completion(@"mock-recaptcha-token-ows", nil);
}

- (void)executeWithCompletion:(void (^)(NSString *, NSError *))completion {
    if (completion) completion(@"mock-recaptcha-token-ows", nil);
}

%end

%hook WKWebView

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    if (url && ([url.host containsString:@"recaptcha"] || [url.host containsString:@"google.com"])) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    %orig;
}

%end

void recaptchabypass_init(void) {}