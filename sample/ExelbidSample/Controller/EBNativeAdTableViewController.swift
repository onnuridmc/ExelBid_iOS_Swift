//
//  EBNativeAdTableViewController.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/02/15.
//

import UIKit
import CoreLocation
import ExelBidSDK

let kDefaultCellIdentifier = "ExelBidSampleAppTableViewAdPlacerCell"

class EBNativeAdTableViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    var contentItems: [String]! = []
    var placer: EBTableViewAdPlacer?
    
    var info: EBAdInfoModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: kDefaultCellIdentifier)
        
        for i in 0 ..< 100 {
            contentItems.append("Item \(i)")
        }
        
        setupAdPlacer()
    }
    

    func setupAdPlacer() {
        // Create a targeting object to serve better ads.
        let targeting = EBNativeAdRequestTargeting.targeting
        targeting.location = CLLocation(latitude: 37.7793, longitude: -122.4175)
        
        // 네이티브 광고 요청시 어플리케이션에서 필수로 요청할 항목들을 설정합니다.
        targeting.desiredAssets = [EBNativeAsset.kAdIconImageKey,
                                       EBNativeAsset.kAdMainImageKey,
                                       EBNativeAsset.kAdCTATextKey,
                                       EBNativeAsset.kAdTextKey,
                                       EBNativeAsset.kAdTitleKey]

        // 광고의 효율을 높이기 위해 옵션 설정
        targeting.yob = "1987"
        targeting.gender = "M"
//        targeting.testing = true
        
        // Create and configure a renderer configuration.
        
        // Static native ads
        let nativeAdSettings = EBStaticNativeAdRendererSettings()
        nativeAdSettings.renderingViewClass = EBTableViewAdPlacerView.self
        nativeAdSettings.viewSizeHandler = { maximumWidth -> CGSize in
            return CGSize(width: maximumWidth, height: 330)
        }
        
        let nativeAdConfig = EBStaticNativeAdRenderer.rendererConfigurationWithRendererSettings(nativeAdSettings)
        
        // Create a table view ad placer that uses server-side ad positioning.
        self.placer = EBTableViewAdPlacer.placerWithTableView(self.tableView, viewController: self, rendererConfigurations: [nativeAdConfig])
        self.placer?.delegate = self
        
        self.placer?.loadAdsForAdUnitID(self.info?.ID, targeting: targeting)
        
        
    }

}

extension EBNativeAdTableViewController : EBTableViewAdPlacerDelegate {
    func nativeAdWillLoadForTableViewAdPlacer(_ placer: EBTableViewAdPlacer?) {
        print("Table view ad placer will Load.")
    }
    
    func nativeAdDidLoadForTableViewAdPlacer(_ placer: EBTableViewAdPlacer?) {
        print("Table view ad placer did Load.")
    }
    
    func nativeAdWillLeaveApplicationFromTableViewAdPlacer(_ placer: EBTableViewAdPlacer?) {
        print("Table view ad placer will leave application.")
    }
    
    
}

extension EBNativeAdTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contentItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.EB_dequeueReusableCellWithIdentifier(kDefaultCellIdentifier, forIndexPath: indexPath) {
            let fontName = self.contentItems[indexPath.row]
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
            cell.textLabel?.text = fontName
            return cell
        }
        return UITableViewCell(style: .default, reuseIdentifier: kDefaultCellIdentifier)
    }
}

extension EBNativeAdTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.EB_deselectRowAtIndexPath(indexPath, animated: true)
    }
}
