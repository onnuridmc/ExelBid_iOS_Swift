//
//  EBInformationViewController.swift
//  ExelbidSample
//

import Foundation
import UIKit
import AppTrackingTransparency
import AdSupport
import DeviceKit

class EBInformationViewController : UIViewController {
    @IBOutlet var txtDevice: UILabel!
    @IBOutlet var txtOsVersion: UILabel!
    @IBOutlet var txtIdfa: UILabel!
    @IBOutlet var txtAttStatus: UILabel!
    @IBOutlet var txtIp: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtDevice.text = "\(Device.current), \(deviceModel())"
        
        txtOsVersion.text = "\(UIDevice.current.systemVersion)"
        
        checkATT()
        
        getPublicIPAddress() { ip in
            DispatchQueue.main.async {
                self.txtIp.text = ip
            }
        }
        
        // 앱이 포그라운드로 돌아올 때 상태 확인
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForegroundNotification),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func copyTapped(_ sender: UIButton) {
        var text: String?
        switch sender.tag {
            case 1:
                text = self.txtDevice.text
            case 2:
                text = self.txtOsVersion.text
            case 3:
                text = self.txtIdfa.text
            case 4:
                text = self.txtAttStatus.text
            case 5:
                text = self.txtIp.text
            default:
                text = nil
        }
        
        if let text = text, !text.isEmpty {
            UIPasteboard.general.string = text
            "Copy".alert(self)
        }
    }
    
    @IBAction func openSettings(_ sender: UIButton) {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc
    func willEnterForegroundNotification() {
        checkATT()
    }
    
    func checkATT() {
        txtAttStatus.text = attStatus()
        txtIdfa.text = ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    func deviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }
    
    func attStatus() -> String {
        var status: String = "";
        if #available(iOS 14.0, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
                case .notDetermined:
                    status = "Not Determined"
                case .restricted:
                    status = "Restricted"
                case .denied:
                    status = "Denied"
                case .authorized:
                    status = "Authorized"
                default:
                    status = ""
            }
        } else {
            status = ASIdentifierManager.shared().isAdvertisingTrackingEnabled ? "Authorized" : "Denied"
        }
        
        return status
    }
    
    func getPublicIPAddress(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://ifconfig.me/ip") else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil, let data = data else {
                completion(nil)
                return
            }

            let publicIP = String(data: data, encoding: .utf8)
            completion(publicIP?.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        task.resume()
    }
}
