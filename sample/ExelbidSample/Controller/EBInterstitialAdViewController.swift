//
//  EBInterstitialAdViewController.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/01/29.
//

import UIKit
import ExelBidSDK

class EBInterstitialAdViewController: UIViewController {
    @IBOutlet var keywordsTextField: UITextField!
    @IBOutlet var isTest: UIButton!
    @IBOutlet var loadAdButton: UIButton!
    @IBOutlet var showAdButton: UIButton!
  
    var interstitial: EBInterstitialAdController?
    var info: EBAdInfoModel?
    
}

extension EBInterstitialAdViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        keywordsTextField.text = info?.ID
    }
    

    @IBAction func loadAdClicked(_ sender: UIButton) {
        guard let identifier = keywordsTextField.text else {
            return
        }
        
        loadAdButton.isEnabled = false
        
        keywordsTextField.resignFirstResponder()

        interstitial = EBInterstitialAdController(adUnitId: identifier)
        if let interstitial = interstitial {
            interstitial.delegate = self
            
            // 광고의 효율을 높이기 위해 옵션 설정
            interstitial.yob = "1987"
            interstitial.gender = "M"

            // 테스트 광고 설정 (true - 테스트 광고가 응답)
            interstitial.testing = isTest.isSelected
            
            interstitial.loadAd()
        }
    }
    
    @IBAction func showAdButton(_ sender: UIButton) {
        showAdButton.isEnabled = false
        
        if let interstitial = interstitial {
            interstitial.showFromViewController(self)
        } else {
            "Error Interstitial".alert(self)
        }
    }
    
    @IBAction func toggleTestButton(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        keywordsTextField.resignFirstResponder()
    }
}

extension EBInterstitialAdViewController: EBInterstitialAdControllerDelegate {
    func interstitialDidLoadAd(_ interstitial: EBInterstitialAdController?) {
        showAdButton.isEnabled = true
        loadAdButton.isEnabled = true
        "Load Ad".alert(self)
    }
    
    func interstitialDidFailToLoadAd(_ interstitial: EBInterstitialAdController?) {
        loadAdButton.isEnabled = true
        "Fail Load Ad".alert(self)
    }
    
    func interstitialDidExpire(_ interstitial: EBInterstitialAdController?) {
        loadAdButton.isEnabled = true
        showAdButton.isHidden = true
    }
    
    func interstitialWillAppear(_ interstitial: EBInterstitialAdController?) {
        
    }
    
    func interstitialDidAppear(_ interstitial: EBInterstitialAdController?) {
        
    }

    func interstitialWillDisappear(_ interstitial: EBInterstitialAdController?) {
        showAdButton.isEnabled = false
    }

    func interstitialDidDisappear(_ interstitial: EBInterstitialAdController?) {
        
    }

    func interstitialDidReceiveTapEvent(_ interstitial: EBInterstitialAdController?) {
        
    }
}
