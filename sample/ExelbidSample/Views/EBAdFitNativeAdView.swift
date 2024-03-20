//
//  EBAdFitNativeAdView.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by Jaeuk Jeong on 2023/08/14.
//

import Foundation
import UIKit
import AdFitSDK

class EBAdFitNativeAdView : UIView {
    @IBOutlet var titleLabel : UILabel?
    @IBOutlet var bodyLabel : UILabel?
    @IBOutlet var callToActionButton : UIButton?
    @IBOutlet var profileNameLabel : UILabel?
    @IBOutlet var profileIconView : UIImageView?
    @IBOutlet var mediaView : AdFitMediaView?
}

extension EBAdFitNativeAdView : AdFitNativeAdRenderable {
    func adTitleLabel() -> UILabel? {
        return self.titleLabel
    }
    
    func adCallToActionButton() -> UIButton? {
        return self.callToActionButton
    }
    
    func adProfileNameLabel() -> UILabel? {
        return self.profileNameLabel
    }
    
    func adProfileIconView() -> UIImageView? {
        return self.profileIconView
    }
    
    func adMediaView() -> AdFitSDK.AdFitMediaView? {
        return self.mediaView
    }
}
