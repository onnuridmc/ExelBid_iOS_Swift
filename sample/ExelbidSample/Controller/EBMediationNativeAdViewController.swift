//
//  EBMediationNativeadViewController.swift
//  com.zionbi.ExelbidSample-Swift
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

// Facebook
import FBAudienceNetwork

// Adfit
import AdFitSDK

// Pangle
import PAGAdSDK

// TNK
import TnkPubSdk

// Applovin
import AppLovinSDK

class EBMediationNativeAdViewController : UIViewController, EBNativeAdDelegate, GADNativeAdLoaderDelegate, GADNativeAdDelegate, FBNativeAdDelegate, AdFitNativeAdLoaderDelegate, AdFitNativeAdDelegate, PAGLNativeAdDelegate, TnkAdListener, MANativeAdDelegate {

    @IBOutlet var adViewContainer: UIView!
    @IBOutlet var keywordsTextField: UITextField!
    @IBOutlet var loadAdButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    
    var info: EBAdInfoModel?
    var mediationManager: EBMediationManager?
    var ebNativeAd: EBNativeAd?
    var mpNativeAd: EBNativeAd?
    
    // AdMob
    var gaAdLoad: GADAdLoader?
    var gaNativeAdView: GADNativeAdView?
    
    // Facebook
    var fanNativeAd: FBNativeAd?
    
    // AdFit
    var afLoader: AdFitNativeAdLoader?
    
    // Pangle
    var pagNativeAd: PAGLNativeAd?
    
