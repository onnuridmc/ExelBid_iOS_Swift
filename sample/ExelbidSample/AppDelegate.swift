//
//  AppDelegate.swift
//  com.zionbi.ExelbidSample-Swift
//
//  Created by HeroK on 2021/01/12.
//

import UIKit
import StoreKit
import AppTrackingTransparency
import ExelBidSDK
import GoogleMobileAds
import FBAudienceNetwork
import IASDKCore
import PAGAdSDK
import AppLovinSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // SKAdNetwork
        if #available(iOS 11.3, *) {
            SKAdNetwork.registerAppForAdNetworkAttribution()
        }
        
        // AdMob
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // FaceBook
        FBAudienceNetworkAds.initialize(with: nil, completionHandler: nil)
        FBAdSettings.setAdvertiserTrackingEnabled(true)
        
        // Digital Turbine
        IASDKCore.sharedInstance().initWithAppID("")

        // Pangle
        let pagConfig = PAGConfig.share()
        pagConfig.appID = "8352814"
        pagConfig.appLogoImage = UIImage(named: "AppIcon")
        
        #if DEBUG
        pagConfig.debugLog = true
        #endif
        
        PAGSdk.start(with: pagConfig, completionHandler: nil)
        
        // Applovin

        // Create the initialization configuration
//        let initConfig = ALSdkInitializationConfiguration(sdkKey: "«SDK-KEY»") { builder in
//
//            builder.mediationProvider = ALMediationProviderMAX
//
//            builder.userSegment = ALUserSegment(name: "«USER-SEGMENT»")
//
//            builder.settings.userIdentifier = "«USER-ID»"
//            builder.settings.setExtraParameterForKey("uid2_token", value: "«TOKEN-VALUE»")
//
//            // Note: you may also set these values in your Info.plist
//            builder.settings.termsAndPrivacyPolicyFlowSettings.isEnabled = true
//            builder.settings.termsAndPrivacyPolicyFlowSettings.termsOfServiceURL = URL(string: "https://www.motiv-i.com/terms")
//            builder.settings.termsAndPrivacyPolicyFlowSettings.privacyPolicyURL = URL(string:"https://www.motiv-i.com/privacy")
//        }
//
//        ALSdk.shared().initialize(with: initConfig) { sdkConfig in
//            // Start loading ads
//        }
    
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
     
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // 사용자로부터 개인정보 보호에 관한 권한을 요청해야 합니다.
        // 앱 설치 후 한번만 요청되며, 사용자가 권한에 대해 응답 후 더 이상 사용자에게 권한 요청을 하지 않습니다.
        // 광고식별자를 수집하지 못하는 경우 광고 요청에 대해 응답이 실패할 수 있습니다.
        if #available(iOS 14.0, *) {
            ATTrackingManager.requestTrackingAuthorization { _ in }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

