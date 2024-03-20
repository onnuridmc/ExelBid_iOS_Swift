//
//  Models.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/01/20.
//

import Foundation

struct EBAdInfoModel {
    
    var title: String
    var ID: String
    var type: EBAdInfoType = .Banner
    var keyWord: String?
    
    enum EBAdInfoType {
        case Banner, AllBanner, DailBanner, Native, NativeBanner, NativeTableViewPlacer, NativeInCollectionView, Video, NativeVideo, MediationBanner, MediationInterstitial, MediationNative, MediationBizboard, AdTag
    }
}


struct EBAdSectionModel {
    var title: String
    var ad: [EBAdInfoModel]
    
    func adAtIndex(_ idx: Int) -> EBAdInfoModel {
        return ad[idx]
    }
    
    func count() -> Int {
        return ad.count
    }

}
