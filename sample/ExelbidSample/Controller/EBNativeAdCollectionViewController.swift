//
//  EBNativeAdCollectionViewController.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/02/19.
//

import UIKit
import CoreLocation
import ExelBidSDK

class EBNativeAdCollectionViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var layout: UICollectionViewFlowLayout!
    
    var contentItems:[UIColor]! = []
    var info: EBAdInfoModel?
    var placer: EBCollectionViewAdPlacer?

    let kReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.layout.scrollDirection = .horizontal
        self.layout.itemSize = CGSize(width: 70, height: 113)
        self.collectionView.setCollectionViewLayout(self.layout, animated: true)
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kReuseIdentifier)

        for _ in 0 ..< 200 {
            let r = CGFloat.random(in: 0...256) / 255
            let g = CGFloat.random(in: 0...256) / 255
            let b = CGFloat.random(in: 0...256) / 255
            let color = UIColor(red: r, green: g, blue: b, alpha: 1)
            contentItems.append(color)
        }
        
        setupAdPlacer()
    }
    
    func setupAdPlacer() {
        // Create a targeting object to serve better ads.
        let targeting = EBNativeAdRequestTargeting.targeting
        
        // 네이티브 광고 요청시 어플리케이션에서 필수로 요청할 항목들을 설정합니다.
        targeting.desiredAssets = [EBNativeAsset.kAdIconImageKey,
                                   EBNativeAsset.kAdCTATextKey,
                                   EBNativeAsset.kAdTitleKey]
        
        // 광고의 효율을 높이기 위해 옵션 설정
        targeting.yob = "1987"
        targeting.gender = "M"
//        targeting.testing = true
        
        // Create and configure a renderer configuration.
        
        // Static native ads
        let nativeAdSettings = EBStaticNativeAdRendererSettings()
        nativeAdSettings.renderingViewClass = EBCollectionViewAdPlacerView.self
        nativeAdSettings.viewSizeHandler = { maximumWidth -> CGSize in
            return CGSize(width: 70, height: 113)
        }
        
         let nativeAdConfig = EBStaticNativeAdRenderer.rendererConfigurationWithRendererSettings(nativeAdSettings)
        
        // Create a table view ad placer that uses server-side ad positioning.
        self.placer = EBCollectionViewAdPlacer.placerWithCollectionView(self.collectionView, viewController: self, rendererConfigurations: [nativeAdConfig])
        self.placer?.delegate = self
        
        self.placer?.loadAdsForAdUnitID(self.info?.ID, targeting: targeting)
        
    }

}

extension EBNativeAdCollectionViewController : EBCollectionViewAdPlacerDelegate {
    func nativeAdWillLoadForCollectionViewAdPlacer(_ placer: EBCollectionViewAdPlacer) {
        print("Collection view ad placer will Load.")
    }
    
    func nativeAdDidLoadForCollectionViewAdPlacer(_ placer: EBCollectionViewAdPlacer) {
        print("Collection view ad placer did Load.")
    }
    
    func nativeAdWillLeaveApplicationFromCollectionViewAdPlacer(_ placer: EBCollectionViewAdPlacer) {
        print("Collection view ad placer will leave application.")
    }
    
    
}

extension EBNativeAdCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.contentItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.EB_dequeueReusableCellWithIdentifier(kReuseIdentifier, forIndexPath: indexPath) {
            cell.backgroundColor = self.contentItems[indexPath.row]
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kReuseIdentifier, for: indexPath)
        return cell
    }
    
    
}
