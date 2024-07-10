//
//  EBVideoAdViewController.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/02/23.
//

import UIKit
import ExelBidSDK

class EBVideoAdViewController: UIViewController, EBVideoDelegate {
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
            
            // 광고의 효율을 높이기 위해 옵션 설정
            EBVideoManager.yob("1987")
            EBVideoManager.gender("M")
            EBVideoManager.testing(true)

            EBVideoManager.startWithCompletionHandler { (request, error) in
                if let error = error  {
                    print(">>> \(error.localizedDescription)")
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
