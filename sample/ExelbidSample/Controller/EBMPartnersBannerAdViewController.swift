//
//  EBMPartnersBannerAdViewController.swift
//  ExelbidSample
//
//  Created by Jaeuk Jeong on 7/31/24.
//

import UIKit
import ExelBidSDK

class EBMPartnersBannerAdViewController: UIViewController {
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

extension EBMPartnersBannerAdViewController {
    @IBAction func loadAdClicked(_ sender: UIButton) {
        if adView != nil {
            adView?.removeFromSuperview()
            adView = nil
        }
        keywordsTextField.resignFirstResponder()
        
        // MPartners Ad View 생성
        self.adView = MPartnersAdView(adUnitId: keywordsTextField.text, size: self.adViewContainer.bounds.size)
        
        if let adView = self.adView {
            adView.delegate = self
            
            // AdView 안에 너비 100%로 웹뷰가 바인딩되게 설정하려면 아래와 같이 메소드를 추가할 수 있습니다.
            // 기본 상태는 설정된 광고사이즈로 센터정렬되어 바인딩 된다.
            adView.fullWebView = true
            
            // 광고의 효율을 높이기 위해 옵션 설정
            adView.yob = "1987"
            adView.gender = "M"
            // adView.testing = true
            
            self.adViewContainer.addSubview(adView)
            
            setAutoLayout(view: self.adViewContainer, adView: adView)
            
            adView.loadAd()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        keywordsTextField.resignFirstResponder()
    }
   
}

extension EBMPartnersBannerAdViewController: EBAdViewDelegate {
    func adViewDidLoadAd(_ view: EBAdView?) {
        print("adViewDidLoadAd.")
    }

    func adViewDidFailToLoadAd(_ view: EBAdView?) {
        print("adViewDidFailToLoadAd.")
    }

    func willLeaveApplicationFromAd(_ view: EBAdView?) {
        print("willLeaveApplicationFromAd.")
    }
}
