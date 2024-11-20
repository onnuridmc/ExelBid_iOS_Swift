//
//  EBTabBarController.swift
//

import Foundation
import UIKit

class EBTabBarController : UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if navigationController != nil {
            let image = UIImage(named: "logo")
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            navigationItem.titleView = imageView
        }
    }
}
