//
//  EBFanNativeAdView.swift
//  ExelbidSample
//
//  Created by Jaeuk Jeong on 3/19/24.
//

import Foundation
import UIKit
import FBAudienceNetwork

class EBFanNativeAdView : UIView {
    var adView: UIView!

    @IBOutlet var adIconImageView: FBMediaView!
    @IBOutlet var adCoverMediaView: FBMediaView!
    @IBOutlet var adTitleLabel: UILabel!
    @IBOutlet var adBodyLabel: UILabel!
    @IBOutlet var adCallToActionButton: UIButton!
    @IBOutlet var adSocialContextLabel: UILabel!
    @IBOutlet var sponsoredLabel: UILabel!
    @IBOutlet var adChoicesView: FBAdChoicesView!
    @IBOutlet var adOptionsView: FBAdOptionsView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
