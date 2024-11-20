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
    @IBOutlet var isTest: UIButton!
    @IBOutlet var loadAdButton: UIButton!
    @IBOutlet var showAdButton: UIButton!
    
    var info: EBAdInfoModel?
    var adView: EBAdView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        keywordsTextField.text = info?.ID
    }
   
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func clearAd() {
        // 광고 영역 내 모든 뷰 제거
        self.adViewContainer.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
    }
}

extension EBMPartnersBannerAdViewController {
    @IBAction func loadAdClicked(_ sender: UIButton) {
        
        guard let identifier = keywordsTextField.text else {
            return
        }
        
        loadAdButton.isEnabled = false
        
        keywordsTextField.resignFirstResponder()
        
        // MPartners Ad View 생성
        self.adView = MPartnersAdView(adUnitId: identifier, size: CGSizeMake(320, 50))
        
        if let adView = self.adView {
            adView.delegate = self
            
            // AdView 안에 너비 100%로 웹뷰가 바인딩되게 설정하려면 아래와 같이 메소드를 추가할 수 있습니다.
            // 기본 상태는 설정된 광고사이즈로 센터정렬되어 바인딩 된다.
            adView.fullWebView = true
            
            // 광고의 효율을 높이기 위해 옵션 설정
            adView.yob = "1987"
            adView.gender = "M"
            
            // 테스트 광고 설정 (true - 테스트 광고가 응답)
            adView.testing = self.isTest.isSelected
            
            adView.loadAd()
        }
    }
    
    @IBAction func showAdClicked(_ sender: UIButton) {
        showAdButton.isEnabled = false
        
        if let adView = self.adView {
            // 기존 광고 뷰 제거
            self.clearAd()
            
            self.showAdButton.isEnabled = false
            
            // 광고 뷰 추가
            self.adViewContainer.addSubview(adView)
            // 광고 뷰 autolayout
            setAutoLayout(view: adViewContainer, adView: adView)
        }
    }
    
    @IBAction func toggleTestButton(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        keywordsTextField.resignFirstResponder()
    }
   
}

extension EBMPartnersBannerAdViewController: EBAdViewDelegate {
    func adViewDidLoadAd(_ view: EBAdView?) {
        "Load Ad".alert(self)
        showAdButton.isEnabled = true
        loadAdButton.isEnabled = true
    }

    func adViewDidFailToLoadAd(_ view: EBAdView?) {
        "Fail Load Ad".alert(self)
        loadAdButton.isEnabled = true
    }

    func willLeaveApplicationFromAd(_ view: EBAdView?) {
        print("willLeaveApplicationFromAd.")
    }
}
