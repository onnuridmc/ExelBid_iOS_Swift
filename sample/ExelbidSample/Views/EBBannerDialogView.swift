//
//  EBBannerDialogView.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/02/09.
//

import UIKit

class EBBannerDialogView: UIView {
    var adView: UIView!
    var closeButton: UIButton!
    var cancleButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
 
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        backView.backgroundColor = UIColor.black
        backView.alpha = 0.6
        self.addSubview(backView)
        backView.setAutoLayout(view: self)
        
        let adBackView = UIView(frame: CGRect(x: 20, y: 20, width: frame.size.width - 40, height: frame.size.height - 40 - UIApplication.shared.statusBarFrame.height))
        adBackView.backgroundColor = UIColor.white
        self.addSubview(adBackView)
        adBackView.setAutoLayout(self, top: 20, left: 20, right: -20, bottom: -20, height: nil, width: nil)
        
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 0, width: adBackView.frame.width - 40, height: 50))
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = UIColor(white: 0.3, alpha: 1)
        titleLabel.text = "Title"
        adBackView.addSubview(titleLabel)
        titleLabel.setAutoLayout(adBackView, top: 0, left: 20, right: 20, bottom: nil, height: 50, width: nil)
       
        let lineView = UIView(frame: CGRect(x: 0, y: 50, width: frame.size.width, height: 1))
        lineView.backgroundColor = UIColor(white: 0.5, alpha: 1)
        adBackView.addSubview(lineView)
        lineView.setAutoLayout(adBackView, top: 50, left: 0, right: 0, bottom: nil, height: 1, width: nil)

        adView = UIView(frame: CGRect(x: 0, y: 50, width: adBackView.frame.size.width, height: adBackView.frame.size.height - 110))
        adBackView.addSubview(adView)
        adView.setAutoLayout(adBackView, top: 50, left: 0, right: 0, bottom: -110, height: nil, width: nil)

        closeButton = UIButton(frame: CGRect(x: 10, y: adBackView.frame.size.height - 60, width: adBackView.frame.size.width/2 - 20, height: 50))
        closeButton.backgroundColor = UIColor(white: 0.3, alpha: 1)
        closeButton.tintColor = UIColor.white
        closeButton.setTitle("종료", for: .normal)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        closeButton.layer.cornerRadius = 5
        closeButton.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
        adBackView.addSubview(closeButton)
        closeButton.setAutoLayout(adBackView, top: nil, left: 10, right: nil, bottom: -10, height: 50, width: Int(adBackView.frame.size.width/2 - 20))

        cancleButton = UIButton(frame: CGRect(x: adBackView.frame.size.width/2 + 10, y: adBackView.frame.size.height - 60, width: adBackView.frame.size.width/2 - 20, height: 50))
        cancleButton.backgroundColor = UIColor(white: 0.3, alpha: 1)
        cancleButton.tintColor = UIColor.white
        cancleButton.setTitle("취소", for: .normal)
        cancleButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        cancleButton.layer.cornerRadius = 5
        cancleButton.addTarget(self, action: #selector(cancleClick), for: .touchUpInside)
        adBackView.addSubview(cancleButton)
        cancleButton.setAutoLayout(adBackView, top: nil, left: nil, right: -10, bottom: -10, height: 50, width: Int(adBackView.frame.size.width/2 - 20))

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func cancleClick() {
        self.removeFromSuperview()
    }
    
    @objc func closeClick() {
        exit(0)
    }
}
