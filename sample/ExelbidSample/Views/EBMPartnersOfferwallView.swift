//
//  EBMPartnersOfferwallView.swift
//  ExelbidSample
//
//  Created by Jaeuk Jeong on 10/23/24.
//

import UIKit
import ExelBidSDK

class EBMPartnersOfferwallView : UIView {
    @IBOutlet var nativeImageView: UIImageView!
    @IBOutlet var nativeIconView: UIImageView!
    @IBOutlet var nativeTitleLabel: UILabel!
    @IBOutlet var nativeAction: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.initView()
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initView() {
        let nib = UINib(nibName: "EBMPartnersOfferwallView", bundle: nil)
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            addSubview(view)
        }
    }

}

extension EBMPartnersOfferwallView: EBNativeAdRendering {
    
    func nativeTitleTextLabel() -> UILabel? {
        return self.nativeTitleLabel
    }
    
    func nativeIconImageView() -> UIImageView? {
        return self.nativeIconView
    }
    
    func nativeMainImageView() -> UIImageView? {
        return self.nativeImageView
    }
    
    func nativeCallToActionTextLabel() -> UILabel? {
        return self.nativeAction
    }
    
}
