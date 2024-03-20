//
//  EBCollectionViewAdPlacerView.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/02/19.
//

import UIKit
import ExelBidSDK

class EBCollectionViewAdPlacerView: UIView {
    var titleLabel: UILabel!
    var iconImageView: UIImageView!
    var privacyInformationIconImageView: UIImageView!
    var ctaLabel: UILabel!
   
    override init(frame: CGRect) {
        super.init(frame: frame)
 
        
        titleLabel = UILabel(frame: CGRect(x: 2, y: 0, width: 61, height: 24))
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        titleLabel.text = "Title"
        self.addSubview(titleLabel)

        iconImageView = UIImageView(frame: CGRect(x: 6, y: 30, width: 60, height: 60))
        iconImageView.clipsToBounds = true
        iconImageView.contentMode = .scaleAspectFill
        self.addSubview(iconImageView)
       
        ctaLabel = UILabel(frame: CGRect(x: 2, y: 94, width: 66, height: 15))
        ctaLabel.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        ctaLabel.font = UIFont.systemFont(ofSize: 10)
        ctaLabel.text = "CTA Text"
        ctaLabel.textColor = UIColor(white: 0.91, alpha: 1.0)
        ctaLabel.textAlignment = .center
        ctaLabel.clipsToBounds = true
        self.addSubview(ctaLabel)
        ctaLabel.layer.cornerRadius = 5
        
        privacyInformationIconImageView = UIImageView(frame: CGRect(x: 56, y: 5, width: 12, height: 12))
        self.addSubview(privacyInformationIconImageView)

        backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        titleLabel.textColor = UIColor(white: 0.26, alpha: 1.0)
        
        clipsToBounds = true
        
     }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}


extension EBCollectionViewAdPlacerView: EBNativeAdRendering {
    func nativeTitleTextLabel() -> UILabel? {
        return titleLabel
    }
    
    func nativeIconImageView() -> UIImageView? {
        return iconImageView
    }
     
   
    func nativeCallToActionTextLabel() -> UILabel? {
        return ctaLabel
    }
    
    func nativePrivacyInformationIconImageView() -> UIImageView? {
        return privacyInformationIconImageView
    }
    
    
}
