//
//  EBNativeVideoAdViewController.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/03/26.
//

import UIKit
import ExelBidSDK

class EBNativeVideoAdViewController: UIViewController {

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
    
    override func viewWillDisappear(_ animated: Bool) {
        clearAd()
    }
}

extension EBNativeVideoAdViewController {
    @IBAction func loadAdClicked(_ sender: UIButton) {
        guard let identifier = keywordsTextField.text else {
            return
        }
        keywordsTextField.endEditing(true)
        
        loadAdButton.isEnabled = false
        clearAd()
        
        // Create and configure a renderer configuration for native ads.
        let ebNativeManager = ExelBidNativeManager(identifier, EBNativeAdView.self)
        
        // 광고의 효율을 높이기 위해 옵션 설정
        ebNativeManager.yob("1987")
        ebNativeManager.gender("M")
        ebNativeManager.testing(true)

        // 네이티브 광고 요청시 어플리케이션에서 필수로 요청할 항목들을 설정합니다.
        ebNativeManager.desiredAssets([EBNativeAsset.kAdTitleKey,
                                       EBNativeAsset.kAdTextKey,
                                       EBNativeAsset.kAdIconImageKey,
                                       EBNativeAsset.kAdVideo,
                                       EBNativeAsset.kAdCTATextKey])

        ebNativeManager.startWithCompletionHandler { (request, response, error) in
            if let error = error {
                print(">>> Native Video Error : \(error.localizedDescription)")
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
        nativeAd?.stopNativeVideo()
        nativeAd = nil
    }
    
    func displayAd() {
        loadAdButton.isEnabled = true
        adViewContainer.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        if let adView = nativeAd?.retrieveAdViewWithError(nil) {
            adViewContainer.addSubview(adView)
            setAutoLayout2(view: adViewContainer, adView: adView)
        }
    }
    
    func configureAdLoadFail() {
        loadAdButton.isEnabled = true
    }
}

extension EBNativeVideoAdViewController: EBNativeAdDelegate {
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
