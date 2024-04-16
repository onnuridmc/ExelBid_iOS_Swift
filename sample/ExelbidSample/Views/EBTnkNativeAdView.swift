//
//  EBTnkNativeAdView.swift
//  ExelbidSample
//

import Foundation
import UIKit

class EBTnkNativeAdView: UIView {
    @IBOutlet var nativeImageView:UIImageView!
    @IBOutlet var nativeIconView:UIImageView!
    @IBOutlet var nativeTitleLabel:UILabel!
    @IBOutlet var nativeDescLabel:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.initView()
    }
    
    func initView() {
        let nib = UINib(nibName: "EBTnkNativeAdView", bundle: nil)
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            addSubview(view)
        }
    }

}
