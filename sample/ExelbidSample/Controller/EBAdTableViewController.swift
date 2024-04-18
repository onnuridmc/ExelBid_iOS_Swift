//
//  EBAdTableViewController.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/01/20.
//

import UIKit
import AppTrackingTransparency

class EBAdTableViewController: UITableViewController {
    
    var sections : [EBAdSectionModel] = EBAdSection.shared.adSections()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
     
        if let path = Bundle.main.path(forResource: "SetInstallAttributionPingbackDelay", ofType: "mobileconfig") {
            let fileUrl = URL(fileURLWithPath: path)
            UIApplication.shared.open(fileUrl, options: [:], completionHandler: nil)
        }
        
        // 사용자로부터 개인정보 보호에 관한 권한을 요청해야 합니다.
        // 앱 설치 후 첫실행 시 한번만 요청되며, 사용자가 권한에 대해 응답 후 더 이상 사용자에게 권한 요청을 하지 않습니다.
        // 광고식별자를 수집하지 못하는 경우 광고 요청에 대해 응답이 실패할 수 있습니다.
        if #available(iOS 14.0, *) {
            ATTrackingManager.requestTrackingAuthorization { _ in
            }
        }
    }
    
    
    func info(indexPath: IndexPath) -> EBAdInfoModel {
        return sections[indexPath.section].adAtIndex(indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let indexPath = sender as? IndexPath else {
            return
        }
        let info = self.info(indexPath:indexPath)
        if segue.identifier == "Banner" {
            if let controller = segue.destination as? EBBannerAdViewController {
                controller.info = info
            }
        }else if segue.identifier == "FrontBanner" {
            if let controller = segue.destination as? EBFrontBannerAdViewController {
                controller.info = info
            }
        }else if segue.identifier == "Native" {
            if let controller = segue.destination as? EBNativeAdViewController {
                controller.info = info
            }
        }else if segue.identifier == "Native Banner" {
            if let controller = segue.destination as? EBNativeBannerAdViewController {
                controller.info = info
            }
        }else if segue.identifier == "TableView" {
            if let controller = segue.destination as? EBNativeAdTableViewController {
                controller.info = info
            }
        }else if segue.identifier == "CollectionView" {
            if let controller = segue.destination as? EBNativeAdCollectionViewController {
                controller.info = info
            }
        }else if segue.identifier == "Video" {
            if let controller = segue.destination as? EBVideoAdViewController {
                controller.info = info
            }
        }else if segue.identifier == "Dialog" {
            if let controller = segue.destination as? EBDialogAdViewController {
                controller.info = info
            }
        }else if segue.identifier == "NativeVideo" {
            if let controller = segue.destination as? EBNativeVideoAdViewController {
                controller.info = info
            }
        }else if segue.identifier == "MediationBanner" {
            if let controller = segue.destination as? EBMediationBannerViewController {
                controller.info = info
            }
        }else if segue.identifier == "MediationInterstitial" {
            if let controller = segue.destination as? EBMediationInterstitialViewController {
                controller.info = info
            }
        }else if segue.identifier == "MediationInterstitialVideo" {
            if let controller = segue.destination as? EBMediationInterstitialVideoViewController {
                controller.info = info
            }
        }else if segue.identifier == "MediationNative" {
            if let controller = segue.destination as? EBMediationNativeAdViewController {
                controller.info = info
            }
        }else if segue.identifier == "MediationNativeVideo" {
            if let controller = segue.destination as? EBMediationNativeVideoAdViewController {
                controller.info = info
            }
        }else if segue.identifier == "MediationBizboardView" {
            if let controller = segue.destination as? EBMediationBizBoardViewController {
                controller.info = info
            }
        }else if segue.identifier == "AdTag" {
            if let controller = segue.destination as? EBAdTagViewController {
                controller.info = info
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.sections[section].count()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let info = self.info(indexPath: indexPath)
        cell.textLabel?.text = info.title
        cell.textLabel?.textColor = UIColor(red: 0.32, green: 0.36, blue: 0.35, alpha: 1)
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].title
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = self.info(indexPath: indexPath)
        switch info.type {
            case .Banner:
                performSegue(withIdentifier: "Banner", sender: indexPath)
            case .AllBanner:
                performSegue(withIdentifier: "FrontBanner", sender: indexPath)
            case .DailBanner:
                performSegue(withIdentifier: "Dialog", sender: indexPath)
            case .Native:
                performSegue(withIdentifier: "Native", sender: indexPath)
            case .NativeBanner:
                performSegue(withIdentifier: "Native Banner", sender: indexPath)
            case .NativeInCollectionView:
                performSegue(withIdentifier: "CollectionView", sender: indexPath)
            case .NativeTableViewPlacer:
                performSegue(withIdentifier: "TableView", sender: indexPath)
            case .Video:
                performSegue(withIdentifier: "Video", sender: indexPath)
            case .NativeVideo:
                performSegue(withIdentifier: "NativeVideo", sender: indexPath)
            case .MediationBanner:
                performSegue(withIdentifier: "MediationBanner", sender: indexPath)
            case .MediationInterstitial:
                performSegue(withIdentifier: "MediationInterstitial", sender: indexPath)
            case .MediationInterstitialVideo:
                performSegue(withIdentifier: "MediationInterstitialVideo", sender: indexPath)
            case .MediationNative:
                performSegue(withIdentifier: "MediationNative", sender: indexPath)
            case .MediationNativeVideo:
                performSegue(withIdentifier: "MediationNativeVideo", sender: indexPath)
            case .MediationBizboard:
                performSegue(withIdentifier: "MediationBizboardView", sender: indexPath)
            case .AdTag:
                performSegue(withIdentifier: "AdTag", sender: indexPath)
        }
    }
}
