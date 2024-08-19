//
//  EBMediationBannerViewController.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by Jaeuk Jeong on 2023/09/05.
//

import Foundation
import UIKit
import AppTrackingTransparency
import ExelBidSDK

// AdMob
import GoogleMobileAds

// Facebook
import FBAudienceNetwork

// Adfit
import AdFitSDK

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

class EBMediationBannerViewController : UIViewController {
    
    @IBOutlet var adViewContainer: UIView!
    @IBOutlet var keywordsTextField: UITextField!
    @IBOutlet var loadAdButton: UIButton!
    @IBOutlet var showAdButton: UIButton!
    
    var info: EBAdInfoModel?
    var mediationManager: EBMediationManager?
    var ebAdView: EBAdView?
    var mpAdView: EBAdView?
    
    // AdMob
    var gaBannerView: GADBannerView?
    
    // Facebook
    var fanAdview: FBAdView?
    
    // AdFit
    var afBannerview: AdFitBannerAdView?
    
    // Digital Turbine
    var dtAdSpot: IAAdSpot?
    var dtUnitController: IAViewUnitController?
    
    // Pangle
    var pagBannerAd: PAGBannerAd?
    
    // Applovin
    var alBannerAd: MAAdView!
    
    // TargetPick
    let tpPublisherId: Int? = 1761
    let tpMediaId: Int? = 33372
    
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
            EBMediationTypes.applovin,
            EBMediationTypes.targetpick,
            EBMediationTypes.mpartners
        ]
        mediationManager = EBMediationManager(adUnitId: unitId, mediationTypes: mediationTypes)
        
        if let mediationManager = mediationManager {
            self.showAdButton.isHidden = false
            
            mediationManager.requestMediation { (manager, error) in
                if error != nil {
                    // 미디에이션 에러 처리
                } else {
                    // 성공 처리
                }
            }
        }
    }

    @IBAction func didTapShowButton(_ sender: UIButton) {
        self.loadMediation()
    }
    
    // adViewController 내 추가된 서브 뷰 제거
    func clearAd() {
        self.adViewContainer.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
    }
}

extension EBMediationBannerViewController {
    
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
            case EBMediationTypes.adfit:
                self.loadAdFit(mediation: mediation)
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
            case EBMediationTypes.mpartners:
                self.loadMPartners(mediation: mediation)
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
        self.clearAd()
        
        self.ebAdView = EBAdView(adUnitId: mediation.unit_id, size: self.adViewContainer.bounds.size)
        
