//
//  EBPangleNativeAdView.swift
//  ExelbidSample
//
//  Created by Jaeuk Jeong on 3/19/24.
//

import UIKit
import PAGAdSDK

class EBPangleNativeAdView : UIView {
    var relatedView: PAGLNativeAdRelatedView!
    var titleLabel: UILabel!
    var detailLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .lightGray;
        
        self.relatedView = PAGLNativeAdRelatedView()
        
        addSubview(self.relatedView.mediaView)
        addSubview(self.relatedView.dislikeButton)
        addSubview(self.relatedView.logoADImageView)
        
        self.titleLabel = UILabel();
        self.titleLabel.textAlignment = .center;
        self.titleLabel.textColor = .black;
        addSubview(self.titleLabel)
        
        self.detailLabel = UILabel();
        self.detailLabel.textAlignment = .center;
        self.detailLabel.textColor = .black;
        addSubview(self.detailLabel)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        self.relatedView.mediaView.frame = self.bounds
        self.relatedView.dislikeButton.frame = CGRectMake(0, 0, 44, 44)
        
        var logoSize = CGSizeMake(20, 10)
        self.relatedView.logoADImageView.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - logoSize.height, logoSize.width, logoSize.height)
        self.titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 20)
        self.detailLabel.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 40, CGRectGetWidth(self.bounds), 40)
    }
    
    func refreshWithNativeAd(_ nativeAd: PAGLNativeAd) {
        self.titleLabel.text = nativeAd.data.adTitle
        self.detailLabel.text = nativeAd.data.adDescription
        self.relatedView.refresh(with: nativeAd)
    }
}