    // Applovin
    var alNativeAdLoader: MANativeAdLoader?
    var alNativeAd: MAAd?
    var alNativeAdView: MANativeAdView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nextButton.isHidden = true
        self.keywordsTextField.text = self.info?.ID
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // TNK - 명시적으로 detach 해야함
        TnkNativeAdItem.detach(self.adViewContainer)
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
            EBMediationTypes.mpartners
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

extension EBMediationNativeAdViewController {
    func loadMediation() {
        guard let mediationManager = mediationManager else {
            return
        }
        
        // 미디에이션 목록을 순차적으로 가져옴
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
            case EBMediationTypes.pangle:
                self.loadPangle(mediation: mediation)
            case EBMediationTypes.tnk:
                self.loadTnk(mediation: mediation)
            case EBMediationTypes.applovin:
                self.loadApplovin(mediation: mediation)
            case EBMediationTypes.mpartners:
                self.loadExelBid(mediation: mediation)
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
        let ebNativeManager = ExelBidNativeManager(mediation.unit_id, EBNativeAdView.self)
        
        // 광고의 효율을 높이기 위해 옵션 설정
        ebNativeManager.yob("1987")
        ebNativeManager.gender("M")
//        ExelBidNativeManager.testing(true)
        
        // 네이티브 광고 요청시 어플리케이션에서 필수로 요청할 항목들을 설정합니다.
        ebNativeManager.desiredAssets([EBNativeAsset.kAdIconImageKey,
                                       EBNativeAsset.kAdMainImageKey,
                                       EBNativeAsset.kAdCTATextKey,
                                       EBNativeAsset.kAdTextKey,
                                       EBNativeAsset.kAdTitleKey])

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
    
    func loadAdMob(mediation: EBMediationWrapper) {
        self.clearAd()
        
        self.gaAdLoad = GADAdLoader.init(adUnitID: mediation.unit_id, rootViewController: self, adTypes: [.native], options: nil)
        self.gaAdLoad?.delegate = self
        self.gaAdLoad?.load(GADRequest.init())
    }
    
    func loadFan(mediation: EBMediationWrapper) {
        self.clearAd()
        
        self.fanNativeAd = FBNativeAd.init(placementID: mediation.unit_id)
        self.fanNativeAd?.delegate = self
        self.fanNativeAd?.loadAd()
    }
    
    func loadAdFit(mediation: EBMediationWrapper) {
        self.clearAd()

        self.afLoader = AdFitNativeAdLoader(clientId: mediation.unit_id, count: 1)
        self.afLoader?.delegate = self
        self.afLoader?.loadAd()
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
    
    func loadTnk(mediation: EBMediationWrapper) {
        self.clearAd()
        
        let adItem = TnkNativeAdItem(placementId:mediation.unit_id, adListener: self)
        adItem.load()
    }
    
    func loadApplovin(mediation: EBMediationWrapper) {
        self.clearAd()
        
        self.alNativeAdLoader = MANativeAdLoader(adUnitIdentifier: "YOUR_AD_UNIT_ID")
        self.alNativeAdLoader?.nativeAdDelegate = self
        
        // call to template native ad
//        self.alNativeAdLoader.loadAd()
        
        // create custom native ad view
        createApplovinNativeAdview()
        
        // call to custom native ad
        self.alNativeAdLoader?.loadAd(into: self.alNativeAdView)

    }
    
    func loadMPartners(mediation: EBMediationWrapper) {
        let mpNativeManager = MPartnersNativeManager(mediation.unit_id, EBNativeAdView.self)
        
        // 광고의 효율을 높이기 위해 옵션 설정
        mpNativeManager.yob("1987")
        mpNativeManager.gender("M")
//        ExelBidNativeManager.testing(true)
        
        // 네이티브 광고 요청시 어플리케이션에서 필수로 요청할 항목들을 설정합니다.
        mpNativeManager.desiredAssets([EBNativeAsset.kAdIconImageKey,
                                       EBNativeAsset.kAdMainImageKey,
                                       EBNativeAsset.kAdCTATextKey,
                                       EBNativeAsset.kAdTextKey,
                                       EBNativeAsset.kAdTitleKey])

        mpNativeManager.startWithCompletionHandler { (request, response, error) in
            if error != nil {
                // 광고가 없거나 요청 실패시 다음 미디에이션 처리를 위해 호출
                self.loadMediation()
            }else{
                self.clearAd()
                
                self.mpNativeAd = response
                self.mpNativeAd?.delegate = self
                
                if let adView = self.mpNativeAd?.retrieveAdViewWithError(nil) {
                    self.adViewContainer.addSubview(adView)
                    self.setAutoLayout2(view: self.adViewContainer, adView: adView)
                }
            }
        }
    }
    
    func createApplovinNativeAdview() {
        let nativeAdViewNib = UINib(nibName: "EBApplovinNativeAdView", bundle: Bundle.main)
        let nativeAdView = nativeAdViewNib.instantiate(withOwner: nil, options: nil).first! as! MANativeAdView?

        let adViewBinder = MANativeAdViewBinder.init(builderBlock: { (builder) in
            builder.titleLabelTag = 1001
            builder.bodyLabelTag = 1003
            builder.callToActionButtonTag = 1007
            builder.iconImageViewTag = 1004
            builder.mediaContentViewTag = 1006
            builder.starRatingContentViewTag = 1008
            builder.advertiserLabelTag = 1002
            builder.optionsContentViewTag = 1005
        })
        nativeAdView?.bindViews(with: adViewBinder)
        self.alNativeAdView = nativeAdView
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
    
    
    // MARK: FBNativeAdDelegate
    
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        if nativeAd.isAdValid {
            nativeAd.unregisterView()
        }
        
        self.fanNativeAd = nativeAd
        var nativeAdView = EBFanNativeAdView.init(frame: CGRectMake(0, 0, 300, 200))
        
        self.adViewContainer.addSubview(nativeAdView)
        
        nativeAd.registerView(
            forInteraction: nativeAdView.adView,
            mediaView: nativeAdView.adCoverMediaView,
            iconView: nativeAdView.adIconImageView,
            viewController: self,
            clickableViews: [nativeAdView.adCallToActionButton, nativeAdView.adCoverMediaView]
        )
    }
    
    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: any Error) {
        self.loadMediation()
    }
    
    
    // MARK: AdFitNativeAdLoaderDelegate
    
    func nativeAdLoaderDidReceiveAds(_ nativeAds: [AdFitNativeAd]) {
        print("Adfit - nativeAdLoaderDidReceiveAds")
    }

    func nativeAdLoaderDidReceiveAd(_ nativeAd: AdFitNativeAd) {
        let nativeAdView = EBAdFitNativeAdView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
        nativeAd.bind(nativeAdView)
        self.adViewContainer.addSubview(nativeAdView)
    }

    func nativeAdLoaderDidFailToReceiveAd(_ nativeAdLoader: AdFitNativeAdLoader, error: Error) {
        print("Adfit - nativeAdLoaderDidFailToReceiveAd - error : \(error.localizedDescription)")
    }
    
    
    // MARK: AdFitNativeAdDelegate
    
    func nativeAdDidClickAd(_ nativeAd: AdFitNativeAd) {
        print("Adfit - nativeAdDidClickAd")
    }
    
    
    // MARK: PAGLNativeAdDelegate
    
    func adDidShow(_ ad: any PAGAdProtocol) {
        
    }
    
    func adDidClick(_ ad: any PAGAdProtocol) {
        
    }
    
    func adDidDismiss(_ ad: any PAGAdProtocol) {
        
    }
    
    
    // MARK: TnkAdListener
    func onLoad(_ adItem: any TnkAdItem) {
        if let nativeAdItem = adItem as? TnkNativeAdItem {
            
            let adView = EBTnkNativeAdView()
            adView.nativeImageView.image = nativeAdItem.getMainImage()
            adView.nativeIconView.image = nativeAdItem.getIconImage()
            adView.nativeTitleLabel.text = nativeAdItem.getTitle()
            adView.nativeDescLabel.text = nativeAdItem.getDescription()
            
            self.adViewContainer.addSubview(adView)
            
            nativeAdItem.attach(self.adViewContainer, clickView:adView.nativeImageView)
        }
    }
    
    func onError(_ adItem: any TnkAdItem, error: AdError) {
        self.loadMediation()
    }
    
    
    // MARK: MANativeAdDelegate
    
    func didLoadNativeAd(_ nativeAdView: MANativeAdView?, for ad: MAAd) {
        // 기존 네이티브 광고 제거
        if let oldNativeAd = self.alNativeAd {
            alNativeAdLoader?.destroy(oldNativeAd)
        }
        
        self.alNativeAd = ad
        
        if let oldNAtiveAdView = self.alNativeAdView {
            oldNAtiveAdView.removeFromSuperview()
        }
        
        self.alNativeAdView = nativeAdView
        if let nativeAdView = nativeAdView {
            self.adViewContainer.addSubview(nativeAdView)
            
            // 네이티브 광고 뷰 레이아웃 설정
            nativeAdView.translatesAutoresizingMaskIntoConstraints = false
            
            // 네이티브 광고 사이즈와 센터 정렬
            NSLayoutConstraint.activate([
                nativeAdView.widthAnchor.constraint(equalTo: self.adViewContainer.widthAnchor),
                nativeAdView.heightAnchor.constraint(equalTo: self.adViewContainer.heightAnchor),
                nativeAdView.centerXAnchor.constraint(equalTo: self.adViewContainer.centerXAnchor),
                nativeAdView.centerYAnchor.constraint(equalTo: self.adViewContainer.centerYAnchor)
            ])
        }
    }
    
    func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        
    }
    
    func didClickNativeAd(_ ad: MAAd) {
        
    }
}



