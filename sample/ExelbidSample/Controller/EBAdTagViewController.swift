//
//  EBAdTagViewController.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by Jaeuk Jeong on 2023/07/24.
//

import UIKit
import WebKit

class EBAdTagViewController: UIViewController {
    
    @IBOutlet var webView: WKWebView!

    var info: EBAdInfoModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 광고식별자와 위치 승인 요청은 광고 요청 전에 완료되야합니다.

        // 광고식별자 - 사용자 승인 요청 및 가져오기
        EBAdTagSupport.shared.requestTrackingAuthorization() { _ in
            // 위치 - 사용자 승인 요청
            EBAdTagSupport.shared.requestLocation()
        }
        
        EBAdTagSupport.shared.coppa = true
        EBAdTagSupport.shared.yob = "1987"
        EBAdTagSupport.shared.gender = "M"
        EBAdTagSupport.shared.segment = ["segment_01" : "keyword"]
        
        let adTargetInfo: String = EBAdTagSupport.shared.adTargetInfo.jsonString()
        
        let webViewConfig = WKWebViewConfiguration()
        let userController = WKUserContentController()

        webViewConfig.processPool = WKProcessPool()
        webViewConfig.allowsInlineMediaPlayback = true
        webViewConfig.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypes.audio

        // 메시지 핸들러 추가
        userController.add(self, name: "mysdk")

        // 문서 로드 전에 스크립트 동작
        userController.addUserScript(WKUserScript(source: String(format: "adTargetInfo=%@", adTargetInfo), injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: true))

        webViewConfig.userContentController = userController

        webView = WKWebView(frame: self.view.frame, configuration: webViewConfig)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        
        if let htmlFile = Bundle.main.path(forResource: "index", ofType: "html") {
            webView.load(URLRequest(url: URL(fileURLWithPath: htmlFile)))
        }
    }
}

extension EBAdTagViewController: WKUIDelegate {
    
}

extension EBAdTagViewController: WKNavigationDelegate {
    
}

extension EBAdTagViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // 요청된 메시지 핸들러 명
        if message.name == "mysdk" {
            let adTargetInfo: String = EBAdTagSupport.shared.adTargetInfo.jsonString()

            // WebView 내 스크립트 실행
            self.webView.evaluateJavaScript(String(format: "adTargetInfo=%@", adTargetInfo)) { result, error in
                print("evaluateJavaScript")
            }
        }
            
    }
}

