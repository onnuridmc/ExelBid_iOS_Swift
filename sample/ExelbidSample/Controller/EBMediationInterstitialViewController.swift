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

// TargetPick
import LibADPlus

class EBMediationInterstitialViewController : UIViewController {
    
    @IBOutlet var keywordsTextField: UITextField!
    @IBOutlet var loadButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    
    var info: EBAdInfoModel?
    var mediationManager: EBMediationManager?
    var ebInterstitialAd: EBInterstitialAdController?
    
    // AdMob
    var gaInterstital: InterstitialAd?
    
    // Facebook
    var fanInterstitialAd: FBInterstitialAd?

    // Digital Turbine
    var dtAdSpot: IAAdSpot?
    var dtFullUnitController: IAFullscreenUnitController?
    
    // Pangle
    var pagIntersitial: PAGLInterstitialAd?
    
    // Applovin
    var alInterstitialAd: MAInterstitialAd!
    
    // TargetPick
    let tpPublisherId: Int? = 1761
    let tpMediaId: Int? = 33372
 
    override func viewDidLoad() {
        super.viewDidLoad()

        self.keywordsTextField.text = self.info?.ID
    }
    
    @IBAction func didTapLoadButton(_ sender: UIButton) {
        guard let identifier = keywordsTextField.text else {
            return
        }

        self.keywordsTextField.endEditing(true)
        
        let mediationTypes = [
            EBMediationTypes.exelbid,
            EBMediationTypes.admob,
            EBMediationTypes.facebook,
            EBMediationTypes.adfit,
            EBMediationTypes.digitalturbine,
            EBMediationTypes.pangle,
            EBMediationTypes.tnk,
            EBMediationTypes.applovin,
            EBMediationTypes.targetpick
        ]
        
        mediationManager = EBMediationManager(adUnitId: identifier, mediationTypes: mediationTypes)
        
        if let mediationManager = mediationManager {

            mediationManager.requestMediation() { (manager, error) in
                if error != nil {
                    // 미디에이션 에러 처리
                    self.nextButton.isEnabled = false
                } else {
                    // 성공 처리
                    self.nextButton.isEnabled = true
                }
            }
        }
    }
    
    @IBAction func didTapNextButton(_ sender: UIButton) {
        self.loadMediation()
    }
}

extension EBMediationInterstitialViewController {
    
