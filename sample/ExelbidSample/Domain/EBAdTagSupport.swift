//
//  AdSupportManager.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by Jaeuk Jeong on 2023/07/26.
//

import Foundation
import UIKit
import AdSupport
import AppTrackingTransparency
import CoreLocation
import CoreTelephony

class EBAdTagSupport : NSObject {
    struct AdTargetInfo : Codable {
        var idfa: String?
        
        var coppa: Bool = true
        
        var yob: String?
        var gender: String?
        var segment: [String : String]?
        
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
        var device_make: String? = "APPLE"
        
        // Location
        var geo_lat: Double?
        var geo_lon: Double?
        
        // 데이터 전달을 위해 JSON String 형태로 변환
        func jsonString() -> String {
            guard let josnData = try? JSONEncoder().encode(self) else {
                return ""
            }
            
            return String(data: josnData, encoding: .utf8)!
        }
    }
    
    private var locationManager = CLLocationManager()
    private var lastLocation: CLLocation?

    static var shared = EBAdTagSupport()
    
    var adTargetInfo = AdTargetInfo()
    
    /** Children’s Online Privacy Protection Act (COPPA) */
    var coppa: Bool {
        get {
            return adTargetInfo.coppa
        }
        
        set {
            adTargetInfo.coppa = newValue
        }
    }

    // AdTarget.yob get/set
    var yob: String? {
        get {
            return adTargetInfo.yob
        }
        
        set {
            adTargetInfo.yob = newValue
        }
    }
    
    // AdTarget.gender get/set
    var gender: String? {
        get {
            return adTargetInfo.gender
        }
        
        set {
            adTargetInfo.gender = newValue
        }
    }
    
    // AdTarget.segment get/set
    var segment: [String : String]? {
        get {
            return adTargetInfo.segment
        }
        
        set {
            adTargetInfo.segment = newValue
        }
    }

    private override init() {
        super.init()
        
        // 광고식별자 (필수)
        self.adTargetInfo.idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        // 위치 사용
        self.locationStart()
        
        // 통신사 정보
        self.getCarrierInfo()

        // 앱 버전
        self.adTargetInfo.app_version = self.getAppVersion()

        // OS Version
        self.adTargetInfo.os_version = UIDevice.current.systemVersion

        // Device Model
        self.adTargetInfo.device_model = self.getDeviceModel()
    }
}

private extension EBAdTagSupport {
    func getCarrierInfo() {
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
        
        if let carrier = carrier {
            self.adTargetInfo.iso_country_code = carrier.isoCountryCode ?? ""
            self.adTargetInfo.mobile_country_code = carrier.mobileCountryCode
            self.adTargetInfo.mobile_network_code = carrier.mobileNetworkCode
            self.adTargetInfo.carrier_name = carrier.carrierName?.replacingOccurrences(of: " ", with: "")
        }
    }
    
    func getAppVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "1.0.0"
        }
        
        return version
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
    
    func locationStart() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.pausesLocationUpdatesAutomatically = true

        // 백그라운드 모드 설정이 필요
//        locationManager.allowsBackgroundLocationUpdates = true
        
        locationManager.startUpdatingLocation()
    }
}

extension EBAdTagSupport {
    func requestTrackingAuthorization(handler:@escaping (_ uuid:String?) -> Void){
        if #available(iOS 14.0, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                    case .authorized:
                        // 허용
                        let uuid: String = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                        handler(uuid)
                        self.adTargetInfo.idfa = uuid
                    case .denied, .restricted:
                        // 거절, 활성 제한됨
                        handler(nil)
                    case .notDetermined:
                        // 결정 안됨
                        handler(nil)
                    default:
                        handler(nil)
                }
            }
        } else {
            let uuid: String = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            handler(uuid)
            self.adTargetInfo.idfa = uuid
        }
    }
    
    func requestLocation () {
        if #available(iOS 14.0, *) {
            changeAuthorization(status: locationManager.authorizationStatus)
        } else {
            changeAuthorization(status: CLLocationManager.authorizationStatus())
        }
    }
}

extension EBAdTagSupport: CLLocationManagerDelegate {
    
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
            self.adTargetInfo.geo_lat = location.coordinate.latitude
            self.adTargetInfo.geo_lon = location.coordinate.longitude
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager didFailWithError - \(error.localizedDescription)")
    }
}

