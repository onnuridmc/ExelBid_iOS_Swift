//
//  EBMPartnersOfferwallCell.swift
//

import UIKit
import ExelBidSDK

class EBMPartnersOfferwallCell : UITableViewCell {
    
    var adContainer : UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        adContainer = UIView()
        adContainer.backgroundColor = UIColor(named: "DefaultColor")
        adContainer.layer.cornerRadius = 5
        adContainer.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        adContainer.layer.shadowOpacity = 0.4
        adContainer.layer.shadowOffset = CGSize(width: 2, height: 2)
        adContainer.layer.shadowRadius = 3
        
        contentView.addSubview(adContainer)
        
        adContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            adContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            adContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            adContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            adContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            adContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        adContainer.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

extension EBMPartnersOfferwallCell : EBAdViewDelegate {
    func adViewDidLoadAd(_ view: EBAdView?) {
        print("adViewDidLoadAd.")
    }

    func adViewDidFailToLoadAd(_ view: EBAdView?) {
        print("adViewDidFailToLoadAd.")
    }

    func willLeaveApplicationFromAd(_ view: EBAdView?) {
        print("willLeaveApplicationFromAd.")
    }
}

extension EBMPartnersOfferwallCell : EBNativeAdDelegate {
    
}
