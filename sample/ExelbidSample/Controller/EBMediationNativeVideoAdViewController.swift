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

// TargetPick
import LibADPlus


class EBMediationNativeVideoAdViewController : UIViewController {

    @IBOutlet var adViewContainer: UIView!
    @IBOutlet var keywordsTextField: UITextField!
    @IBOutlet var loadAdButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    
    var info: EBAdInfoModel?
    var mediationManager: EBMediationManager?
    var ebNativeAd: EBNativeAd?
    
    // AdMob
    var gaAdLoad: AdLoader?
    var gaNativeAdView: NativeAdView?
    
    // Pangle
    var pagNativeAd: PAGLNativeAd?
    
    // TargetPick
    let tpPublisherId: Int? = 1761
    let tpMediaId: Int? = 33372
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.keywordsTextField.text = self.info?.ID
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @IBAction func didTapLoadButton(_ sender: UIButton) {
        guard let identifier = keywordsTextField.text else {
            return
        }
        
        self.keywordsTextField.endEditing(true)

        let mediationTypes = [
            EBMediationTypes.exelbid,
            EBMediationTypes.admob,
            EBMediationTypes.pangle,
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
    
    // adViewController 내 추가된 서브 뷰 제거
    func clearAd() {
        self.adViewContainer.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
    }
}

extension EBMediationNativeVideoAdViewController {
    
    // 미디에이션 목록 순차 처리
    func loadMediation() {
        guard let mediationManager = mediationManager else {
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
            case EBMediationTypes.pangle:
                self.loadPangle(mediation: mediation)
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
        let ebNativeManager = ExelBidNativeManager(mediation.unit_id, EBNativeAdView.self)
        
        // 광고의 효율을 높이기 위해 옵션 설정
        ebNativeManager.yob("1987")
        ebNativeManager.gender("M")
//        ebNativeManager.testing(true)
        
        // 
        ebNativeManager.desiredAssets([EBNativeAsset.kAdTitleKey,
                                       EBNativeAsset.kAdTextKey,
                                       EBNativeAsset.kAdIconImageKey,
                                       EBNativeAsset.kAdVideo,
                                       EBNativeAsset.kAdCTATextKey])

        ebNativeManager.startWithCompletionHandler { (request, response, error) in
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
    
    // AdMob 광고 호출
    func loadAdMob(mediation: EBMediationWrapper) {
        self.clearAd()
        
        let videoOptions = VideoOptions()
        videoOptions.areCustomControlsRequested = true
        
        self.gaAdLoad = AdLoader(adUnitID: mediation.unit_id, rootViewController: self, adTypes: [.native], options: [videoOptions])
        self.gaAdLoad?.delegate = self
        self.gaAdLoad?.load(Request.init())
    }
    
    // Pangle 광고 호출
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
    
    // TargetPick 광고 호출
    func loadTargetPick(mediation: EBMediationWrapper) {
        self.clearAd()
        
        // withSectionID 데이터형을 맞추기 위해 unit_id를 정수로 변환
        if let section_id = Int(mediation.unit_id),
           let pub_id = self.tpPublisherId,
           let media_id = self.tpMediaId {
            
            let model = ADMZVideoModel(withPublisherID:pub_id,
                                       withMediaID: media_id,
                                       withSectionID: section_id,
                                       withVideoSize: .init(width: 320, height: 480),
                                       withKeywordParameter: "KeywordTargeting",
                                       withOtherParameter: "BannerAdditionalParameters",
                                       withMediaAgeLevel: .unknownType,
                                       withAppID: "appID",
                                       withAppName: "appName",
                                       withStoreURL: "StoreURL",
                                       withSMS: true,
                                       withTel: true,
                                       withCalendar: true,
                                       withStorePicture: true,
                                       withAutoPlay: true,
                                       withAutoReplay: true,
                                       withMuteOption: true,
                                       withClickFull: true,
                                       withClickButtonShow: true,
                                       withSkipButtonShow: true,
                                       withClickVideoArea: true,
                                       withCloseButtonShow: true,
                                       withSoundButtonShow: true,
                                       withInlineVideo: true)
            model.setUserInfo(withGenderType: .Male,
                              withAge: 15,
                              withUserID: "mezzomedia",
                              withEmail: "mezzo@mezzomedia.co.kr",
                              withUserLocationAgree: false)
            
            
            let videoAd = ADMZVideoView()
            videoAd.updateModel(value: model)
            
            // 필요에따라 이벤트 핸들러 구분
            let handler: ADMZEventHandler = { code in
                print(">>> \(code) - \(code.rawValue)")
            }
            
            videoAd.setFailHandler(value: handler)
            videoAd.setSuccessHandler(value: handler)
            videoAd.setOtherHandler(value: handler)
            videoAd.setAPIResponseHandler(value: { dic in
                print("API DATA = \(String.init(describing: dic))")
            })
            
            self.adViewContainer.addSubview(videoAd)
            setAutoLayout(view: self.adViewContainer, adView: videoAd)
            
            videoAd.startVideo()
        } else {
            // 예외 처리
            
            // 다음 미디에이션 호출
            self.loadMediation()
        }
    }
}
 
// MARK: - 광고 뷰 Delegate
extension EBMediationNativeVideoAdViewController : EBNativeAdDelegate, NativeAdLoaderDelegate, NativeAdDelegate, VideoControllerDelegate, PAGLNativeAdDelegate {
    
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
    
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        let nibView = Bundle.main.loadNibNamed("EBAdMobNativeAdView", owner: nil, options: nil)?.first
        guard let nativeAdView = nibView as? NativeAdView else {
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
    
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: any Error) {
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
    
    
    // MARK: - PAGLNativeAdDelegate
    
    func adDidShow(_ ad: any PAGAdProtocol) {
        
    }
    
    func adDidClick(_ ad: any PAGAdProtocol) {
        
    }
    
    func adDidDismiss(_ ad: any PAGAdProtocol) {
        
    }

}



