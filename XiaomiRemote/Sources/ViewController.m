#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController () <WKNavigationDelegate>
@property(nonatomic,strong) WKWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;

    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    config.allowsInlineMediaPlayback = YES;
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;

    // Preserve ws-scrcpy's two-canvas grid: video-layer below, touch-layer above.
    // Hide only the web toolbar/status and make the mirror scale to the iPhone.
    NSString *cleanUI = @"(function(){"
        "var meta=document.createElement('meta');"
        "meta.name='viewport';"
        "meta.content='width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no,viewport-fit=cover';"
        "document.head&&document.head.appendChild(meta);"
        "var s=document.createElement('style');"
        "s.innerHTML='"
        "#status,.control-buttons-list,.control-wrapper{display:none!important;}"
        "html,body{margin:0!important;padding:0!important;width:100%!important;height:100%!important;background:#000!important;overflow:hidden!important;overscroll-behavior:none!important;}"
        "body[data-embed-entry]{display:flex!important;align-items:center!important;justify-content:center!important;}"
        ".device-view{display:flex!important;flex-direction:row!important;width:100vw!important;height:100vh!important;min-width:0!important;min-height:0!important;align-items:center!important;justify-content:center!important;background:#000!important;overflow:hidden!important;}"
        ".video{display:grid!important;grid-template-columns:auto!important;grid-template-rows:auto!important;place-items:center!important;width:100vw!important;height:100vh!important;min-width:0!important;min-height:0!important;background:#000!important;overflow:hidden!important;}"
        ".video-layer,.touch-layer{grid-area:1 / 1!important;display:block!important;max-width:100vw!important;max-height:100vh!important;width:auto!important;height:auto!important;margin:0!important;padding:0!important;object-fit:contain!important;}"
        ".video-layer{z-index:1!important;pointer-events:none!important;}"
        ".touch-layer{z-index:10!important;pointer-events:auto!important;touch-action:none!important;-webkit-user-select:none!important;user-select:none!important;-webkit-touch-callout:none!important;}"
        "*{-webkit-tap-highlight-color:transparent!important;}"
        "';"
        "document.documentElement.appendChild(s);"
        "})();";
    WKUserScript *script = [[WKUserScript alloc] initWithSource:cleanUI injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    [config.userContentController addUserScript:script];

    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    self.webView.navigationDelegate = self;
    self.webView.backgroundColor = UIColor.blackColor;
    self.webView.opaque = NO;
    self.webView.allowsLinkPreview = NO;
    self.webView.userInteractionEnabled = YES;

    // Do NOT disable WKWebView's UIScrollView: on iOS that can prevent the web
    // touch pipeline from delivering touchstart/touchmove to the touch canvas.
    // Page scrolling is blocked by CSS instead.
    self.webView.scrollView.backgroundColor = UIColor.blackColor;
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.scrollEnabled = YES;
    self.webView.scrollView.multipleTouchEnabled = YES;
    self.webView.scrollView.delaysContentTouches = NO;
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

    [self.view addSubview:self.webView];
    [NSLayoutConstraint activateConstraints:@[
        [self.webView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ]];

    // H.264 is forced because this Xiaomi/iPhone combination does not decode
    // the H.265 stream correctly. deviceKind=phone forces ws-scrcpy Touch mode.
    NSString *urlString = @"https://skynote.tailc55cbf.ts.net/embed.html?device=9b8e6c50&host=skynote.tailc55cbf.ts.net&port=443&secure=true&codec=h264&maxFps=30&bitrate=6000000&maxSize=1920&audio=false&keyboard=true&deviceKind=phone";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.0];
    [self.webView loadRequest:request];
}

- (BOOL)prefersHomeIndicatorAutoHidden { return YES; }
- (BOOL)prefersStatusBarHidden { return YES; }

@end
