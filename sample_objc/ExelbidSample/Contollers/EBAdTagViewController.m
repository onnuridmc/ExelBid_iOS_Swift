//
//  EBAdTagView.m
//  ExelbidSample
//
//  Created by Jaeuk Jeong on 2023/07/13.
//  Copyright © 2023 Zionbi. All rights reserved.
//

#import "EBAdTagViewController.h"
#import "EBAdTagSupport.h"

@interface EBAdTagViewController ()<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) IBOutlet WKWebView *webView;

@end

@implementation EBAdTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    WKWebViewConfiguration *webviewConfiguration = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    
    // Javascript에서 호출받을 핸들러 설정
    [userContentController addScriptMessageHandler:self name:@"exelbidAdTag"];

    webviewConfiguration.allowsInlineMediaPlayback = YES;
    webviewConfiguration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAudio;
    [webviewConfiguration setUserContentController:userContentController];

    _webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:webviewConfiguration];
    [_webView setUIDelegate:self];
    [_webView setNavigationDelegate:self];
    [self.view addSubview:_webView];

    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURL *requestUrl = [NSURL fileURLWithPath:htmlFile];
    [_webView loadRequest:[[NSURLRequest alloc] initWithURL:requestUrl]];
}

#pragma mark - <WKScriptMessageHandler>

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSString *name = message.name;
    WKWebView *webView = message.webView;
    
    NSLog(@"didReceiveScriptMessage : %@", name);
    
    if ([name isEqualToString:@"exelbidAdTag"]) {
        NSString * callback = message.body;
        
        [webView evaluateJavaScript:[NSString stringWithFormat:@"%@(%@)", callback, [[EBAdTagSupport sharedProvider] params]] completionHandler:^(id result, NSError *error) {
            if (error != nil) {    // evaluateJavaScript 에러
                NSLog(@"evaluateJavaScript Error : %@", error.localizedDescription);
            } else if (result != nil){    // evaluateJavaScript 성공 및 응답값
                NSLog(@"evaluateJavaScript Success Result : %@", [NSString stringWithFormat:@"%@", result]);
            }
        }];
    }
}

#pragma mark - <WKNavigationDelegate>

// 페이지 이동시 scheme이나 host에 따라 분기처리
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *url = navigationAction.request.URL;
    WKFrameInfo *targetFrame = navigationAction.targetFrame;

    if (url) {
        NSLog(@"decidePolicyForNavigationAction URL : %@", [url absoluteString]);
        NSLog(@"decidePolicyForNavigationAction URL scheme : %@", [url scheme]);
        NSLog(@"decidePolicyForNavigationAction URL host : %@", [url host]);
        NSLog(@"decidePolicyForNavigationAction URL path : %@", [url path]);
        NSLog(@"decidePolicyForNavigationAction URL query : %@", [url query]);
        NSLog(@"decidePolicyForNavigationAction targetFrame : %@", navigationAction.targetFrame);
        
        
        
        // 대상 프레임이 존재하며 메인프레임(최상위 Document)일 경우
        if (targetFrame != nil && targetFrame.isMainFrame == YES) {
            // URL 채크
            if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
                // HTTP 링크
                
                // URL host 확인
                if ([[url host] isEqualToString:@"도메인"]) {
                    // 같은 도메인
                    
                    // 허용 처리
                    decisionHandler(WKNavigationActionPolicyAllow);

                } else {
                    // 다른 도메인 (외부 브라우저로 열기)
                    // 매체의 컨텐츠 도메인이 아닌경우 광고로 판단하여 광고 클릭 처리(외부 브라우저 처리)를 시도한다.
                    
                    // 차단 처리
                    decisionHandler(WKNavigationActionPolicyCancel);

                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                        if (success) {
                            // 성공

                        } else {
                            // 실패

                        }
                    }];
                }
            } else {
                // scheme이 http프로토콜이 아닌경우 (딥링크 등)
                
//                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
//                    if (success) {
//                        // 성공
//
//                    } else {
//                        // 실패
//                    }
//                }];
                
                // 임시 허용 처리
                decisionHandler(WKNavigationActionPolicyAllow);
            }
        } else {
            // 새창 이벤트 또는 메인 프레임이 아닌곳에서 페이지 이동
            // 기본적으로 허용 처리
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    }

}

// Window.popup, <a target="_blank"> 등 새창 이벤트
// 매체의 컨텐츠 도메인이 아닌경우 광고로 판단하여 광고 클릭 처리(외부 브라우저 처리)를 시도한다.
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    NSURL *url = navigationAction.request.URL;
    
    @try {
        NSLog(@"createWebViewWithConfiguration URL : %@", [url absoluteString]);
        NSLog(@"createWebViewWithConfiguration URL scheme : %@", [url scheme]);
        NSLog(@"createWebViewWithConfiguration URL host : %@", [url host]);
        NSLog(@"createWebViewWithConfiguration URL path : %@", [url path]);
        NSLog(@"createWebViewWithConfiguration URL query : %@", [url query]);
        NSLog(@"createWebViewWithConfiguration targetFrame : %@", navigationAction.targetFrame);
        
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            if (success) {
                // 성공

            } else {
                // 실패

            }
        }];
    } @catch (NSException *error) {
        // URL을 처리할 수 없는 경우
    }
    
    return nil;
}

@end
