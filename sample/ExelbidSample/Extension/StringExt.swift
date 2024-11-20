//
//  StringExt.swift
//  ExelbidSample
//
//  Created by Jaeuk Jeong on 11/6/24.
//

import Foundation
import UIKit

extension String {
    func alert(_ viewController: UIViewController) {
        let alert = UIAlertController(title: nil, message: self, preferredStyle: .alert)

        alert.view.layer.cornerRadius = 10
        
        viewController.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alert.dismiss(animated: true)
        }
    }
}
