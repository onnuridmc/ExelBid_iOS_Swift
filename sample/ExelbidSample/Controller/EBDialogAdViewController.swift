//
//  EBDialogAdViewController.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/02/09.
//

import UIKit
import ExelBidSDK

class EBDialogAdViewController: UIViewController {
    @IBOutlet var keywordsTextField1: UITextField!
    @IBOutlet var keywordsTextField2: UITextField!
    @IBOutlet var loadHTMLAdButton: UIButton!
    @IBOutlet var showHTMLAdButton: UIButton!
    @IBOutlet var loadNativeAdButton1: UIButton!
    @IBOutlet var showNativeAdButton1: UIButton!
    @IBOutlet var loadNativeAdButton2: UIButton!
    @IBOutlet var showNativeAdButton2: UIButton!
   
    var info: EBAdInfoModel?
    var nativeAd: EBNativeAd?
    var adView: EBAdView?
  
    var htmlDialogView: EBHTMLDialogView?
    var nativeDialogView: EBNativeDialogView?
    var nativeRoundView: EBNativeRoundView?


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        keywordsTextField1.text = info?.ID.components(separatedBy: ",")[0]
        keywordsTextField2.text = info?.ID.components(separatedBy: ",")[1]
        loadHTMLAdButton.layer.cornerRadius = 3.0
        showHTMLAdButton.layer.cornerRadius = 3.0
        loadNativeAdButton1.layer.cornerRadius = 3.0
        showNativeAdButton1.layer.cornerRadius = 3.0
        loadNativeAdButton2.layer.cornerRadius = 3.0
        showNativeAdButton2.layer.cornerRadius = 3.0
        buttonReset()
        
        htmlDialogView = EBHTMLDialogView(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        nativeDialogView = EBNativeDialogView(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        nativeRoundView = EBNativeRoundView(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        
  
    }

}

extension EBDialogAdViewController {
    @IBAction func didTapHTMLLoadButton(_ sender: UIButton) {
        keywordsTextField1.endEditing(true)
        buttonReset()
        loadHTMLAdButton.isEnabled = false

        if adView != nil {
            adView?.removeFromSuperview()
        }
        
        guard let htmlDialogView = htmlDialogView?.adView else {
            return
        }
        
        adView = EBAdView(adUnitId: keywordsTextField1.text, size: htmlDialogView.bounds.size)
        adView?.delegate = self
        adView?.yob = "1987"
        adView?.gender = "M"
        adView?.fullWebView = true
//        adView?.testing = true
        
        if let adView = adView {
            htmlDialogView.addSubview(adView)
            adView.setAutoLayout(view: htmlDialogView)
            adView.loadAd()
        }
        
    }
    
    @IBAction func didTapHTMLShowButton(_ sender: UIButton) {
        guard let htmlDialogView = htmlDialogView else {
            return
        }
        if let naviView = navigationController?.view {
            naviView.addSubview(htmlDialogView)
            htmlDialogView.setAutoLayout(view: naviView)
        }
    }
   
    @IBAction func didTapNativeLoadButton1(_ sender: UIButton) {
        keywordsTextField1.endEditing(true)
        buttonReset()
        loadNativeAdButton1.isEnabled = false
        clearAd1()
        nativeAdLoad(1)
    }
   
    @IBAction func didTapNativeShowButton1(_ sender: UIButton) {
        guard let nativeDialogView = nativeDialogView else {
            return
        }
        nativeDialogView.adView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        if let adView = nativeAd?.retrieveAdViewWithError(nil) {
            nativeDialogView.adView.addSubview(adView)
            adView.setAutoLayout(view: nativeDialogView.adView)
            if let naviView = navigationController?.view {
                naviView.addSubview(nativeDialogView)
                nativeDialogView.setAutoLayout(view: naviView)
            }
        }
    }
   
    @IBAction func didTapNativeLoadButton2(_ sender: UIButton) {
        keywordsTextField1.endEditing(true)
        buttonReset()
        loadNativeAdButton2.isEnabled = false
        clearAd2()
        nativeAdLoad(2)
    }
   
    @IBAction func didTapNativeShowButton2(_ sender: UIButton) {
        guard let nativeRoundView = nativeRoundView else {
            return
        }
        nativeRoundView.adView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        if let adView = nativeAd?.retrieveAdViewWithError(nil) {
            nativeRoundView.adView.addSubview(adView)
            adView.setAutoLayout(view: nativeRoundView.adView)
          
          
            if let naviView = navigationController?.view {
                naviView.addSubview(nativeRoundView)
                nativeRoundView.setAutoLayout(view: naviView)
            }
        }
  
    }
   
}

extension EBDialogAdViewController {
    func nativeAdLoad(_ type: Int) {
        let settings = EBStaticNativeAdRendererSettings()
        if type == 1 {
            settings.renderingViewClass = EBNativeAdView.self
        }else{
            settings.renderingViewClass = EBNativeAd2View.self
        }
        
        let config = EBStaticNativeAdRenderer.rendererConfigurationWithRendererSettings(settings)
        let adRequest = EBNativeAdRequest.requestWithAdUnitIdentifier(keywordsTextField2.text, rendererConfigurations: [config])
        let targeting = EBNativeAdRequestTargeting()
        targeting.yob = "1976"
        targeting.gender = "M"
//        targeting.testing = true
        adRequest.targeting = targeting
        
        adRequest.startWithCompletionHandler { (request, response, error) in
            if error != nil {
                self.configureAdLoadFail()
                return
            }
            
            self.nativeAd = response
            self.nativeAd?.delegate = self
            if type == 1 {
                self.loadNativeAdButton1.isEnabled = true
                self.showNativeAdButton1.isHidden = false
            }else{
                self.loadNativeAdButton2.isEnabled = true
                self.showNativeAdButton2.isHidden = false
            }
        }
    }
    
    func buttonReset() {
        showHTMLAdButton.isHidden = true
        showNativeAdButton1.isHidden = true
        showNativeAdButton2.isHidden = true
    }
    
    func clearAd1() {
        nativeDialogView?.adView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        nativeAd = nil
    }
    
    func clearAd2() {
        nativeRoundView?.adView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        nativeAd = nil
    }
    
    func configureAdLoadFail() {
        loadNativeAdButton1.isEnabled = true
        loadNativeAdButton2.isEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        keywordsTextField1.resignFirstResponder()
        keywordsTextField2.resignFirstResponder()
    }
    

}


extension EBDialogAdViewController: EBAdViewDelegate {
    func adViewDidLoadAd(_ view: EBAdView?) {
        loadHTMLAdButton.isEnabled = true
        showHTMLAdButton.isHidden = false
    }
    
    func adViewDidFailToLoadAd(_ view: EBAdView?) {
        loadHTMLAdButton.isEnabled = true
    }
    
}

extension EBDialogAdViewController: EBNativeAdDelegate {
    func willLoadForNativeAd(_ nativeAd: EBNativeAd?) {
        print("Will Load for native ad.")
    }
    
    func didLoadForNativeAd(_ nativeAd: EBNativeAd?) {
        print("Did Load for native ad.")
    }
    
    func willLeaveApplicationFromNativeAd(_ nativeAd: EBNativeAd?) {
        print("Will leave application from native ad.")
    }
    
    func viewControllerForPresentingModalView() -> UIViewController? {
       return self
    }
    
}
