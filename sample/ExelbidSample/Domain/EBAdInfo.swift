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
            EBAdInfoModel(title: "배너광고", ID: "cd54f7365c637fc41327422e3b7dee8d7fb3dcec", type: .Banner),
            EBAdInfoModel(title: "전면광고", ID: "e88b95b25a0c736cb218135814f84f644dfd4248", type: .AllBanner),
            EBAdInfoModel(title: "다이얼로그광고", ID: "e88b95b25a0c736cb218135814f84f644dfd4248,7590634941fa4bd366b49bb46eb3043bc63d42d6", type: .DailBanner)
        ]
    }
    
    func nativeAds() -> [EBAdInfoModel] {
        return [
            EBAdInfoModel(title: "네이티브", ID: "7590634941fa4bd366b49bb46eb3043bc63d42d6", type: .Native),
            EBAdInfoModel(title: "네이티브 Banner", ID: "d8bd935d16c258c21e506ee7dd0f532986c23dae", type: .NativeBanner),
            EBAdInfoModel(title: "네이티브 Ad (CollectionView)", ID: "7590634941fa4bd366b49bb46eb3043bc63d42d6", type: .NativeInCollectionView),
            EBAdInfoModel(title: "네이티브 Ad (TableView)", ID: "7590634941fa4bd366b49bb46eb3043bc63d42d6", type: .NativeTableViewPlacer)
        ]
    }
    
    func videoAds() -> [EBAdInfoModel] {
        return [
            EBAdInfoModel(title: "비디오 전면", ID: "202748c414a9f9a0be6c73893bc1589c6bc9af4a", type: .Video),
            EBAdInfoModel(title: "비디오 네이티브", ID: "7590634941fa4bd366b49bb46eb3043bc63d42d6", type: .NativeVideo)
        ]
    }
    
    func etcAds() -> [EBAdInfoModel] {
        
        return [
            EBAdInfoModel(title: "미디에이션 Banner", ID: "cd54f7365c637fc41327422e3b7dee8d7fb3dcec", type: .MediationBanner),
            EBAdInfoModel(title: "미디에이션 Interstitial", ID: "e88b95b25a0c736cb218135814f84f644dfd4248", type: .MediationInterstitial),
            EBAdInfoModel(title: "미디에이션 Native", ID: "7590634941fa4bd366b49bb46eb3043bc63d42d6", type: .MediationNative),
            EBAdInfoModel(title: "미디에이션 Native Video", ID: "a43a885cdb49fb515b18d2db5e14c58a735fe7ee", type: .MediationNativeVideo),
//            EBAdInfoModel(title: "미디에이션 BizboardView", ID: "7590634941fa4bd366b49bb46eb3043bc63d42d6", type: .MediationBizboard),
//            EBAdInfoModel(title: "애드태그", ID: "d8bd935d16c258c21e506ee7dd0f532986c23dae", type: .AdTag)
        ]
    }

}
