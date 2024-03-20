//
//  UIViewControllerExt.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/02/09.
//

import UIKit

extension UIViewController {
    func setAutoLayout(view: UIView, adView: UIView) {
        adView.translatesAutoresizingMaskIntoConstraints = false
        adView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        adView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        adView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        adView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func setAutoLayout2(view: UIView, adView: UIView) {
        let safeArea = view.safeAreaLayoutGuide
        adView.translatesAutoresizingMaskIntoConstraints = false
        adView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        adView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        adView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        adView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
    }
}
