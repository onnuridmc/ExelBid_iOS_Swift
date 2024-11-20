//
//  EBMPartnersOfferwallViewController.swift
//

import UIKit
import Foundation
import ExelBidSDK

let kMPCellIdentifier = "EBMPartnersOfferwallCell"

class EBMPartnersOfferwallViewController : UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var adContainer: UIView!
    
    var contentItems: [[UIView]] = [[], []]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.register(EBMPartnersOfferwallCell.self, forCellReuseIdentifier: kMPCellIdentifier)
        
        loadBannerAd("MPNS100006", section: 0)
        loadNativeAd("MPNS100007", section: 0)
//        loadBannerAd("MPNS100008", section: 0)
//        loadNativeAd("MPNS100009", section: 0)
//        loadBannerAd("MPNS1000010", section: 0)
    }
    
    func loadBannerAd(_ unit_id: String, section: Int = 1, index: Int = -1) {
        let adView = MPartnersAdView(adUnitId: unit_id, size: CGSizeMake(320, 50))

        adView.delegate = self
        adView.fullWebView = true
        adView.yob = "1987"
        adView.gender = "M"
        adView.testing = true
        
        adView.loadAd()
                                     
        if !self.contentItems.indices.contains(section) {
            self.contentItems[section] = []
        }

        let idx = index > -1 ? index : self.contentItems[section].count
        self.contentItems[section].insert(adView, at: idx)

        let indexPath = IndexPath(row: idx, section: section)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func loadNativeAd(_ unit_id: String, section: Int = 1, index: Int = -1) {
        let ebNativeManager = MPartnersNativeManager(unit_id, EBMPartnersOfferwallView.self)
        
        // 광고의 효율을 높이기 위해 옵션 설정
        ebNativeManager.yob("1987")
        ebNativeManager.gender("M")
        ebNativeManager.testing(true)

        // 네이티브 광고 요청시 어플리케이션에서 필수로 요청할 항목들을 설정합니다.
        ebNativeManager.desiredAssets([EBNativeAsset.kAdIconImageKey,
                                       EBNativeAsset.kAdMainImageKey,
                                       EBNativeAsset.kAdCTATextKey,
                                       EBNativeAsset.kAdTextKey,
                                       EBNativeAsset.kAdTitleKey])

        ebNativeManager.startWithCompletionHandler { (request, response, error) in
            if let error = error {
                print(">>> Native Error : \(error.localizedDescription)")
            } else if let response = response {
                response.delegate = self
                if let adView = response.retrieveAdViewWithError(nil) {
                    if !self.contentItems.indices.contains(section) {
                        self.contentItems[section] = []
                    }

                    let idx = index > -1 ? index : self.contentItems[section].count
                    self.contentItems[section].insert(adView, at: idx)
                    
                    let indexPath = IndexPath(row: idx, section: section)
                    self.tableView.insertRows(at: [indexPath], with: .automatic)
                }
            } else {
                print(">>> Native Empty")
            }
        }
    }
    
}

extension EBMPartnersOfferwallViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.contentItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentItems[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: kMPCellIdentifier) as? EBMPartnersOfferwallCell {
            let item = self.contentItems[indexPath.section][indexPath.row]
            cell.adContainer.addSubview(item)
            self.setAutoLayout(view: cell.adContainer, adView: item)

            return cell
        }

        return UITableViewCell(style: .default, reuseIdentifier: kMPCellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(">>> \(#function) : \(indexPath)")
    }
}

extension EBMPartnersOfferwallViewController : EBAdViewDelegate {
    func adViewDidLoadAd(_ view: EBAdView?) {
        print("adViewDidLoadAd.")
    }

    func adViewDidFailToLoadAd(_ view: EBAdView?) {
        print("adViewDidFailToLoadAd.")
    }

    func willLeaveApplicationFromAd(_ view: EBAdView?) {
        print("willLeaveApplicationFromAd.")
    }
}

extension EBMPartnersOfferwallViewController : EBNativeAdDelegate {
    
}
