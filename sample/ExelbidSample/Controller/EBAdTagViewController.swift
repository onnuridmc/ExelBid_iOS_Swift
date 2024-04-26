//
//  EBAdTagViewController.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by Jaeuk Jeong on 2023/07/24.
//

import UIKit
import WebKit
import AdSupport
import ExelBidSDK

class EBAdTagViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    @IBOutlet var webView: WKWebView!

    var info: EBAdInfoModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EBAdTagSupport.shared.coppa = true
        EBAdTagSupport.shared.yob = "1987"
        EBAdTagSupport.shared.gender = "M"
        EBAdTagSupport.shared.segment = ["segment_01" : "keyword"]
        
        let webViewConfig = WKWebViewConfiguration()
        let userController = WKUserContentController()

        webViewConfig.processPool = WKProcessPool()
        webViewConfig.allowsInlineMediaPlayback = true
        webViewConfig.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypes.audio

        // 메시지 핸들러 추가
        userController.add(self, name: "exelbidAdTag")

        webViewConfig.allowsInlineMediaPlayback = true
        webViewConfig.mediaTypesRequiringUserActionForPlayback = .audio
        webViewConfig.userContentController = userController

        webView = WKWebView(frame: self.view.frame, configuration: webViewConfig)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        
        if let htmlFile = Bundle.main.path(forResource: "index", ofType: "html") {
            webView.load(URLRequest(url: URL(fileURLWithPath: htmlFile)))
        }
    }
    
    // MARK: - WKNavigationDelegate
    // 페이지 이동시 scheme이나 host에 따라 분기처리
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url {
            print("decidePolicyForNavigationAction URL : \(url.absoluteString)")
            print("decidePolicyForNavigationAction URL scheme : \(String(describing: url.scheme))")
            print("decidePolicyForNavigationAction URL host : \(String(describing: url.host))")
            print("decidePolicyForNavigationAction URL path : \(url.path)")
            print("decidePolicyForNavigationAction URL query : \(String(describing: url.query))")

            // 대상 프레임이 존재하며 메인프레임(최상위 Document)일 경우
            if let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame {
                
                // URL 채크
                if url.scheme == "http" || url.scheme == "https" {
                    // HTTP 링크
                    
                    // URL host 확인
                    if url.host == "@DOMAIN" {
                        // 같은 도메인
                        
                        // 허용 처리
                        decisionHandler(.allow)
                    } else {
                        // 다른 도메인 (외부 브라우저로 열기)
                        // 매체의 컨텐츠 도메인이 아닌경우 광고로 판단하여 광고 클릭 처리(외부 브라우저 처리)를 시도한다.
                        
                        // 차단 처리
                        decisionHandler(.cancel);
                        
                        UIApplication.shared.open(url, options: [:]) { result in
                            if (result) {
                                // 성공

                            } else {
                                // 실패

                            }
                        }
                    }
                } else {
                    // scheme이 http프로토콜이 아닌경우 (딥링크 등)
                    
//                    UIApplication.shared.open(url, options: [:]) { result in
//                        if (result) {
//                            // 성공
//
//                        } else {
//                            // 실패
//
//                        }
//                    }
                    
                    // 임시 허용 처리
                    decisionHandler(.allow);
                }
            } else {
                // 새창 이벤트 또는 메인 프레임이 아닌곳에서 페이지 이동
                // 기본적으로 허용 처리
                decisionHandler(.allow);
            }
        }
        
    }
    
    // Window.popup, <a target="_blank"> 등 새창 이벤트
    // 매체의 컨텐츠 도메인이 아닌경우 광고로 판단하여 광고 클릭 처리(외부 브라우저 처리)를 시도한다.
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            UIApplication.shared.open(url, options: [:]) { result in
                if (result) {
                    // 성공

                } else {
                    // 실패

                }
            }
        }
        
        return nil
    }
    
    
    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let name = message.name

        if let webView = message.webView {
            switch name {
                case "exelbidAdTag":
                    if let callback = message.body as? String {
                        webView.evaluateJavaScript("\(callback)(\(EBAdTagSupport.shared.params));")
                    }
                default:
                    break
            }
            
        }
        
    }
}

