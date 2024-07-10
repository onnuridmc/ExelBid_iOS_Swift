//
//  AppDelegate.m
//  ExelbidSample
//
//  Created by HeroK on 2016. 10. 24..
//  Copyright © 2016년 Zionbi. All rights reserved.
//

#import "AppDelegate.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <ExelBidSDK/ExelBidSDK-Swift.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import <IASDKCore/IASDKCore.h>
#import <PAGAdSDK/PAGAdSDK.h>
//#import <LibADPlus/LibADPlus-Swift.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // AdMob
    [GADMobileAds.sharedInstance startWithCompletionHandler:nil];
    
//    // Facebook
//    [FBAudienceNetworkAds initializeWithSettings:nil completionHandler:nil];
//    [FBAdSettings setAdvertiserTrackingEnabled:YES];
    
    // Digital Turbine
    [IASDKCore.sharedInstance initWithAppID:@""
                            completionBlock:^(BOOL success, NSError * _Nullable error) {}
                            completionQueue:nil];
    
    // Pangle
    PAGConfig *config = [PAGConfig shareConfig];
    config.appID = @"8352814";
    //If you need to display open ads, you should set the app logo image
    config.appLogoImage = [UIImage imageNamed:@"AppIcon"];
    
    #if DEBUG
        config.debugLog = YES;
    #endif
    
    [PAGSdk startWithConfig:config completionHandler:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            //load ad data
        }
    }];
    
    // MezzoMedia
//    [LibADPlusStore start];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // 사용자로부터 개인정보 보호에 관한 권한을 요청해야 합니다.
    // 앱 설치 후 한번만 요청되며, 사용자가 권한에 대해 응답 후 더 이상 사용자에게 권한 요청을 하지 않습니다.
    // 광고식별자를 수집하지 못하는 경우 광고 요청에 대해 응답이 실패할 수 있습니다.
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            
        }];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
