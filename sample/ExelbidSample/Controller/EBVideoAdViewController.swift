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
    @IBOutlet var isTest: UIButton!
    @IBOutlet var loadAdButton: UIButton!
    @IBOutlet var showAdButton: UIButton!
  
    var info: EBAdInfoModel?
    var videoManager: EBVideoManager?
}

extension EBVideoAdViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keywordsTextField.text = self.info?.ID
    }
    
    @IBAction func loadAdClicked(_ sender: UIButton) {
        guard let identifier = keywordsTextField.text else {
            return
        }
        
        keywordsTextField.endEditing(true)
        
        loadAdButton.isEnabled = false
        
        self.videoManager = EBVideoManager(identifier: identifier)
        
        if let videoManager = self.videoManager {
            // 광고의 효율을 높이기 위해 옵션 설정
            videoManager.yob("1987")
            videoManager.gender("M")
            
            // 테스트 광고 설정 (true - 테스트 광고가 응답)
            videoManager.testing(isTest.isSelected)

            videoManager.startWithCompletionHandler { (request, error) in
                self.loadAdButton.isEnabled = true
                
                if let error = error  {
                    print(">>> \(error.localizedDescription)")

                    "Fail Load Ad".alert(self)
                }else{
                    self.showAdButton.isEnabled = true
                    
                    "Load Ad".alert(self)
                }
            }
        }
    }
    
    @IBAction func showAdButton(_ sender: UIButton) {
        showAdButton.isEnabled = false
        
        if let videoManager = videoManager {
            videoManager.presentAd(controller: self, delegate: self)
        } else {
            "Error Video".alert(self)
        }
    }
    
    @IBAction func toggleTestButton(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        keywordsTextField.resignFirstResponder()
    }
}
