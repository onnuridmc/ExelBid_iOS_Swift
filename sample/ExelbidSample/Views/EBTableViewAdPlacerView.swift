//
//  EBTableViewAdPlacerView.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/02/15.
//

import UIKit
import ExelBidSDK

class EBTableViewAdPlacerView: UIView {
    var titleLabel: UILabel!
    var mainTextLabel: UILabel!
    var iconImageView: UIImageView!
    var mainImageView: UIImageView!
    var privacyInformationIconImageView: UIImageView!
    var ctaLabel: UILabel!
   
    override init(frame: CGRect) {
        super.init(frame: frame)
 
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.text = "Title"
        self.addSubview(titleLabel)

        mainTextLabel = UILabel()
        mainTextLabel.font = UIFont.systemFont(ofSize: 14)
        mainTextLabel.text = "Text"
        mainTextLabel.numberOfLines = 2
        self.addSubview(mainTextLabel)

        iconImageView = UIImageView()
        self.addSubview(iconImageView)

        mainImageView = UIImageView()
        mainImageView.clipsToBounds = true
        mainImageView.contentMode = .scaleAspectFill
        self.addSubview(mainImageView)
        
        
       
         ctaLabel = UILabel()
        ctaLabel.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        ctaLabel.font = UIFont.systemFont(ofSize: 14)
        ctaLabel.text = "CTA Text"
        ctaLabel.textColor = UIColor(white: 0.91, alpha: 1.0)
        ctaLabel.textAlignment = .center
        ctaLabel.clipsToBounds = true
        self.addSubview(ctaLabel)
    
        privacyInformationIconImageView = UIImageView()
        self.addSubview(privacyInformationIconImageView)

        backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        titleLabel.textColor = UIColor(white: 0.26, alpha: 1.0)
        mainTextLabel.textColor = UIColor(white: 0.26, alpha: 1.0)
        
        clipsToBounds = true
        
     }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    override func layoutSubviews() {
        let width = self.bounds.size.width
        
        self.titleLabel.frame = CGRect(x: 75, y: 10, width: 212, height: 60)
        self.iconImageView.frame = CGRect(x: 10, y: 10, width: 60, height: 60)
        self.privacyInformationIconImageView.frame = CGRect(x: width - 35, y: 10, width: 25, height: 25)
        self.ctaLabel.frame = CGRect(x: width - 100, y: 280, width: 90, height: 40)
        self.mainTextLabel.frame = CGRect(x: width / 2 - 150, y: 68, width: 300, height: 30)
        self.mainImageView.frame = CGRect(x: width / 2 - 150, y: 119, width: 300, height: 156)
        self.ctaLabel.layer.cornerRadius = 5
    }

}


extension EBTableViewAdPlacerView: EBNativeAdRendering {
    func nativeMainTextLabel() -> UILabel? {
        return mainTextLabel
    }
    
    func nativeTitleTextLabel() -> UILabel? {
        return titleLabel
    }
    
    func nativeIconImageView() -> UIImageView? {
        return iconImageView
    }
    
    func nativeMainImageView() -> UIImageView? {
        return mainImageView
    }
    
   
    func nativeCallToActionTextLabel() -> UILabel? {
        return ctaLabel
    }
    
    func nativePrivacyInformationIconImageView() -> UIImageView? {
        return privacyInformationIconImageView
    }
    
    
}
