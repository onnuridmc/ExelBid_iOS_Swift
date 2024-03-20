//
//  EBBannerAdViewController.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/01/20.
//

import UIKit
import ExelBidSDK

class EBBannerAdViewController: UIViewController {
    @IBOutlet var adViewContainer: UIView!
    @IBOutlet var keywordsTextField: UITextField!
    @IBOutlet var loadAdButton: UIButton!
    
    var info: EBAdInfoModel?
    var adView: EBAdView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        keywordsTextField.text = info?.ID
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        adView?.stopAutomaticallyRefreshingContents()   //광로 리로드를 종료
//    }
   
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

extension EBBannerAdViewController {
    @IBAction func loadAdClicked(_ sender: UIButton) {
        if adView != nil {
            adView?.removeFromSuperview()
            adView = nil
        }
        keywordsTextField.resignFirstResponder()
        
        self.adView = EBAdView(adUnitId: keywordsTextField.text, size: self.adViewContainer.bounds.size)
        
        if let adView = self.adView {
            adView.delegate = self
            adView.yob = "1976"
            adView.gender = "M"
            adView.fullWebView = true
            adView.testing = true
            
            self.adViewContainer.addSubview(adView)
            
            setAutoLayout(view: self.adViewContainer, adView: adView)
            
            adView.loadAd()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        keywordsTextField.resignFirstResponder()
    }
    
   
}

extension EBBannerAdViewController: EBAdViewDelegate {
    func adViewDidLoadAd(_ view: EBAdView?) {
    }
    
    func adViewDidFailToLoadAd(_ view: EBAdView?) {
    }
    
}
