//
//  EBMediationInterstitialVideoViewController.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by Jaeuk Jeong on 3/15/24.
//

import Foundation
import UIKit
import AppTrackingTransparency
import ExelBidSDK

// AdMob
import GoogleMobileAds

// Facebook
import FBAudienceNetwork

// Digital Turbine
import IASDKCore

// Pangle
import PAGAdSDK

// Tnk
import TnkPubSdk

// Applovin
import AppLovinSDK

class EBMediationInterstitialVideoViewController : UIViewController, EBVideoDelegate, GADFullScreenContentDelegate, FBInterstitialAdDelegate, IAUnitDelegate, PAGLInterstitialAdDelegate, TnkAdListener, MAAdDelegate {
    
    @IBOutlet var keywordsTextField: UITextField!
    @IBOutlet var loadAdButton: UIButton!
    @IBOutlet var showAdButton: UIButton!
    
    var info: EBAdInfoModel?
    var mediationManager: EBMediationManager?
    
    // AdMob
    var gaInterstital: GADInterstitialAd?
    
    // Facebook
    var fanInterstitialAd: FBInterstitialAd?

    // Digital Turbine
    var dtAdSpot: IAAdSpot?
    var dtFullUnitController: IAFullscreenUnitController?
    
    // Pangle
    var pagIntersitial: PAGLInterstitialAd?
    
    // Applovin
    var alInterstitialAd: MAInterstitialAd!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showAdButton.isHidden = true
        self.keywordsTextField.text = self.info?.ID
    }
    
    @IBAction func didTapLoadButton(_ sender: UIButton) {
        self.keywordsTextField.endEditing(true)

        guard let unitId = self.keywordsTextField.text else {
            return
        }
        
        let mediationTypes = [
            EBMediationTypes.exelbid,
            EBMediationTypes.admob,
            EBMediationTypes.pangle
        ]
        
        mediationManager = EBMediationManager(adUnitId: unitId, mediationTypes: mediationTypes)
        
        if let mediationManager = mediationManager {
            self.showAdButton.isHidden = false
            
            mediationManager.requestMediation() { (manager, error) in
                if error != nil {
                    // 미디에이션 에러 처리
                }
            }
        }
    }
    
    @IBAction func didTapShowButton(_ sender: UIButton) {
        self.loadMediation()
    }
}

extension EBMediationInterstitialVideoViewController {
    func loadMediation() {
        guard let mediationManager = mediationManager else {
            self.emptyMediation()
            return
        }
        
        // 미디에이션 목록을 순차적으로 가져옴
        if let mediation = mediationManager.next() {
            
            print(">>>>> \(#function) : \(mediation.id)")
            
            switch mediation.id {
            case EBMediationTypes.exelbid:
                self.loadExelBid(mediation: mediation)
            case EBMediationTypes.admob:
                self.loadAdMob(mediation: mediation)
            case EBMediationTypes.pangle:
                self.loadPangle(mediation: mediation)
            default:
                self.loadMediation()
            }
        } else {
            self.emptyMediation()
        }
    }
    
    func emptyMediation() {
        print("Mediation Empty")
        // 미디에이션 목록이 비어있음. 광고 없음 처리.
    }
    
    func loadExelBid(mediation: EBMediationWrapper) {
        EBVideoManager.initFullVideo(identifier: mediation.unit_id)
        
        // 광고의 효율을 높이기 위해 옵션 설정
        EBVideoManager.yob("1987")
        EBVideoManager.gender("M")
//        EBVideoManager.testing(true)

        EBVideoManager.startWithCompletionHandler { (request, error) in
            if error != nil {
                self.loadMediation()
            } else {
                EBVideoManager.presentAd(controller: self, delegate: self)
            }
        }
    }
    
    func loadAdMob(mediation: EBMediationWrapper) {
        GADInterstitialAd.load(withAdUnitID: mediation.unit_id, request: GADRequest.init()) { (ad, error) in
            if let error = error {
                self.loadMediation()
            } else {
                self.gaInterstital = ad
                
                if let gaInterstital = self.gaInterstital {
                    gaInterstital.fullScreenContentDelegate = self
                    gaInterstital.present(fromRootViewController: self)
                }
            }
        }
    }
    
    func loadPangle(mediation: EBMediationWrapper) {
        var adRequest = PAGInterstitialRequest.init()
        
        PAGLInterstitialAd.load(withSlotID: mediation.unit_id, request: adRequest) { (interstitialAd, error) in
            if let error = error {
                self.loadMediation()
            } else {
                self.pagIntersitial = interstitialAd
                
                if let interstitial = self.pagIntersitial {
                    interstitial.delegate = self
                    interstitial.present(fromRootViewController: self)
                }
            }
        }
    }
    
    func loadTnk(mediation: EBMediationWrapper) {
        let adItem = TnkInterstitialAdItem(viewController: self, placementId: mediation.unit_id)
        adItem.setListener(self)
        adItem.load()
    }
    
    func loadApplovin(mediation: EBMediationWrapper) {
        self.alInterstitialAd = MAInterstitialAd(adUnitIdentifier: "YOUR_AD_UNIT_ID")
        self.alInterstitialAd.delegate = self

        // Load the first ad
        self.alInterstitialAd.load()
    }
    
    
    // MARK: EBVideoDelegate
    func videoAdDidLoad(adUnitID: String) {

    }

    func videoAdDidFailToLoad(adUnitID: String, error: any Error) {
        self.loadMediation()
    }
    
    // MARK: GADFullScreenContentDelegate
    
    func ad(_ ad: any GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: any Error) {
        self.loadMediation()
    }
    
    func adWillPresentFullScreenContent(_ ad: any GADFullScreenPresentingAd) {
        
    }
    
    func adWillDismissFullScreenContent(_ ad: any GADFullScreenPresentingAd) {
        
    }
    
    
    // MARK: FBInterstitialAdDelegate
    
    func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        if interstitialAd.isAdValid {
            interstitialAd.show(fromRootViewController: self)
        }
    }
    
    func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: any Error) {
        self.loadMediation()
    }
    
    
    // MARK: IAUnitDelegate
    
    func iaParentViewController(for unitController: IAUnitController?) -> UIViewController {
        return self
    }
    
    
    // MARK: PAGLInterstitialAdDelegate
    
    func adDidShow(_ ad: any PAGAdProtocol) {
        
    }
    
    func adDidDismiss(_ ad: any PAGAdProtocol) {
        
    }
    
    func adDidShowFail(_ ad: any PAGAdProtocol, error: any Error) {
        self.loadMediation()
    }
    
    
    // MARK: TnkAdListener
    func onLoad(_ adItem: any TnkAdItem) {
        if adItem.isLoaded() {
            adItem.show()
        }
    }
    
    func onError(_ adItem: any TnkAdItem, error: AdError) {
        self.loadMediation()
    }

    
    // MARK: MAAdDelegate
    func didLoad(_ ad: MAAd) {
        if self.alInterstitialAd.isReady {
            self.alInterstitialAd.show()
        }
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        self.loadMediation()
    }
    
    func didDisplay(_ ad: MAAd) {
        
    }
    
    func didHide(_ ad: MAAd) {
        
    }
    
    func didClick(_ ad: MAAd) {
        
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        self.loadMediation()
    }
    
}