    // 미디에이션 목록 순차 처리
    func loadMediation() {
        guard let mediationManager = mediationManager else {
            self.emptyMediation()
            return
        }
        
        // 미디에이션 순서대로 가져오기 (더이상 없으면 nil)
        if let mediation = mediationManager.next() {
            
            print(">>>>> \(#function) : \(mediation.id), \(mediation.unit_id)")
            
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
            case EBMediationTypes.targetpick:
                self.loadTargetPick(mediation: mediation)
            default:
                self.loadMediation()
            }
        } else {
            self.emptyMediation()
        }
    }
    
    // 미디에이션 목록이 비어있음. 광고 없음 처리.
    func emptyMediation() {
        print("Mediation Empty")
    }
    
    // MARK: - 미디에이션 광고 호출
    
    // Exelbid 광고 호출
    func loadExelBid(mediation: EBMediationWrapper) {
        self.ebInterstitialAd = EBInterstitialAdController(adUnitId: mediation.unit_id)
        if let interstitial = self.ebInterstitialAd {
            interstitial.delegate = self
            
            // 광고의 효율을 높이기 위해 옵션 설정
            interstitial.yob = "1987"
            interstitial.gender = "M"
//            interstitial.testing = true
            
            interstitial.loadAd()
        }
    }
    
    // AdMob 광고 호출
    func loadAdMob(mediation: EBMediationWrapper) {
        Task {
            do {
                gaInterstital = try await InterstitialAd.load(with: mediation.unit_id, request: Request())
                gaInterstital?.fullScreenContentDelegate = self
                gaInterstital?.present(from: self)
            } catch {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                self.loadMediation()
            }
        }
    }
    
    // Fan 광고 호출
    func loadFan(mediation: EBMediationWrapper) {
        self.fanInterstitialAd = FBInterstitialAd(placementID: mediation.unit_id)
        self.fanInterstitialAd?.delegate = self
        
        self.fanInterstitialAd?.load()
    }
    
    // Digital Turbine 광고 호출
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
    
    // Pangle 광고 호출
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
    
    // TNK 광고 호출
    func loadTnk(mediation: EBMediationWrapper) {
        let adItem = TnkInterstitialAdItem(viewController: self, placementId: mediation.unit_id)
        adItem.setListener(self)
        adItem.load()
    }
    
    // AppLovin 광고 호출
    func loadApplovin(mediation: EBMediationWrapper) {
        self.alInterstitialAd = MAInterstitialAd(adUnitIdentifier: "YOUR_AD_UNIT_ID")
        self.alInterstitialAd.delegate = self
        
        // Load the first ad
        self.alInterstitialAd.load()
    }
    
    // TargetPick 광고 호출
    func loadTargetPick(mediation: EBMediationWrapper) {
        
        // withSectionID 데이터형을 맞추기 위해 unit_id를 정수로 변환
        if let section_id = Int(mediation.unit_id),
           let pub_id = self.tpPublisherId,
           let media_id = self.tpMediaId {
            
            let model = ADMZInterstitialModel(withPublisherID: pub_id,
                                              withMediaID: media_id,
                                              withSectionID: section_id,
                                              withKeywordParameter: "KeywordTargeting",
                                              withOtherParameter: "BannerAdditionalParameters",
                                              withMediaAgeLevel: .under13Age,
                                              withAppID:"appID",
                                              withAppName: "appName",
                                              withStoreURL: "StoreURL",
                                              withSMS: true,
                                              withTel: true,
                                              withCalendar: true,
                                              withStorePicture: true,
                                              withInlineVideo: true,
                                              withPopupType: .FullSize)
            model.setUserInfo(withGenderType: .Male,
                              withAge: 15,
                              withUserID: "mezzomedia",
                              withEmail: "mezzo@mezzomedia.co.kr",
                              withUserLocationAgree: false)
            
            // 필요에따라 이벤트 핸들러 구분
            let handler: ADMZEventHandler = { code in
                print(">>> \(#function) \(code) - \(code.rawValue)")
            }
            
            ADMZInterstitialLoader.presentAd(fromViewController:self,
                                             withModel: model,
                                             withSuccessHandler: handler,
                                             withFailedHandler: handler,
                                             withOtherEventHandler: handler)
            
        } else {
            // 예외 처리
            
            // 다음 미디에이션 호출
            self.loadMediation()
        }
    }
    
}

// MARK: - 광고 뷰 Delegate
extension EBMediationInterstitialViewController : EBInterstitialAdControllerDelegate, FullScreenContentDelegate, FBInterstitialAdDelegate, IAUnitDelegate, PAGLInterstitialAdDelegate, TnkAdListener, MAAdDelegate {
    
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
    
    
    // MARK: - FullScreenContentDelegate
    
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
      print("\(#function) called")
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("\(#function) called with error: \(error.localizedDescription)")
      // Clear the interstitial ad.
        gaInterstital = nil
        self.loadMediation()
    }

    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("\(#function) called")
        // Clear the interstitial ad.
        gaInterstital = nil
    }
    
    
    // MARK: - FBInterstitialAdDelegate
    
    func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        if interstitialAd.isAdValid {
            interstitialAd.show(fromRootViewController: self)
        }
    }
    
    func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: any Error) {
        self.loadMediation()
    }
    
    
    // MARK: - IAUnitDelegate
    
    func iaParentViewController(for unitController: IAUnitController?) -> UIViewController {
        return self
    }
    
    
    // MARK: - PAGLInterstitialAdDelegate
    
    func adDidShow(_ ad: any PAGAdProtocol) {
        
    }
    
    func adDidDismiss(_ ad: any PAGAdProtocol) {
        
    }
    
    func adDidShowFail(_ ad: any PAGAdProtocol, error: any Error) {
        self.loadMediation()
    }
    
    
    // MARK: - TnkAdListener
    func onLoad(_ adItem: any TnkAdItem) {
        if adItem.isLoaded() {
            adItem.show()
        }
    }
    
    func onError(_ adItem: any TnkAdItem, error: AdError) {
        self.loadMediation()
    }

    
    // MARK: - MAAdDelegate
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
