//
//  EBAdInfo.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/01/20.
//

import Foundation

struct EBAdInfo {
    static var shared = EBAdInfo()

    func bannerAds() -> [EBAdInfoModel] {
        return [
            EBAdInfoModel(title: "배너광고", ID: "08377f76c8b3e46c4ed36c82e434da2b394a4dfa", type: .Banner),
            EBAdInfoModel(title: "전면광고", ID: "615217b82a648b795040baee8bc81986a71d0eb7", type: .AllBanner),
            EBAdInfoModel(title: "다이얼로그광고", ID: "615217b82a648b795040baee8bc81986a71d0eb7,5792d262715cbd399d6910200437b40a95dcc0f6", type: .DailBanner)
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
            EBAdInfoModel(title: "비디오 네이티브", ID: "5792d262715cbd399d6910200437b40a95dcc0f6", type: .NativeVideo)
        ]
    }
    
    func etcAds() -> [EBAdInfoModel] {
        
        return [
            EBAdInfoModel(title: "미디에이션 Banner", ID: "08377f76c8b3e46c4ed36c82e434da2b394a4dfa", type: .MediationBanner),
            EBAdInfoModel(title: "미디에이션 Interstitial", ID: "615217b82a648b795040baee8bc81986a71d0eb7", type: .MediationInterstitial),
            EBAdInfoModel(title: "미디에이션 Interstitial Video", ID: "202748c414a9f9a0be6c73893bc1589c6bc9af4a", type: .MediationInterstitialVideo),
            EBAdInfoModel(title: "미디에이션 Native", ID: "5792d262715cbd399d6910200437b40a95dcc0f6", type: .MediationNative),
            EBAdInfoModel(title: "미디에이션 Native Video", ID: "a43a885cdb49fb515b18d2db5e14c58a735fe7ee", type: .MediationNativeVideo),
//            EBAdInfoModel(title: "미디에이션 BizboardView", ID: "5792d262715cbd399d6910200437b40a95dcc0f6", type: .MediationBizboard),
            EBAdInfoModel(title: "애드태그", ID: "", type: .AdTag)
        ]
    }

}