        if let adView = self.ebAdView {
            adView.delegate = self
            adView.fullWebView = true
            
            // 광고의 효율을 높이기 위해 옵션 설정
            adView.yob = "1987"
            adView.gender = "M"
//            adView.testing = true
            
            self.adViewContainer.addSubview(adView)
            setAutoLayout(view: adViewContainer, adView: adView)
            adView.loadAd()
        }
    }
    
    // AdMob 광고 호출
    func loadAdMob(mediation: EBMediationWrapper) {
        self.clearAd()
        
        let viewWidth = self.adViewContainer.frame.inset(by: self.adViewContainer.safeAreaInsets).width
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        
        self.gaBannerView = GADBannerView(adSize: adaptiveSize)
        
        if let bannerView = self.gaBannerView {
            bannerView.delegate = self
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            bannerView.adUnitID = mediation.unit_id
            bannerView.rootViewController = self
            
            bannerView.load(GADRequest.init())
        }
    }
    
    // Fan 광고 호출
    func loadFan(mediation: EBMediationWrapper) {
        self.clearAd()
        
        self.fanAdview = FBAdView(placementID: mediation.unit_id, adSize: kFBAdSizeHeight50Banner, rootViewController: self)
        
        if let adView = self.fanAdview {
            adView.frame = CGRectMake(0, 0, 320, 250)
            adView.delegate = self
            adView.loadAd()
        }
    }
    
    // AdFit 광고 호출
    func loadAdFit(mediation: EBMediationWrapper) {
        self.clearAd()

        self.afBannerview = AdFitBannerAdView(clientId: mediation.unit_id, adUnitSize: "320x50")
        
        if let bannerView = self.afBannerview {
            bannerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 50)
            bannerView.rootViewController = self
            self.adViewContainer.addSubview(bannerView)
            bannerView.loadAd()
        }
    }
    
    // Digital Turbine 광고 호출
    func loadDT(mediation: EBMediationWrapper) {
        self.clearAd()
        
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
        
        self.dtUnitController = IAViewUnitController.build() { builder in
            builder.unitDelegate = self
        }
        
        if let adRequest = adRequest, let unitController = self.dtUnitController {
            self.dtAdSpot = IAAdSpot.build() { builder in
                builder.adRequest = adRequest
                builder.addSupportedUnitController(unitController)
            }
        }
        
        self.dtAdSpot?.fetchAd() { (adSpot, adModel, error) in
            if let error = error {
                print("Failed to get an ad: \(error.localizedDescription)")
            } else {
                if adSpot?.activeUnitController == self.dtUnitController {
                    self.dtUnitController?.showAd(inParentView: self.view)
                }
            }
        }
    }
    
    // Pangle 광고 호출
    func loadPangle(mediation: EBMediationWrapper) {
        self.clearAd()
        
        let size = kPAGBannerSize320x50
        PAGBannerAd.load(withSlotID: mediation.unit_id, request: PAGBannerRequest.init(bannerSize: size)) { (bannerAd, error) in
            if let error = error {
                self.loadMediation()
            } else {
                self.pagBannerAd = bannerAd
                self.pagBannerAd?.delegate = self
                self.pagBannerAd?.rootViewController = self
                
                if let bannerView = self.pagBannerAd?.bannerView {
                    bannerView.frame = CGRectMake((self.adViewContainer.frame.size.width-size.size.width)/2.0, self.adViewContainer.frame.size.height-size.size.height, size.size.width, size.size.height)
                    self.adViewContainer.addSubview(bannerView)
                }
            }
        }
    }
    
    // TNK 광고 호출
    func loadTnk(mediation: EBMediationWrapper) {
        self.clearAd()
        
        let adView = TnkBannerAdView(placementId: mediation.unit_id, adListener: self)
        adView.frame = CGRect(x: 0, y: 0, width: 320, height: 50)
        adView.setContainerView(self.adViewContainer)
        adView.load()
    }
    
    // AppLovin 광고 호출
    func loadApplovin(mediation: EBMediationWrapper) {
        self.clearAd()
        
        self.alBannerAd = MAAdView(adUnitIdentifier: mediation.unit_id)
        self.alBannerAd.delegate = self
    
        // Banner height on iPhone and iPad is 50 and 90, respectively
//        let height: CGFloat = (UIDevice.current.userInterfaceIdiom == .pad) ? 90 : 50
    
        // Stretch to the width of the screen for banners to be fully functional
//        let width: CGFloat = UIScreen.main.bounds.width
//        alBannerAd.frame = CGRect(x: 0, y: 0, width: width, height: height)
            
        self.alBannerAd.frame = self.adViewContainer.frame
    
        self.adViewContainer.addSubview(self.alBannerAd)
    
        // Load the first ad
        self.alBannerAd.loadAd()
    }
    
    // TargetPick 광고 호출
    func loadTargetPick(mediation: EBMediationWrapper) {
        self.clearAd()
        
        // withSectionID 데이터형을 맞추기 위해 unit_id를 정수로 변환
        if let section_id = Int(mediation.unit_id),
           let pub_id = self.tpPublisherId,
           let media_id = self.tpMediaId {

            let model = ADMZBannerModel(withPublisherID: pub_id,
                                        withMediaID: media_id,
                                        withSectionID: section_id,
                                        withBannerSize: .init(width: 320.0, height: 50.0),
                                        withKeywordParameter: "",
                                        withOtherParameter: "",
                                        withMediaAgeLevel: .over13Age,
                                        withAppID:Bundle.main.bundleIdentifier,
                                        withAppName: "ExelbidDemo(iOS)",
                                        withStoreURL: "StoreURL",
                                        withSMS: true,
                                        withTel: true,
                                        withCalendar: true,
                                        withStorePicture: true,
                                        withInlineVideo: true,
                                        withBannerType:.Strip)
            model.setUserInfo(withGenderType: .Male,
                              withAge: 15,
                              withUserID: "mezzomedia",
                              withEmail: "mezzo@mezzomedia.co.kr",
                              withUserLocationAgree: false)
            
            let bannerAd = ADMZBannerView()
            bannerAd.updateModel(value: model)
            
            // 필요에따라 이벤트 핸들러 구분
            let handler: ADMZEventHandler = { code in
                print(">>> \(code) - \(code.rawValue)")
            }
            
            bannerAd.setFailHandler(value: handler)
            bannerAd.setSuccessHandler(value: handler)
            bannerAd.setOtherHandler(value: handler)
            bannerAd.setAPIResponseHandler(value: { dic in
                print("API DATA = \(String.init(describing: dic))")
            })
            
            self.adViewContainer.addSubview(bannerAd)
            setAutoLayout(view: self.adViewContainer, adView: bannerAd)
            
            bannerAd.startBanner()
        } else {
            // 예외 처리
            
            // 다음 미디에이션 호출
            self.loadMediation()
        }
    }
    
    func loadMPartners(mediation: EBMediationWrapper) {
        self.clearAd()
        
        self.mpAdView = MPartnersAdView(adUnitId: mediation.unit_id, size: self.adViewContainer.bounds.size)
        
        if let adView = self.mpAdView {
            adView.delegate = self
            adView.fullWebView = true
            
            // 광고의 효율을 높이기 위해 옵션 설정
            adView.yob = "1987"
            adView.gender = "M"
//            adView.testing = true
            
            self.adViewContainer.addSubview(adView)
            setAutoLayout(view: adViewContainer, adView: adView)
            adView.loadAd()
        }
    }

}

