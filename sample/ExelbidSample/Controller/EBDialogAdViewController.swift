//
//  EBDialogAdViewController.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/02/09.
//

import UIKit
import ExelBidSDK

class EBDialogAdViewController: UIViewController {
    @IBOutlet var keywordsTextField1: UITextField!
    @IBOutlet var isTest1: UIButton!
    @IBOutlet var loadBannerAdButton: UIButton!
    @IBOutlet var showBannerAdButton: UIButton!
    
    @IBOutlet var keywordsTextField2: UITextField!
    @IBOutlet var isTest2: UIButton!
    @IBOutlet var loadNativeAdButton: UIButton!
    @IBOutlet var showNativeAdButton: UIButton!
   
    var info: EBAdInfoModel?
    var nativeAd: EBNativeAd?
    var adView: EBAdView?
  
    var bannerDialogView: EBBannerDialogView?
    var nativeDialogView: EBNativeDialogView?


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        keywordsTextField1.text = info?.ID.components(separatedBy: ",")[0]
        keywordsTextField2.text = info?.ID.components(separatedBy: ",")[1]
        
        bannerDialogView = EBBannerDialogView(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        nativeDialogView = EBNativeDialogView(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
    }

}

extension EBDialogAdViewController {
    @IBAction func loadBannerAdClicked(_ sender: UIButton) {
        guard let identifier = keywordsTextField1.text, let bannerDialogView = bannerDialogView else {
            return
        }
        
        loadBannerAdButton.isEnabled = false
        
        keywordsTextField1.resignFirstResponder()
        
        adView = EBAdView(adUnitId: identifier, size: bannerDialogView.bounds.size)
        
        if let adView = adView {
            adView.delegate = self

            // AdView 안에 너비 100%로 웹뷰가 바인딩되게 설정하려면 아래와 같이 메소드를 추가할 수 있습니다.
            // 기본 상태는 설정된 광고사이즈로 센터정렬되어 바인딩 된다.
            adView.fullWebView = true
            
            // 광고의 효율을 높이기 위해 옵션 설정
            adView.yob = "1987"
            adView.gender = "M"

            // 테스트 광고 설정 (true - 테스트 광고가 응답)
            adView.testing = isTest1.isSelected
            
            adView.loadAd()
        }
    }
    
    @IBAction func showBannerAdButton(_ sender: UIButton) {
        showBannerAdButton.isEnabled = false

        if let adView = adView, let bannerDialogView = bannerDialogView {
            
            bannerDialogView.adView.subviews.forEach { subview in
                subview.removeFromSuperview()
            }

            // 광고 뷰 추가
            bannerDialogView.adView.addSubview(adView)
            // 광고 뷰 autolayout
            adView.setAutoLayout(view: bannerDialogView.adView)
            
            // 배너 다이얼로그 뷰
            if let naviView = navigationController?.view {
                naviView.addSubview(bannerDialogView)
                bannerDialogView.setAutoLayout(view: naviView)
            }
        }
    }
   
    @IBAction func loadNativeAdClicked(_ sender: UIButton) {
        guard let identifier = keywordsTextField2.text else {
            return
        }
        
        keywordsTextField2.endEditing(true)
        
        loadNativeAdButton.isEnabled = false
        
        
        let ebNativeManager = ExelBidNativeManager(identifier, EBNativeAdView.self)
        
        // 광고의 효율을 높이기 위해 옵션 설정
        ebNativeManager.yob("1987")
        ebNativeManager.gender("M")
        
        // 테스트 광고 설정 (true - 테스트 광고가 응답)
        ebNativeManager.testing(isTest2.isSelected)

        // 네이티브 광고 요청시 어플리케이션에서 필수로 요청할 항목들을 설정합니다.
        ebNativeManager.desiredAssets([EBNativeAsset.kAdIconImageKey,
                                       EBNativeAsset.kAdMainImageKey,
                                       EBNativeAsset.kAdCTATextKey,
                                       EBNativeAsset.kAdTextKey,
                                       EBNativeAsset.kAdTitleKey])

        ebNativeManager.startWithCompletionHandler { (request, response, error) in
            self.loadNativeAdButton.isEnabled = true

            if let error = error {
                print(">>> Native Error : \(error.localizedDescription)")

                "Fail Load Native Ad".alert(self)
            }else{
                self.nativeAd = response
                self.nativeAd?.delegate = self
                
                self.showNativeAdButton.isEnabled = true
                "Load Native Ad".alert(self)
            }
        }
    }
   
    @IBAction func showNativeAdButton(_ sender: UIButton) {
        guard let nativeDialogView = nativeDialogView else {
            return
        }
        nativeDialogView.adView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        if let adView = nativeAd?.retrieveAdViewWithError(nil) {
            nativeDialogView.adView.addSubview(adView)
            adView.setAutoLayout(view: nativeDialogView.adView)
            if let naviView = navigationController?.view {
                naviView.addSubview(nativeDialogView)
                nativeDialogView.setAutoLayout(view: naviView)
            }
        }
    }
}

extension EBDialogAdViewController {
    
    @IBAction func toggleTestButton(_ sender: UIButton) {
        sender.isSelected.toggle()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        keywordsTextField1.resignFirstResponder()
        keywordsTextField2.resignFirstResponder()
    }

}


extension EBDialogAdViewController: EBAdViewDelegate {
    func adViewDidLoadAd(_ view: EBAdView?) {
        showBannerAdButton.isEnabled = true
        loadBannerAdButton.isEnabled = true
        "Load Banner Ad".alert(self)
    }
    
    func adViewDidFailToLoadAd(_ view: EBAdView?) {
        loadBannerAdButton.isEnabled = true
        "Fail Load Banner Ad".alert(self)
    }
    
}

extension EBDialogAdViewController: EBNativeAdDelegate {
    func willLoadForNativeAd(_ nativeAd: EBNativeAd?) {
        print("Will Load for native ad.")
    }
    
    func didLoadForNativeAd(_ nativeAd: EBNativeAd?) {
        print("Did Load for native ad.")
    }
    
    func willLeaveApplicationFromNativeAd(_ nativeAd: EBNativeAd?) {
        print("Will leave application from native ad.")
    }
    
    func viewControllerForPresentingModalView() -> UIViewController? {
       return self
    }
    
}
