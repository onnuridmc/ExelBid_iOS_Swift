//
//  EBAdSection.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/01/20.
//

import Foundation

struct EBAdSection {
    static var shared = EBAdSection()
    
    func adSections() -> [EBAdSectionModel] {
        return [
            EBAdSectionModel(title: "MPartners Ads", ad: EBAdInfo.shared.mpartnersAds()),
            EBAdSectionModel(title: "Banner Ads", ad: EBAdInfo.shared.bannerAds()),
            EBAdSectionModel(title: "Native Ads", ad: EBAdInfo.shared.nativeAds()),
            EBAdSectionModel(title: "Video Ads", ad: EBAdInfo.shared.videoAds()),
            EBAdSectionModel(title: "Etc Ads", ad: EBAdInfo.shared.etcAds())
        ]
    }
    
}
