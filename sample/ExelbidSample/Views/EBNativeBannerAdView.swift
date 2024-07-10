//
//  EBNativeBannerAdView.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/02/09.
//

import UIKit
import ExelBidSDK

class EBNativeBannerAdView: UIView {

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
        
        privacyInformationIconImageView = UIImageView()
        self.addSubview(privacyInformationIconImageView)

        ctaLabel = UILabel()
        ctaLabel.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        ctaLabel.font = UIFont.systemFont(ofSize: 14)
        ctaLabel.text = "CTA Text"
        ctaLabel.textColor = UIColor(white: 0.91, alpha: 1.0)
        ctaLabel.textAlignment = .center
        ctaLabel.clipsToBounds = true
        self.addSubview(ctaLabel)

        backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        titleLabel.textColor = UIColor(white: 0.26, alpha: 1.0)
        mainTextLabel.textColor = UIColor(white: 0.26, alpha: 1.0)
        
        self.perform(#selector(self.adAnimation1), with: nil, afterDelay: 2)
        clipsToBounds = true
        
     }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    override func layoutSubviews() {
        let width = self.bounds.size.width
        
        self.titleLabel.frame = CGRect(x: 70, y: 0, width:  width - 170, height: 50)
        self.iconImageView.frame = CGRect(x: 20, y: 10, width: 30, height: 30)
        self.privacyInformationIconImageView.frame = CGRect(x: width - 95, y: 12, width: 25, height: 25)
        self.ctaLabel.frame = CGRect(x: width - 60, y: 10, width: 50, height: 30)
        self.mainTextLabel.frame = CGRect(x: 70, y: 50, width: width - 170, height: 50)
        self.ctaLabel.layer.cornerRadius = 3
        
    }

    @objc func adAnimation1() {
        let width = self.bounds.size.width
        UIView.animate(withDuration: 1) {
            self.titleLabel.frame = CGRect(x: 70, y: -50, width: width - 170, height: 50)
            self.mainTextLabel.frame = CGRect(x: 70, y: 0, width: width - 170, height: 50)
        } completion: { ( finished ) in
            self.titleLabel.frame = CGRect(x: 70, y: 50, width: width - 170, height: 50)
            self.perform(#selector(self.adAnimation2), with: nil, afterDelay: 2)
        }

    }
    
    @objc func adAnimation2() {
        let width = self.bounds.size.width
        UIView.animate(withDuration: 1) {
            self.titleLabel.frame = CGRect(x: 70, y: 0, width: width - 170, height: 50)
            self.mainTextLabel.frame = CGRect(x: 70, y: -50, width: width - 170, height: 50)
        } completion: { ( finished ) in
            self.titleLabel.frame = CGRect(x: 70, y: 50, width: 200, height: 50)
            self.perform(#selector(self.adAnimation1), with: nil, afterDelay: 2)
        }
    }

}

extension EBNativeBannerAdView: EBNativeAdRendering {
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
