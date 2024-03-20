//
//  EBFrontBannerAdViewController.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/01/29.
//

import UIKit
import ExelBidSDK

class EBFrontBannerAdViewController: UIViewController {
    @IBOutlet var keywordsTextField: UITextField!
    @IBOutlet var loadAdButton: UIButton!
    @IBOutlet var showAdButton: UIButton!
  
    var interstitial: EBInterstitialAdController?
    var info: EBAdInfoModel?
    
}

extension EBFrontBannerAdViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.showAdButton.isHidden = true
        self.keywordsTextField.text = self.info?.ID
        self.loadAdButton.layer.cornerRadius = 3.0
        self.showAdButton.layer.cornerRadius = 3.0
    }
    

    @IBAction func didTapLoadButton(_ sender: UIButton) {
        self.keywordsTextField.endEditing(true)
        
        self.showAdButton.isHidden = true
        self.loadAdButton.isEnabled = false
    
        self.interstitial = EBInterstitialAdController.interstitialAdControllerForAdUnitId(self.keywordsTextField.text);
        if let interstitial = self.interstitial {
            interstitial.delegate = self
            interstitial.yob = "1990"
            interstitial.gender = "M"
            interstitial.testing = true
            interstitial.loadAd()
        }
    }
    
    @IBAction func didTapShowButton(_ sender: UIButton) {
        self.interstitial?.showFromViewController(self)
    }
}

extension EBFrontBannerAdViewController: EBInterstitialAdControllerDelegate {
    func interstitialDidLoadAd(_ interstitial: EBInterstitialAdController?) {
        self.showAdButton.isHidden = false
        self.loadAdButton.isEnabled = true
    }
    
    func interstitialDidFailToLoadAd(_ interstitial: EBInterstitialAdController?) {
        self.loadAdButton.isEnabled = true
    }
    
    func interstitialDidExpire(_ interstitial: EBInterstitialAdController?) {
        self.loadAdButton.isEnabled = true
        self.showAdButton.isHidden = true
    }
    
    func interstitialWillAppear(_ interstitial: EBInterstitialAdController?) {
        
    }
    
    func interstitialDidAppear(_ interstitial: EBInterstitialAdController?) {
        
    }

    func interstitialWillDisappear(_ interstitial: EBInterstitialAdController?) {
        self.showAdButton.isHidden = true
    }

    func interstitialDidDisappear(_ interstitial: EBInterstitialAdController?) {
        
    }

    func interstitialDidReceiveTapEvent(_ interstitial: EBInterstitialAdController?) {
        
    }
}
