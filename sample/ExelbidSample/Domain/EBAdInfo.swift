//
//  EBAdInfo.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/01/20.
//

import Foundation

struct EBAdInfo {
    static var shared = EBAdInfo()
    
    func mpartnersAds() -> [EBAdInfoModel] {
        return [
            EBAdInfoModel(title: "MPartners Offerwall", ID: "", type: .MPartnersOfferwall),
            EBAdInfoModel(title: "MPartners 배너광고", ID: "exelbiddev", type: .MPartnersBanner),
            EBAdInfoModel(title: "MPartners 네이티브", ID: "exelbiddev", type: .MPartnersNative)
        ]
    }

    func bannerAds() -> [EBAdInfoModel] {
        return [
            EBAdInfoModel(title: "배너광고", ID: "08377f76c8b3e46c4ed36c82e434da2b394a4dfa", type: .Banner),
            EBAdInfoModel(title: "전면광고", ID: "615217b82a648b795040baee8bc81986a71d0eb7", type: .Interstitial),
            EBAdInfoModel(title: "다이얼로그광고", ID: "615217b82a648b795040baee8bc81986a71d0eb7,5792d262715cbd399d6910200437b40a95dcc0f6", type: .DailBanner),
            EBAdInfoModel(title: "애드태그", ID: "", type: .AdTag),
        ]
    }
    
    func nativeAds() -> [EBAdInfoModel] {
        return [
            EBAdInfoModel(title: "네이티브", ID: "5792d262715cbd399d6910200437b40a95dcc0f6", type: .Native),
            EBAdInfoModel(title: "네이티브 Banner", ID: "5792d262715cbd399d6910200437b40a95dcc0f6", type: .NativeBanner),
            EBAdInfoModel(title: "네이티브 Ad (CollectionView)", ID: "5792d262715cbd399d6910200437b40a95dcc0f6", type: .NativeInCollectionView),
            EBAdInfoModel(title: "네이티브 Ad (TableView)", ID: "5792d262715cbd399d6910200437b40a95dcc0f6", type: .NativeTableViewPlacer)
        ]
    }
    
    func videoAds() -> [EBAdInfoModel] {
        return [
            EBAdInfoModel(title: "비디오 전면", ID: "3f548c41c3c6539ee7051aeb58ada2d4c039bc07", type: .Video),
            EBAdInfoModel(title: "비디오 네이티브", ID: "ac6c351af0850502d7174a4e80aea169cf9c1823", type: .NativeVideo)
        ]
    }
    
    func etcAds() -> [EBAdInfoModel] {
        
        return [
            EBAdInfoModel(title: "미디에이션 Banner", ID: "08377f76c8b3e46c4ed36c82e434da2b394a4dfa", type: .MediationBanner),
            EBAdInfoModel(title: "미디에이션 Interstitial", ID: "615217b82a648b795040baee8bc81986a71d0eb7", type: .MediationInterstitial),
            EBAdInfoModel(title: "미디에이션 Interstitial Video", ID: "3f548c41c3c6539ee7051aeb58ada2d4c039bc07", type: .MediationInterstitialVideo),
            EBAdInfoModel(title: "미디에이션 Native", ID: "5792d262715cbd399d6910200437b40a95dcc0f6", type: .MediationNative),
            EBAdInfoModel(title: "미디에이션 Native Video", ID: "ac6c351af0850502d7174a4e80aea169cf9c1823", type: .MediationNativeVideo),
            //            EBAdInfoModel(title: "미디에이션 BizboardView", ID: "5792d262715cbd399d6910200437b40a95dcc0f6", type: .MediationBizboard)
        ]
    }

}
