//
//  EBPangleNativeAdView.swift
//  ExelbidSample
//
//  Created by Jaeuk Jeong on 3/19/24.
//

import UIKit
import PAGAdSDK

class EBPangleNAtiveAdView : UIView {
    var relatedView: PAGLNativeAdRelatedView?
    var titleLabel: UILabel?
    var detailLabel: UILabel?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.relatedView?.mediaView.frame = self.bounds
        self.relatedView?.dislikeButton.frame = CGRectMake(0, 0, 44, 44)
        
        var logoSize = CGSizeMake(20, 10)
        self.relatedView?.logoADImageView.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - logoSize.height, logoSize.width, logoSize.height)
        self.titleLabel?.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 20)
        self.detailLabel?.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 40, CGRectGetWidth(self.bounds), 40)
    }
    
    func refreshWithNativeAd(_ nativeAd: PAGLNativeAd) {
        self.titleLabel?.text = nativeAd.data.adTitle
        self.detailLabel?.text = nativeAd.data.adDescription
        self.relatedView?.refresh(with: nativeAd)
    }
}
