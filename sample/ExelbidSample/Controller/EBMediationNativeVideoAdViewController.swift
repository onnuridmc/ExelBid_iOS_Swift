//
//  EBMediationNativeVideoAdViewController.swift
//
//  Created by Jaeuk Jeong on 2023/08/08.
//

import Foundation
import Foundation
import UIKit
import AppTrackingTransparency
import ExelBidSDK

// AdMob
import GoogleMobileAds

// Pangle
import PAGAdSDK

class EBMediationNativeVideoAdViewController : UIViewController, EBNativeAdDelegate, GADNativeAdLoaderDelegate, GADNativeAdDelegate, GADVideoControllerDelegate, PAGLNativeAdDelegate {

    @IBOutlet var adViewContainer: UIView!
    @IBOutlet var keywordsTextField: UITextField!
    @IBOutlet var loadAdButton: UIButton!
    @IBOutlet var showAdButton: UIButton!
    
    var info: EBAdInfoModel?
    var mediationManager: EBMediationManager?
    var ebNativeAd: EBNativeAd?
    
    // AdMob
    var gaAdLoad: GADAdLoader?
    var gaNativeAdView: GADNativeAdView?
    
    // Pangle
    var pagNativeAd: PAGLNativeAd?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showAdButton.isHidden = true
        self.keywordsTextField.text = self.info?.ID
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
        ];
        mediationManager = EBMediationManager(adUnitId: unitId, mediationTypes: mediationTypes)
        
        if let mediationManager = mediationManager {
            self.showAdButton.isHidden = false
            
            mediationManager.requestMediation() { (manager, error) in
                if error != nil {
                    // ERROR - Request Mediation
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

extension EBMediationNativeVideoAdViewController {
    func loadMediation() {
        guard let mediationManager = mediationManager else {
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
    
    /**
     엑셀비드 광고 요청
     예시는 배너 광고이며 전면 광고는 EBFrontBannerAdViewController 참고
     */
    func loadExelBid(mediation: EBMediationWrapper) {
        ExelBidNativeManager.initNativeAdWithAdUnitIdentifier(mediation.unit_id, EBNativeAdView.self)
        ExelBidNativeManager.testing(true)
        ExelBidNativeManager.yob("1976")
        ExelBidNativeManager.gender("M")
        
        let allowedAdAssets = NSMutableSet(objects: EBNativeAsset.kAdTitleKey,
                                           EBNativeAsset.kAdTextKey,
                                           EBNativeAsset.kAdIconImageKey,
                                           EBNativeAsset.kAdVideo,
                                           EBNativeAsset.kAdCTATextKey)

        ExelBidNativeManager.desiredAssets(allowedAdAssets)
        ExelBidNativeManager.startWithCompletionHandler { (request, response, error) in
            if error != nil {
                // 광고가 없거나 요청 실패시 다음 미디에이션 처리를 위해 호출
                self.loadMediation()
            }else{
                self.clearAd()
                
                self.ebNativeAd = response
                self.ebNativeAd?.delegate = self
                
                if let adView = self.ebNativeAd?.retrieveAdViewWithError(nil) {
                    self.adViewContainer.addSubview(adView)
                    self.setAutoLayout2(view: self.adViewContainer, adView: adView)
                }
            }
        }
    }
    
    func loadAdMob(mediation: EBMediationWrapper) {
        self.clearAd()
        
        let videoOptions = GADVideoOptions()
        videoOptions.customControlsRequested = true

        self.gaAdLoad = GADAdLoader.init(adUnitID: mediation.unit_id, rootViewController: self, adTypes: [.native], options: [videoOptions])
        self.gaAdLoad?.delegate = self
        self.gaAdLoad?.load(GADRequest.init())
    }

    func loadPangle(mediation: EBMediationWrapper) {
        self.clearAd()
        
        PAGLNativeAd.load(withSlotID: mediation.unit_id, request: PAGNativeRequest.init()) { (nativeAd, error) in
            let nativeAdView = EBPangleNativeAdView(frame: self.adViewContainer.frame)
            self.adViewContainer.addSubview(nativeAdView)
            if let nativeAd = nativeAd {
                nativeAd.delegate = self
                nativeAdView.refreshWithNativeAd(nativeAd)
            }
            nativeAdView.layoutSubviews()
        }
    }
    
    // MARK: EBNativeAdDelegate
    
    func willLoadForNativeAd(_ nativeAd: EBNativeAd?) {
        
    }
    
    func didLoadForNativeAd(_ nativeAd: EBNativeAd?) {
        
    }
    
    func willLeaveApplicationFromNativeAd(_ nativeAd: EBNativeAd?) {
        
    }
    
    func viewControllerForPresentingModalView() -> UIViewController? {
        return self
    }
    
    
    // MARK: - GADNativeAdLoaderDelegate
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        let nibView = Bundle.main.loadNibNamed("EBAdMobNativeAdView", owner: nil, options: nil)?.first
        guard let nativeAdView = nibView as? GADNativeAdView else {
            print(">>>>> Not Found loadNibNamed(EBAdMobNativeAdView)")
            
            return
        }
        
        self.adViewContainer.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        
        let viewDictionary = ["_nativeAdView": nativeAdView]
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary
            )
        )
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary
            )
        )
        
        nativeAd.delegate = self
        nativeAd.mediaContent.videoController.delegate = self
        
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        
        if let mediaView = nativeAdView.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
            let heightConstraint = NSLayoutConstraint(
                item: mediaView,
                attribute: .height,
                relatedBy: .equal,
                toItem: mediaView,
                attribute: .width,
                multiplier: CGFloat(1 / nativeAd.mediaContent.aspectRatio),
                constant: 0)
            heightConstraint.isActive = true
        }
        
        
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil

        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil

        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil

        (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)
        nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil

        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        nativeAdView.storeView?.isHidden = nativeAd.store == nil

        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        nativeAdView.priceView?.isHidden = nativeAd.price == nil

        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
        
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        
        nativeAdView.nativeAd = nativeAd
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: any Error) {
        self.loadMediation()
    }
    
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
        guard let rating = starRating?.doubleValue else {
            return nil
        }
        
        if rating >= 5 {
            return UIImage(named: "stars_5")
        } else if rating >= 4.5 {
            return UIImage(named: "stars_4_5")
        } else if rating >= 4 {
            return UIImage(named: "stars_4")
        } else if rating >= 3.5 {
            return UIImage(named: "stars_3_5")
        } else {
            return nil
        }
    }
    
    
    // MARK: PAGLNativeAdDelegate
    
    func adDidShow(_ ad: any PAGAdProtocol) {
        
    }
    
    func adDidClick(_ ad: any PAGAdProtocol) {
        
    }
    
    func adDidDismiss(_ ad: any PAGAdProtocol) {
        
    }

}



