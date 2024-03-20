//
//  UIViewExt.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/06/01.
//

import Foundation
import UIKit

extension UIView {
    func setAutoLayout(view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func setAutoLayout2(view: UIView) {
        let safeArea = view.safeAreaLayoutGuide
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
    }
    
    func setAutoLayout(_ view: UIView, top: Int?, left: Int?, right: Int?, bottom: Int?, height: Int?, width: Int?) {
        self.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            let safeArea = view.safeAreaLayoutGuide
            if let top = top {
                self.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: CGFloat(top)).isActive = true
            }
            if let left = left {
                self.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: CGFloat(left)).isActive = true
            }
            if let right = right {
                self.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: CGFloat(right)).isActive = true
            }
            if let bottom = bottom {
                self.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: CGFloat(bottom)).isActive = true
            }
            if let height = height {
                self.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
            }
            if let width = width {
                self.widthAnchor.constraint(equalToConstant: CGFloat(width)).isActive = true
            }
        }else{
            if let top = top {
                self.topAnchor.constraint(equalTo: view.topAnchor, constant: CGFloat(top)).isActive = true
            }
            if let left = left {
                self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CGFloat(left)).isActive = true
            }
            if let right = right {
                self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: CGFloat(right)).isActive = true
            }
            if let bottom = bottom {
                self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: CGFloat(bottom)).isActive = true
            }
            if let height = height {
                self.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
            }
            if let width = width {
                self.widthAnchor.constraint(equalToConstant: CGFloat(width)).isActive = true
            }
        }
    }
    
    func setCenterAutoLayout(_ view: UIView, x: Int?, y: Int?) {
        self.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            let safeArea = view.safeAreaLayoutGuide
            if let x = x {
                self.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor, constant: CGFloat(x)).isActive = true
            }
            if let y = y {
                self.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor, constant: CGFloat(y)).isActive = true
            }

        }else{
            if let x = x {
                self.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: CGFloat(x)).isActive = true
            }
            if let y = y {
                self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: CGFloat(y)).isActive = true
            }
        }
    }
}
