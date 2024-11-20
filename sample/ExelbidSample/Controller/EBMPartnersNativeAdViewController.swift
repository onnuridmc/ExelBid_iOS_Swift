//
//  EBMPartnersNativeAdViewController.swift
//  ExelbidSample
//
//  Created by Jaeuk Jeong on 7/31/24.
//

import UIKit
import ExelBidSDK

class EBMPartnersNativeAdViewController: UIViewController {
    @IBOutlet var adViewContainer: UIView!
    @IBOutlet var keywordsTextField: UITextField!
    @IBOutlet var isTest: UIButton!
    @IBOutlet var loadAdButton: UIButton!
    @IBOutlet var showAdButton: UIButton!
   
    var info: EBAdInfoModel?
    var nativeAd: EBNativeAd?
    
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
        adViewContainer.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
    }
    
}

extension EBMPartnersNativeAdViewController {
    @IBAction func loadAdClicked(_ sender: UIButton) {
        guard let identifier = keywordsTextField.text else {
            return
        }
        
        keywordsTextField.endEditing(true)
        
        loadAdButton.isEnabled = false
        
        let ebNativeManager = MPartnersNativeManager(identifier, EBNativeAdView.self)
        
        // 광고의 효율을 높이기 위해 옵션 설정
        ebNativeManager.yob("1987")
        ebNativeManager.gender("M")
        
        // 테스트 광고 설정 (true - 테스트 광고가 응답)
        ebNativeManager.testing(isTest.isSelected)

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
                
                "Fail Load Ad".alert(self)
            }else{
                self.nativeAd = response
                self.nativeAd?.delegate = self
                
                self.showAdButton.isEnabled = true
                "Load Ad".alert(self)
            }
        }

    }

    @IBAction func showAdButton(_ sender: UIButton) {
        showAdButton.isEnabled = false
        
        if let adView = nativeAd?.retrieveAdViewWithError(nil) {
            // 기존 광고 뷰 제거
            clearAd()
            
            adViewContainer.addSubview(adView)
            setAutoLayout2(view: adViewContainer, adView: adView)
        } else {
            "Error Native".alert(self)
        }
    }
    
    @IBAction func toggleTestButton(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        keywordsTextField.resignFirstResponder()
    }
}

extension EBMPartnersNativeAdViewController: EBNativeAdDelegate {
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
