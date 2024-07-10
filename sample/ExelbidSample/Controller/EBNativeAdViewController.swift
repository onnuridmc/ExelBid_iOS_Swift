//
//  EBNativeAdViewController.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/02/04.
//

import UIKit
import ExelBidSDK

class EBNativeAdViewController: UIViewController {
    @IBOutlet var adViewContainer: UIView!
    @IBOutlet var keywordsTextField: UITextField!
    @IBOutlet var loadAdButton: UIButton!
   
    var info: EBAdInfoModel?
    var nativeAd: EBNativeAd?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        keywordsTextField.text = info?.ID
        loadAdButton.layer.cornerRadius = 3.0
    }
    
}

extension EBNativeAdViewController {
    @IBAction func loadAdClicked(_ sender: UIButton) {
        guard let identifier = keywordsTextField.text else {
            return
        }
        keywordsTextField.endEditing(true)
        
        loadAdButton.isEnabled = false
        clearAd()
        
        let ebNativeManager = ExelBidNativeManager(identifier, EBNativeAdView.self)
        
        // 광고의 효율을 높이기 위해 옵션 설정
        ebNativeManager.yob("1987")
        ebNativeManager.gender("M")
//        ebNativeManager.testing(true)

        // 네이티브 광고 요청시 어플리케이션에서 필수로 요청할 항목들을 설정합니다.
        ebNativeManager.desiredAssets([EBNativeAsset.kAdIconImageKey,
                                       EBNativeAsset.kAdMainImageKey,
                                       EBNativeAsset.kAdCTATextKey,
                                       EBNativeAsset.kAdTextKey,
                                       EBNativeAsset.kAdTitleKey])

        ebNativeManager.startWithCompletionHandler { (request, response, error) in
            self.loadAdButton.isEnabled = true

            if let error = error {
                print(">>> Native Error : \(error.localizedDescription)")
                self.configureAdLoadFail()
            }else{
                self.nativeAd = response
                self.nativeAd?.delegate = self
                self.displayAd()
            }
        }

    }

    func clearAd() {
        adViewContainer.subviews.forEach { subview in
            subview.removeFromSuperview()
        }

        nativeAd = nil
    }
    
    func displayAd() {
        self.loadAdButton.isEnabled = true
        self.adViewContainer.subviews.forEach { subview in
            subview.removeFromSuperview()
        }

        if let adView = self.nativeAd?.retrieveAdViewWithError(nil) {
            self.adViewContainer.addSubview(adView)
            self.setAutoLayout2(view: self.adViewContainer, adView: adView)
        } else {
            print(">>> ERROR Native displayAd")
        }
    }
    
    func configureAdLoadFail() {
        self.loadAdButton.isEnabled = true
    }
}

extension EBNativeAdViewController: EBNativeAdDelegate {
    func willLoadForNativeAd(_ nativeAd: EBNativeAd?) {
        print(">>> Will Load for native ad.")
    }
    
    func didLoadForNativeAd(_ nativeAd: EBNativeAd?) {
        print(">>> Did Load for native ad.")
    }
    
    func willLeaveApplicationFromNativeAd(_ nativeAd: EBNativeAd?) {
        print(">>> Will leave application from native ad.")
    }
    
    func viewControllerForPresentingModalView() -> UIViewController? {
        return self
    }
    
    
}
