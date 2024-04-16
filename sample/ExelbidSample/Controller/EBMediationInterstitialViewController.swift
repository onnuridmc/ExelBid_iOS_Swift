//
//  EBMediationInterstitialViewController.swift
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

class EBMediationInterstitialViewController : UIViewController, EBInterstitialAdControllerDelegate, GADFullScreenContentDelegate, FBInterstitialAdDelegate, IAUnitDelegate, PAGLInterstitialAdDelegate, TnkAdListener, MAAdDelegate {
    
    @IBOutlet var keywordsTextField: UITextField!
    @IBOutlet var loadAdButton: UIButton!
    @IBOutlet var showAdButton: UIButton!
    
    var info: EBAdInfoModel?
    var mediationManager: EBMediationManager?
    var ebInterstitialAd: EBInterstitialAdController?
    
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
            EBMediationTypes.facebook,
            EBMediationTypes.adfit,
            EBMediationTypes.digitalturbine,
            EBMediationTypes.pangle,
            EBMediationTypes.tnk,
            EBMediationTypes.applovin
        ];
        
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

extension EBMediationInterstitialViewController {
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
            case EBMediationTypes.facebook:
                self.loadFan(mediation: mediation)
            case EBMediationTypes.digitalturbine:
                self.loadDT(mediation: mediation)
            case EBMediationTypes.pangle:
                self.loadPangle(mediation: mediation)
            case EBMediationTypes.tnk:
                self.loadTnk(mediation: mediation)
            case EBMediationTypes.applovin:
                self.loadApplovin(mediation: mediation)
            default:
                self.loadMediation()
            }
        } else {
            self.emptyMediation()
        }
    }
    
    func emptyMediation() {
        print("Mediation Empty")
        // 미디에이션 리셋 또는 광고 없음 처리
//        self.mediationManager?.reset()
//        self.loadMediation()
    }
    
    func loadExelBid(mediation: EBMediationWrapper) {
        self.ebInterstitialAd = EBInterstitialAdController.interstitialAdControllerForAdUnitId(mediation.unit_id);
        if let interstitial = self.ebInterstitialAd {
            interstitial.delegate = self
            interstitial.yob = "1990"
            interstitial.gender = "M"
            interstitial.testing = true
            interstitial.loadAd()
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
    
    func loadFan(mediation: EBMediationWrapper) {
        self.fanInterstitialAd = FBInterstitialAd(placementID: mediation.unit_id)
        self.fanInterstitialAd?.delegate = self

        self.fanInterstitialAd?.load()
    }
    
    func loadDT(mediation: EBMediationWrapper) {
        IASDKCore.sharedInstance().userData = IAUserData.build() { builder in
            builder.age = 30
            builder.gender = IAUserGenderType.male
            builder.zipCode = "90210"
        }
        IASDKCore.sharedInstance().keywords = "swimming, music"
        
        var adRequest = IAAdRequest.build() { builder in
            builder.useSecureConnections = false
            builder.spotID = mediation.unit_id
            builder.timeout = 5
        }
        
        self.dtFullUnitController = IAFullscreenUnitController.build() { builder in
            builder.unitDelegate = self
        }
        
        if let adRequest = adRequest, let unitController = self.dtFullUnitController {
            self.dtAdSpot = IAAdSpot.build() { builder in
                builder.adRequest = adRequest
                builder.addSupportedUnitController(unitController)
            }
        }
        
        self.dtAdSpot?.fetchAd() { (adSpot, adModel, error) in
            if let error = error {
                print("Failed to get an ad: \(error.localizedDescription)")
            } else {
                if adSpot?.activeUnitController == self.dtFullUnitController {
                    self.dtFullUnitController?.showAd(animated: true, completion: nil)
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
                
                if let interstitial = interstitialAd {
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
    
    
    // MARK: EBInterstitialAdControllerDelegate
    
    func interstitialDidLoadAd(_ interstitial: EBInterstitialAdController?) {
        self.ebInterstitialAd?.showFromViewController(self)
    }
    
    func interstitialDidFailToLoadAd(_ interstitial: EBInterstitialAdController?) {
        self.loadMediation()
    }
    
    func interstitialWillAppear(_ interstitial: EBInterstitialAdController?) {
        
    }
    
    func interstitialWillDisappear(_ interstitial: EBInterstitialAdController?) {
        
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
