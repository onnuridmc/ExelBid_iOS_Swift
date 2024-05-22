//
//  EBMediationInterstitialVideoAdViewController.m
//  ExelbidSample
//
//  Created by Jaeuk Jeong on 2/27/24.
//  Copyright © 2024 Zionbi. All rights reserved.
//

#import "EBMediationInterstitialVideoAdViewController.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <ExelBidSDK/ExelBidSDK-Swift.h>

// AdMob
#import <GoogleMobileAds/GoogleMobileAds.h>

// Pangle
#import <PAGAdSDK/PAGAdSDK.h>


@interface EBMediationInterstitialVideoAdViewController ()<EBVideoDelegate, GADFullScreenContentDelegate, PAGLInterstitialAdDelegate>

@property (nonatomic, strong) EBMediationManager *mediationManager;

// AdMob
@property (nonatomic, strong) GADInterstitialAd *gaInterstitial;

// Pangle
@property (nonatomic, strong) PAGLInterstitialAd *pagInterstitialAd;

@end

@implementation EBMediationInterstitialVideoAdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showAdButton.hidden = YES;
    self.keywordsTextField.text = self.info.ID;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)didTapLoadButton:(id)sender
{
    [self.keywordsTextField endEditing:YES];
    
    self.showAdButton.hidden = YES;
    
    // ExelBid 미디에이션 목록 설정
    NSArray * mediationTypes = [[NSArray alloc] initWithObjects:
                       EBMediationTypes.exelbid,
                       EBMediationTypes.admob,
                       EBMediationTypes.pangle,
                       nil];
    
    // ExelBid 미디에이션 초기화
    self.mediationManager = [[EBMediationManager alloc] initWithAdUnitId:self.keywordsTextField.text mediationTypes:mediationTypes];
    
    // ExelBid 미디에이션 테스트 설정
    self.mediationManager.testing = YES;

    // ExelBid 미디에이션 요청 및 콜백
    [self.mediationManager requestMediationWithHandler:^(EBMediationManager *manager, NSError *error) {
        if (error) {
            NSLog(@"================> %@", error);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.showAdButton.hidden = NO;
            });
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.spinner.hidden = YES;
            self.loadAdButton.enabled = YES;
        });
    }];
}

- (IBAction)didTapShowButton:(id)sender
{
    [self loadMediation];
}

- (void)loadMediation
{
    if (self.mediationManager != nil) {
        // ExelBid 미디에이션 순서대로 가져오기 (더이상 없으면 nil)
        EBMediationWrapper *mediation = [self.mediationManager next];
        
        if (mediation == nil) {
            [self emptyMediation];
        } else if ([mediation.id isEqualToString:EBMediationTypes.exelbid]) {
            [self loadExelBid:mediation];
        } else if ([mediation.id isEqualToString:EBMediationTypes.admob]) {
            [self loadAdMob:mediation];
        } else if ([mediation.id isEqualToString:EBMediationTypes.pangle]) {
            [self loadPangle:mediation];
        } else {
            [self loadMediation];
        }
    }
}

- (void)emptyMediation
{
    NSLog(@"Mediation Empty");
    // 미디에이션 목록이 비어있음. 광고 없음 처리.
}

- (void)loadExelBid:(EBMediationWrapper *)mediation
{
    [EBVideoManager initFullVideoWithIdentifier:mediation.unit_id];
    [EBVideoManager testing:YES];
    [EBVideoManager yob:@"1990"];
    [EBVideoManager gender:@"M"];
    
    [EBVideoManager startWithCompletionHandler:^(EBVideoAdRequest *request, NSError *error) {
        if (error) {
            [self loadMediation];
        } else {
            [EBVideoManager presentAdWithController:self delegate:self];
        }
    }];
}

- (void)loadAdMob:(EBMediationWrapper *)mediation
{
    // 전면 광고 요청
    [GADInterstitialAd loadWithAdUnitID:mediation.unit_id request:[GADRequest request] completionHandler:
     ^(GADInterstitialAd *ad, NSError *error) {
        if (error) {
            NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
            return;
        }
        self.gaInterstitial = ad;

        // 전면 광고 노출
        if (self.gaInterstitial) {
            self.gaInterstitial.fullScreenContentDelegate = self;
            [self.gaInterstitial presentFromRootViewController:self];
        }
      }];
}

- (void)loadPangle:(EBMediationWrapper *)mediation
{
    PAGInterstitialRequest *request = [PAGInterstitialRequest request];
    
    [PAGLInterstitialAd loadAdWithSlotID:mediation.unit_id request:request completionHandler:^(PAGLInterstitialAd * interstitialAd, NSError * error) {
            if (error) {
                NSLog(@"interstitial ad load fail : %@",error);
                return;
            }
            self.pagInterstitialAd = interstitialAd;
            self.pagInterstitialAd.delegate = self;
        
            if (self.pagInterstitialAd) {
                [self.pagInterstitialAd presentFromRootViewController:self];
            }
     }];
}

#pragma mark - EBVideoDelegate

- (void)videoAdDidLoadWithAdUnitID:(NSString * _Nonnull)adUnitID
{
    
}

- (void)videoAdDidFailToLoadWithAdUnitID:(NSString * _Nonnull)adUnitID error:(NSError * _Nonnull)error
{
    [self loadMediation];
}

#pragma mark - GADFullScreenContentDelegate

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
    NSLog(@"AdMob - didFailToPresentFullScreenContentWithError - error : %@", error.localizedDescription);
    [self loadMediation];
}

- (void)adWillPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    
}

- (void)adWillDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad
{
    
}

#pragma mark - PAGBannerAdDelegate

- (void)adDidShow:(PAGBannerAd *)ad {
    
}

- (void)adDidClick:(PAGBannerAd *)ad {
    
}

- (void)adDidDismiss:(PAGBannerAd *)ad {
    
}

- (void)adDidShowFail:(PAGBannerAd *)ad error:(NSError *)error {
    
}

@end

