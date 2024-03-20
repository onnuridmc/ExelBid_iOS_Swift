//
//  EBNativeRoundView.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/02/09.
//

import UIKit

class EBNativeRoundView: UIView {
    var adView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        backView.backgroundColor = UIColor.black
        backView.alpha = 0.6
        self.addSubview(backView)
        backView.setAutoLayout(view: self)
     
        let adBackView = UIView(frame: CGRect(x: 20, y: (frame.size.height-330)/2, width: frame.size.width-40, height: 330))
        adBackView.backgroundColor = UIColor.white
        adBackView.clipsToBounds = true
        self.addSubview(adBackView)
        adBackView.layer.cornerRadius = 10
        adBackView.setAutoLayout(self, top: nil, left: 20, right: -20, bottom: nil, height: 330, width: nil)
        adBackView.setCenterAutoLayout(self, x: nil, y: 0)
      
         
        adView = UIView(frame: CGRect(x: 0, y: 0, width: adBackView.frame.size.width, height: adBackView.frame.size.height))
        adBackView.addSubview(adView)
        adView.setAutoLayout(adBackView, top: 0, left: 0, right: 0, bottom: 0, height: nil, width: nil)

        let adlabelView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        adlabelView.backgroundColor = UIColor.black
        adlabelView.alpha = 0.5
        adBackView.addSubview(adlabelView)
        adlabelView.setAutoLayout(adBackView, top: 0, left: 0, right: nil, bottom: nil, height: 20, width: 30)

        let adlabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        adlabel.font = UIFont.boldSystemFont(ofSize: 10)
        adlabel.textColor = UIColor.white
        adlabel.text = "AD"
        adlabel.textAlignment = .center
        adBackView.addSubview(adlabel)
        adlabel.setAutoLayout(adBackView, top: 0, left: 0, right: nil, bottom: nil, height: 20, width: 30)

        
     
        let closeButton = UIButton(frame: CGRect(x: adBackView.frame.size.width - 40, y: 10, width: 30, height: 30))
        closeButton.setImage(UIImage(named: "close"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
        adBackView.addSubview(closeButton)
        closeButton.setAutoLayout(adBackView, top: 10, left: nil, right: -10, bottom: nil, height: 30, width: 30)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func closeClick() {
        self.removeFromSuperview()
    }
}
