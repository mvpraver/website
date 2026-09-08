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

    // Hide every ws-scrcpy web control/status element and make the Android
    // framebuffer fill the entire app. Touch events still go to the video.
    NSString *cleanUI = @"(function(){"
        "var s=document.createElement('style');"
        "s.innerHTML='#status,.control-buttons-list,.control-wrapper{display:none!important;}"
        "html,body{margin:0!important;padding:0!important;width:100%!important;height:100%!important;background:#000!important;overflow:hidden!important;}"
        ".device-view{margin:0!important;padding:0!important;width:100vw!important;height:100vh!important;max-width:none!important;max-height:none!important;background:#000!important;}"
        ".video{margin:0!important;padding:0!important;width:100%!important;height:100%!important;display:flex!important;align-items:center!important;justify-content:center!important;background:#000!important;}"
        ".video canvas,.video video,canvas,video{max-width:100%!important;max-height:100%!important;}';"
        "document.documentElement.appendChild(s);"
        "})();";
    WKUserScript *script = [[WKUserScript alloc] initWithSource:cleanUI injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    [config.userContentController addUserScript:script];

    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    self.webView.navigationDelegate = self;
    self.webView.backgroundColor = UIColor.blackColor;
    self.webView.opaque = NO;
    self.webView.scrollView.backgroundColor = UIColor.blackColor;
    self.webView.scrollView.bounces = NO;
    [self.view addSubview:self.webView];

    [NSLayoutConstraint activateConstraints:@[
        [self.webView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ]];

    // Explicit secure WebSocket settings are required behind Tailscale HTTPS.
    NSString *urlString = @"https://skynote.tailc55cbf.ts.net/embed.html?device=9b8e6c50&host=skynote.tailc55cbf.ts.net&port=443&secure=true&codec=h264&maxFps=30&bitrate=6000000&maxSize=1920&audio=false&keyboard=true&deviceKind=phone";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.0];
    [self.webView loadRequest:request];
}

- (BOOL)prefersHomeIndicatorAutoHidden { return YES; }
- (BOOL)prefersStatusBarHidden { return YES; }

@end
