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
        }else if segue.identifier == "Interstitial" {
            if let controller = segue.destination as? EBInterstitialAdViewController {
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
        }else if segue.identifier == "Native Video" {
            if let controller = segue.destination as? EBNativeVideoAdViewController {
                controller.info = info
            }
        }else if segue.identifier == "Mediation Banner" {
            if let controller = segue.destination as? EBMediationBannerViewController {
                controller.info = info
            }
        }else if segue.identifier == "Mediation Interstitial" {
            if let controller = segue.destination as? EBMediationInterstitialViewController {
                controller.info = info
            }
        }else if segue.identifier == "Mediation Interstitial Video" {
            if let controller = segue.destination as? EBMediationInterstitialVideoViewController {
                controller.info = info
            }
        }else if segue.identifier == "Mediation Native" {
            if let controller = segue.destination as? EBMediationNativeAdViewController {
                controller.info = info
            }
        }else if segue.identifier == "Mediation Native Video" {
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
        }else if segue.identifier == "MPartners Banner" {
            if let controller = segue.destination as? EBMPartnersBannerAdViewController {
                controller.info = info
            }
        }else if segue.identifier == "MPartners Native" {
            if let controller = segue.destination as? EBMPartnersNativeAdViewController {
                controller.info = info
            }
        }else if segue.identifier == "MPartners Offerwall" {
            if let controller = segue.destination as? EBMPartnersOfferwallViewController {
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
            case .Interstitial:
                performSegue(withIdentifier: "Interstitial", sender: indexPath)
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
                performSegue(withIdentifier: "Native Video", sender: indexPath)
            case .MediationBanner:
                performSegue(withIdentifier: "Mediation Banner", sender: indexPath)
            case .MediationInterstitial:
                performSegue(withIdentifier: "Mediation Interstitial", sender: indexPath)
            case .MediationInterstitialVideo:
                performSegue(withIdentifier: "Mediation Interstitial Video", sender: indexPath)
            case .MediationNative:
                performSegue(withIdentifier: "Mediation Native", sender: indexPath)
            case .MediationNativeVideo:
                performSegue(withIdentifier: "Mediation Native Video", sender: indexPath)
            case .MediationBizboard:
                performSegue(withIdentifier: "MediationBizboardView", sender: indexPath)
            case .AdTag:
                performSegue(withIdentifier: "AdTag", sender: indexPath)
            case .MPartnersBanner:
                performSegue(withIdentifier: "MPartners Banner", sender: indexPath)
            case .MPartnersNative:
                performSegue(withIdentifier: "MPartners Native", sender: indexPath)
            case .MPartnersOfferwall:
                performSegue(withIdentifier: "MPartners Offerwall", sender: indexPath)
        }
    }
}
