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
        
        // Create and configure a renderer configuration for native ads.
        ExelBidNativeManager.initNativeAdWithAdUnitIdentifier(identifier, EBNativeAdView.self)
        ExelBidNativeManager.testing(true)
        ExelBidNativeManager.yob("1976")
        ExelBidNativeManager.gender("M")
        
        ExelBidNativeManager.desiredAssets(NSSet(objects:EBNativeAsset.kAdIconImageKey,
                                                 EBNativeAsset.kAdMainImageKey,
                                                 EBNativeAsset.kAdCTATextKey,
                                                 EBNativeAsset.kAdTextKey,
                                                 EBNativeAsset.kAdTitleKey));

        ExelBidNativeManager.startWithCompletionHandler { (request, response, error) in
            if error != nil {
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

extension EBNativeAdViewController: EBNativeAdDelegate {
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
