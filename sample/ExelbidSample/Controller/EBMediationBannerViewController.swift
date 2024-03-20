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

class EBMediationBannerViewController : UIViewController {
    
    @IBOutlet var adViewContainer: UIView!
    @IBOutlet var keywordsTextField: UITextField!
    @IBOutlet var loadAdButton: UIButton!
    @IBOutlet var showAdButton: UIButton!
    
    var info: EBAdInfoModel?
    var mediationManager: EBMediationManager?
    var ebAdView: EBAdView?
    
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
        
        GADAdLoaderAdType.native
        
        mediationManager = EBMediationManager(adUnitId: unitId, mediationTypes: [EBMediationTypes.exelbid, EBMediationTypes.admob, EBMediationTypes.pangle])
        
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

extension EBMediationBannerViewController {
    
    // adViewController 내 추가된 서브 뷰 제거
    func clearAd() {
        self.adViewContainer.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
    }
    
    func loadMediation() {
        guard let mediationManager = mediationManager else {
            self.emptyMediation()
            return
        }
        
        // 미디에이션 목록을 순차적으로 가져옴
        if let mediation = mediationManager.next() {
            
            print(">>>>> Mediation ID : \(mediation.id)")
            
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
        self.clearAd();
        
        self.ebAdView = EBAdView(adUnitId: mediation.unit_id, size: self.adViewContainer.bounds.size)
        
        if let adView = self.ebAdView {
            adView.delegate = self
            adView.yob = "1976"
            adView.gender = "M"
            adView.fullWebView = true
            adView.testing = true
            
            self.adViewContainer.addSubview(adView)
            setAutoLayout(view: adViewContainer, adView: adView)
            adView.loadAd()
        }
    }
    
    func loadAdMob(mediation: EBMediationWrapper) {
        self.clearAd();
        
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
    
    func loadFan(mediation: EBMediationWrapper) {
        self.clearAd();
        
        self.fanAdview = FBAdView(placementID: mediation.unit_id, adSize: kFBAdSizeHeight50Banner, rootViewController: self)
        
        if let adView = self.fanAdview {
            adView.frame = CGRectMake(0, 0, 320, 250)
            adView.delegate = self
            adView.loadAd()
        }
    }
    
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
    
    func loadDT(mediation: EBMediationWrapper) {
        self.clearAd();
        
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
    
    func loadPangle(mediation: EBMediationWrapper) {
        self.clearAd();
        
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
}

extension EBMediationBannerViewController : EBAdViewDelegate {
    func adViewDidLoadAd(_ view: EBAdView?) {
        
    }
    
    func adViewDidFailToLoadAd(_ view: EBAdView?) {
        self.loadMediation()
    }
}

extension EBMediationBannerViewController : GADBannerViewDelegate {
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
}

extension EBMediationBannerViewController : FBAdViewDelegate {
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
}

extension EBMediationBannerViewController : AdFitBannerAdViewDelegate {
    func adViewDidFailToReceiveAd(_ bannerAdView: AdFitBannerAdView, error: Error) {
        self.loadMediation()
    }
}

extension EBMediationBannerViewController : IAUnitDelegate {
    func iaParentViewController(for unitController: IAUnitController?) -> UIViewController {
        return self
    }
}

extension EBMediationBannerViewController : PAGBannerAdDelegate {
}

