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
        targeting.desiredAssets = NSSet(objects:EBNativeAsset.kAdIconImageKey,
                                        EBNativeAsset.kAdMainImageKey,
                                        EBNativeAsset.kAdCTATextKey,
                                        EBNativeAsset.kAdTextKey,
                                        EBNativeAsset.kAdTitleKey)
        targeting.testing = true
        targeting.yob = "1976"
        targeting.gender = "M"
        
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
