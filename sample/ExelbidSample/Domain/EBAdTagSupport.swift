//
//  AdSupportManager.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by Jaeuk Jeong on 2023/07/26.
//

import Foundation
import UIKit
import WebKit
import AdSupport
import CoreLocation
import CoreTelephony

struct EBAdTagModel : Encodable {

    var idfa: String?

    var coppa: Bool?
    var yob: String?
    var gender: String?
    var segment: [String : String]?
    
    // 앱 버전
    var app_version: String?
    
    // Carrier
    var iso_country_code: String?
    var mobile_country_code: String?
    var mobile_network_code: String?
    var carrier_name: String?
    
    // Device
    var country_code: String?
    var os_version: String?
    var device_model: String?
    var device_make: String = "APPLE"
    
    // Location
    var geo_lat: Double?
    var geo_lon: Double?
}

class EBAdTagSupport : NSObject, CLLocationManagerDelegate{
    
    private var locationManager = CLLocationManager()
    private var lastLocation: CLLocation?

    static var shared = EBAdTagSupport()
    
    var coppa: Bool?
    var yob: String?
    var gender: String?
    var segment: [String : String]?
    
    var params: String {
        var adTagModel = EBAdTagModel()
        
        adTagModel.idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        adTagModel.coppa = self.coppa ?? true
        adTagModel.yob = self.yob
        adTagModel.gender = self.gender
        adTagModel.segment = self.segment
        
        adTagModel.app_version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        
        adTagModel.os_version = UIDevice.current.systemVersion
        adTagModel.device_model = getDeviceModel()
        adTagModel.device_make = "APPLE"
        
        if let lastLocation = self.lastLocation {
            adTagModel.geo_lat = lastLocation.coordinate.latitude
            adTagModel.geo_lon = lastLocation.coordinate.longitude
        }
        
        if let carrier = self.getCarrierInfo() {
            adTagModel.iso_country_code = carrier.isoCountryCode ?? ""
            adTagModel.mobile_country_code = carrier.mobileCountryCode
            adTagModel.mobile_network_code = carrier.mobileNetworkCode
            adTagModel.carrier_name = carrier.carrierName?.replacingOccurrences(of: " ", with: "")
        }
        
        guard let jsonData = try? JSONEncoder().encode(adTagModel) else {
            return "{}"
        }
        
        return String(data: jsonData, encoding: .utf8)!
    }
    
    override init() {
        super.init()
        
        // 위치 사용
        self.locationStart()
    }
    
    func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let model = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return model
    }
    
    func getCarrierInfo() -> CTCarrier? {
        var carrier: CTCarrier?
        if #available(iOS 12.0, *) {
            if let carriers = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders {
                for (_, value) in carriers {
                    if value.isoCountryCode != nil {
                        carrier = value
                    }
                }
            }
        } else{
            carrier = CTTelephonyNetworkInfo().subscriberCellularProvider
        }
    
        return carrier
    }
    
    func locationStart() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.pausesLocationUpdatesAutomatically = true
        
        locationManager.startUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate
    
    // 위치 사용 권한에 따라 값 조회
    func changeAuthorization(status: CLAuthorizationStatus) {
        switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                // 앱 사용중에만, 항상
                locationManager.startUpdatingLocation()
            case .notDetermined:
                // 결정 안됨
                // 사용자에게 권한 요청
                locationManager.requestWhenInUseAuthorization()
            case .denied, .restricted:
                // 거절, 활성 제한됨
                locationManager.stopUpdatingLocation()
            default:
                break
        }
    }

    // iOS 14.0+
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            changeAuthorization(status: manager.authorizationStatus)
        }
    }

    // Deprecated iOS 14.0
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        changeAuthorization(status: status)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            if let lastLocation = lastLocation {
                if location.horizontalAccuracy < 1 || location.timestamp.timeIntervalSince(lastLocation.timestamp) < 0 {
                    continue;
                }
            }

            self.lastLocation = location
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager didFailWithError - \(error.localizedDescription)")
    }
}
