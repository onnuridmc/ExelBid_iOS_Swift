//
//  EBMediationBizBoardViewController.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by Jaeuk Jeong on 2023/08/14.
//

import Foundation
import UIKit
import AppTrackingTransparency
import ExelBidSDK
import AdFitSDK

class EBMediationBizBoardViewController : UIViewController {

    @IBOutlet var adViewContainer: UIView!
    @IBOutlet var keywordsTextField: UITextField!
    @IBOutlet var loadAdButton: UIButton!
    @IBOutlet var showAdButton: UIButton!
    
    var info: EBAdInfoModel?
    var mediationManager: EBMediationManager?
    var ebNativeAd: EBNativeAd?
    var afLoader: AdFitNativeAdLoader?
    var afBizboardTemplate: BizBoardTemplate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.showAdButton.isHidden = true
        self.keywordsTextField.text = self.info?.ID
        
        // 광고 요청하기 전에 사용자로 부터 개인정보 보호에 관한 권한을 요청해야 합니다.
        // (앱이 설치되고 한번만 호출하면 되며, 아래 코드는 사용자가 권한에 대한 응답 후에는 더 이상 사용자에게 권한을 묻지 않습니다.)
        if #available(iOS 14.0, *) {
            ATTrackingManager.requestTrackingAuthorization { _ in }
        }
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
                    // ERROR - Request Mediation
                } else {
                    self.loadMediation()
                }
            }
        }
    }
    
    @IBAction func didTapShowButton(_ sender: UIButton) {

    }
    
    // adViewController 내 추가된 서브 뷰 제거
    func clearAd() {
        self.adViewContainer.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
    }
}

extension EBMediationBizBoardViewController {
    
    func loadMediation() {
        guard let mediationManager = mediationManager else {
            return
        }
        
        // 미디에이션 목록을 순차적으로 가져옴
        if let mediation = mediationManager.next() {
            
            print(">>>>> Mediation ID : \(mediation.id)")
            
            switch mediation.id {
            case EBMediationTypes.exelbid:
                self.loadExelBid(mediation: mediation)
            case EBMediationTypes.adfit:
                self.loadAdFit(mediation: mediation)
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
    
    /**
     엑셀비드 광고 요청
     예시는 배너 광고이며 전면 광고는 EBFrontBannerAdViewController 참고
     */
    func loadExelBid(mediation: EBMediationWrapper) {
        ExelBidNativeManager.initNativeAdWithAdUnitIdentifier(mediation.unit_id, EBNativeAdView.self)
        ExelBidNativeManager.testing(true)
        ExelBidNativeManager.yob("1976")
        ExelBidNativeManager.gender("M")

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
    
    func loadAdFit(mediation: EBMediationWrapper) {
        self.clearAd()

        self.afBizboardTemplate = BizBoardTemplate(frame: CGRectZero)
        
        if let afBizboardTemplate = self.afBizboardTemplate {
            let viewWidth: Double = self.adViewContainer.frame.size.width; // 실제 뷰의 너비
            let leftRightMargin: Double = BizBoardTemplate.defaultEdgeInset.left + BizBoardTemplate.defaultEdgeInset.right; // 비즈보드 좌우 마진의 합
            let topBottomMargin: Double = BizBoardTemplate.defaultEdgeInset.top + BizBoardTemplate.defaultEdgeInset.bottom; // 비즈보드 상하 마진의 합
            
            // 여백을 커스텀하게 설정하였다면 아래 값을 적용
        //    double leftRightMargin = self.afBizboardTemplate.bgViewleftMargin + self.afBizboardTemplate.bgViewRightMargin;
        //    double topBottomMargin = self.afBizboardTemplate.bgViewTopMargin + self.afBizboardTemplate.bgViewBottomMargin;
            
            let bizBoardWidth: Double = viewWidth - leftRightMargin; // 뷰의 실제 너비에서 좌우 마진값을 빼주면 비즈보드 너비가 나온다.
            let bizBoardRatio: Double = 1029.0 / 222.0; // 비즈보드 이미지의 비율
            let bizBoardHeight: Double = bizBoardWidth / bizBoardRatio; // 비즈보드 너비에서 비율값을 나눠주면 비즈보드 높이를 계산 할 수 있다.
            let viewHeight: Double = bizBoardHeight + topBottomMargin; // 비즈보드 높이에서 상하 마진값을 더해주면 실제 그려줄 뷰의 높이를 알 수 있다.
            
            afBizboardTemplate.frame = CGRectMake(0, 0, viewWidth, viewHeight);
            
            self.adViewContainer.addSubview(afBizboardTemplate)

            self.afLoader = AdFitNativeAdLoader(clientId: mediation.unit_id, count: 1)
            self.afLoader?.delegate = self
            self.afLoader?.infoIconPosition = .topRight
            self.afLoader?.loadAd()
        }
    }

}

extension EBMediationBizBoardViewController : EBNativeAdDelegate {
    func willLoadForNativeAd(_ nativeAd: EBNativeAd?) {
        
    }
    
    func didLoadForNativeAd(_ nativeAd: EBNativeAd?) {
        
    }
    
    func willLeaveApplicationFromNativeAd(_ nativeAd: EBNativeAd?) {
        
    }
    
    func viewControllerForPresentingModalView() -> UIViewController? {
        return self
    }
}

extension EBMediationBizBoardViewController : AdFitNativeAdLoaderDelegate {
    func nativeAdLoaderDidReceiveAds(_ nativeAds: [AdFitNativeAd]) {
        print("Adfit - nativeAdLoaderDidReceiveAds")
    }

    func nativeAdLoaderDidReceiveAd(_ nativeAd: AdFitNativeAd) {
        if let afBizboardTemplate = self.afBizboardTemplate {
            //인포아이콘 조정은 바인드 전에 이뤄줘야 한다.
            nativeAd.infoIconRightConstant = -20; //인포아이콘을 우에서 좌로 20
            nativeAd.infoIconTopConstant = 5; //인포아이콘을 위에서 아래로 5만큼 이동

            nativeAd.bind(afBizboardTemplate)
            nativeAd.delegate = self;
        } else {
            // Empty - BizboardTemplate
        }
    }

    func nativeAdLoaderDidFailToReceiveAd(_ nativeAdLoader: AdFitNativeAdLoader, error: Error) {
        print("Adfit - nativeAdLoaderDidFailToReceiveAd - error : \(error.localizedDescription)")
    }
}

extension EBMediationBizBoardViewController : AdFitNativeAdDelegate {
    func nativeAdDidClickAd(_ nativeAd: AdFitNativeAd) {
        print("Adfit - nativeAdDidClickAd")
    }
}
