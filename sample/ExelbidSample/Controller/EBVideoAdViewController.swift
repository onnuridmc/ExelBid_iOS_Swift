//
//  EBVideoAdViewController.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/02/23.
//

import UIKit
import ExelBidSDK

class EBVideoAdViewController: UIViewController {
    @IBOutlet var keywordsTextField: UITextField!
    @IBOutlet var loadAdButton: UIButton!
    @IBOutlet var showAdButton: UIButton!
  
    var info: EBAdInfoModel?
}

extension EBVideoAdViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showAdButton.isHidden = true
        self.keywordsTextField.text = self.info?.ID
        self.loadAdButton.layer.cornerRadius = 3.0
        self.showAdButton.layer.cornerRadius = 3.0
   
        // Do any additional setup after loading the view.
    }
    

    @IBAction func didTapLoadButton(_ sender: UIButton) {
        self.keywordsTextField.endEditing(true)
        
        self.showAdButton.isHidden = true
        self.loadAdButton.isEnabled = false
        
        if let unitId = self.keywordsTextField.text {
            EBVideoManager.initFullVideo(identifier: unitId)
            EBVideoManager.testing(false)
            EBVideoManager.yob("1976")
            EBVideoManager.gender("M")

            EBVideoManager.startWithCompletionHandler { (request, error) in
                if error != nil {
                    self.configureAdLoadFail()
                }else{
                    self.showAdButton.isHidden = false
                }
                self.loadAdButton.isEnabled = true
            }
        }
    }
    
    @IBAction func didTapShowButton(_ sender: UIButton) {
        EBVideoManager.presentAd(controller: self, delegate: self)
        self.showAdButton.isHidden = true       //다음 클릭 초기화 위해 삭제를 합니다.
    }
    
    func configureAdLoadFail() {
        loadAdButton.isEnabled = true
    }
}

extension EBVideoAdViewController: EBVideoDelegate {
    
}