// MARK: - 광고 뷰 Delegate
extension EBMediationBannerViewController : EBAdViewDelegate, GADBannerViewDelegate, FBAdViewDelegate, AdFitBannerAdViewDelegate, IAUnitDelegate, PAGBannerAdDelegate, TnkAdListener, MAAdViewAdDelegate {
    
    // MARK: EBAdViewDelegate
    
    func adViewDidLoadAd(_ view: EBAdView?) {
        
    }
    
    func adViewDidFailToLoadAd(_ view: EBAdView?) {
        self.loadMediation()
    }
    
    
    // MARK: - GADBannerViewDelegate
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.adViewContainer.addSubview(bannerView)
        self.adViewContainer.addConstraints([
            NSLayoutConstraint(
                item: bannerView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self.adViewContainer.safeAreaLayoutGuide,
                attribute: .bottom,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: bannerView,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: self.adViewContainer,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            )
        ])
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: any Error) {
        self.loadMediation()
    }
    
    
    // MARK: - FBAdViewDelegate
    
    func adViewDidLoad(_ adView: FBAdView) {
        
        if let adView = self.fanAdview, adView.isAdValid {
            self.adViewContainer.addSubview(adView)
        }
    }
    
    func adViewDidClick(_ adView: FBAdView) {
        
    }
    
    func adView(_ adView: FBAdView, didFailWithError error: any Error) {
        self.loadMediation()
    }
    
    
    // MARK: - AdFitBannerAdViewDelegate
    
    func adViewDidFailToReceiveAd(_ bannerAdView: AdFitBannerAdView, error: Error) {
        self.loadMediation()
    }
    
    
    // MARK: - IAUnitDelegate
    
    func iaParentViewController(for unitController: IAUnitController?) -> UIViewController {
        return self
    }
    
    
    // MARK: - TnkAdListener
    
    func onLoad(_ adItem: any TnkAdItem) {
        adItem.show()
    }
    
    func onError(_ adItem: any TnkAdItem, error: AdError) {
        self.loadMediation()
    }
    
    
    // MARK: - MAAdViewAdDelegate
    
    func didLoad(_ ad: MAAd) {
        
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        
    }
    
    func didExpand(_ ad: MAAd) {
        
    }
    
    func didCollapse(_ ad: MAAd) {
        
    }
    
    func didDisplay(_ ad: MAAd) {
        
    }
    
    func didHide(_ ad: MAAd) {
        
    }
    
    func didClick(_ ad: MAAd) {
        
    }
}
