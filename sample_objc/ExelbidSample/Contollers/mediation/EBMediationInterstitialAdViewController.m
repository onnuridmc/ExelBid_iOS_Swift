//
//  EBMediationInterstitialAdViewController.m
//  ExelbidSample
//
//  Created by Jaeuk Jeong on 2/27/24.
//  Copyright © 2024 Zionbi. All rights reserved.
//

#import "EBMediationInterstitialAdViewController.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <ExelBidSDK/ExelBidSDK-Swift.h>

// AdMob
#import <GoogleMobileAds/GoogleMobileAds.h>

// Facebook
#import <FBAudienceNetwork/FBAudienceNetwork.h>

// Digital Turbine
#import <IASDKCore/IASDKCore.h>

// Pangle
#import <PAGAdSDK/PAGAdSDK.h>

// TargetPick
#import <LibADPlus/LibADPlus-Swift.h>


@interface EBMediationInterstitialAdViewController ()<EBInterstitialAdControllerDelegate, GADFullScreenContentDelegate, FBInterstitialAdDelegate, IAUnitDelegate, PAGLInterstitialAdDelegate>

@property (nonatomic, strong) EBMediationManager *mediationManager;

@property (nonatomic, strong) EBInterstitialAdController *ebInterstitialAd;

// AdMob
@property (nonatomic, strong) GADInterstitialAd *gaInterstitial;

// Facebook
@property (nonatomic, strong) FBInterstitialAd *fanInterstitialAd;

// Digital Turbine
@property (nonatomic, strong) IAAdSpot *dtAdSpot;
@property (nonatomic, strong) IAFullscreenUnitController *dtFullUnitController;

// Pangle
@property (nonatomic, strong) PAGLInterstitialAd *pagInterstitialAd;

// TargetPick
@property (nonatomic, assign) NSInteger tpPublisherId;
@property (nonatomic, assign) NSInteger tpMediaId;

@end

@implementation EBMediationInterstitialAdViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _tpPublisherId = 1761;
        _tpMediaId = 33372;
    }
    return self;
}

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
                                EBMediationTypes.targetpick,
                                nil];
    
    // ExelBid 미디에이션 초기화
    self.mediationManager = [[EBMediationManager alloc] initWithAdUnitId:self.keywordsTextField.text mediationTypes:mediationTypes];

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
    // 순차적으로 미디에이션 호출
    [self loadMediation];
}

// 미디에이션 목록 순차 처리
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
        } else if ([mediation.id isEqualToString:EBMediationTypes.facebook]) {
            [self loadFan:mediation];
        } else if ([mediation.id isEqualToString:EBMediationTypes.digitalturbine]) {
            [self loadDT:mediation];
        } else if ([mediation.id isEqualToString:EBMediationTypes.pangle]) {
            [self loadPangle:mediation];
        } else if ([mediation.id isEqualToString:EBMediationTypes.targetpick]) {
            [self loadTargetPick:mediation];
        } else {
            [self loadMediation];
        }
    }
}

// 미디에이션 목록이 비어있음. 광고 없음 처리.
- (void)emptyMediation
{
    NSLog(@"Mediation Empty");
}

#pragma mark - 미디에이션 광고 호출

// Exelbid 광고 호출
- (void)loadExelBid:(EBMediationWrapper *)mediation
{
    
    self.ebInterstitialAd = [[EBInterstitialAdController alloc] initWithAdUnitId:mediation.unit_id];
    self.ebInterstitialAd.delegate = self;

    [self.ebInterstitialAd setYob:@"1976"];
    [self.ebInterstitialAd setGender:@"M"];
    [self.ebInterstitialAd setTesting:YES];
    
    // 전면 광고 요청
    [self.ebInterstitialAd loadAd];
}

// AdMob 광고 호출
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

// Fan 광고 호출
- (void)loadFan:(EBMediationWrapper *)mediation
{
    self.fanInterstitialAd = [[FBInterstitialAd alloc] initWithPlacementID:mediation.unit_id];
    self.fanInterstitialAd.delegate = self;
    
    // 전면 광고 요청
    [self.fanInterstitialAd loadAd];
    
    // 전면 광고 노출
    if (self.fanInterstitialAd && self.fanInterstitialAd.isAdValid) {
        [self.fanInterstitialAd showAdFromRootViewController:self];
    }
}

// Digital Turbine 광고 호출
- (void)loadDT:(EBMediationWrapper *)mediation
{
    IASDKCore.sharedInstance.userData = [IAUserData build:^(id<IAUserDataBuilder>  _Nonnull builder) {
        builder.age = 30;
        builder.gender = IAUserGenderTypeMale;
        builder.zipCode = @"90210";
    }];
    
    IASDKCore.sharedInstance.keywords = @"swimming, music";
    
    IAAdRequest *adRequest = [IAAdRequest build:^(id<IAAdRequestBuilder>  _Nonnull builder) {
        builder.useSecureConnections = NO;
        builder.spotID = @"";
        builder.timeout = 5;
    }];

    self.dtFullUnitController = [IAFullscreenUnitController build:^(id<IAFullscreenUnitControllerBuilder> _Nonnull builder) {
        builder.unitDelegate = self;
    }];
    
    self.dtAdSpot = [IAAdSpot build:^(id<IAAdSpotBuilder>  _Nonnull builder) {
        builder.adRequest = adRequest;
        [builder addSupportedUnitController:self.dtFullUnitController];
    }];
    
    __weak typeof(self) weakSelf = self;
    [self.dtAdSpot fetchAdWithCompletion:^(IAAdSpot * adSpot, IAAdModel * adModel, NSError * error) {
        if (error) {
            NSLog(@"Failed to get an ad: %@\n", error);
        } else {
            if (adSpot.activeUnitController == weakSelf.dtFullUnitController) {
                [weakSelf.dtFullUnitController showAdAnimated:YES completion:nil];
            }
        }
    }];
}

// Pangle 광고 호출
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


// TargetPick 광고 호출
- (void)loadTargetPick:(EBMediationWrapper *)mediation
{
    ADMZInterstitialModel *model = [[ADMZInterstitialModel alloc]
                                    initWithPublisherID:self.tpPublisherId
                                    withMediaID:self.tpMediaId
                                    withSectionID:[mediation.unit_id integerValue]
                                    withKeywordParameter:@"KeywordTargeting"
                                    withOtherParameter:@"BannerAdditionalParameters"
                                    withMediaAgeLevel:ADMZUserAgeLevelTypeOver13Age
                                    withAppID:[[NSBundle mainBundle] bundleIdentifier]
                                    withAppName:@"ExelbidDemo(iOS)"
                                    withStoreURL:@"StoreURL"
                                    withSMS:YES
                                    withTel:YES
                                    withCalendar:YES
                                    withStorePicture:YES
                                    withInlineVideo:YES
                                    withPopupType:ADMZInterstitialTypeFullSize];
    
    [ADMZInterstitialLoader presentAdFromViewController:self withModel:model
                                     withSuccessHandler:^(enum ADMZResponseStatusType type) {
        NSLog(@"InterstitialDidEventSuccess");
    }
                                      withFailedHandler:^(enum ADMZResponseStatusType type) {
        NSLog(@"InterstitialDidEventFail");
    }
                                  withOtherEventHandler:^(enum ADMZResponseStatusType type) {
        NSLog(@"InterstitialDidEventOther");
    }];
}

#pragma mark - EBInterstitialAdControllerDelegate

- (void)interstitialDidLoadAd:(EBInterstitialAdController *)interstitial
{
    // 전면 광고 노출
    [self.ebInterstitialAd showFromViewController:self];
}

- (void)interstitialDidFailToLoadAd:(EBInterstitialAdController *)interstitial
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

#pragma mark - FBInterstitialAdDelegate
- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd
{
    if (interstitialAd && interstitialAd.isAdValid) {
        [interstitialAd showAdFromRootViewController:self];
    }
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    NSLog(@"Fan - didFailWithError - error : %@", [error localizedDescription]);
    [self loadMediation];
}

#pragma mark - IAUnitDelegate

- (UIViewController * )IAParentViewControllerForUnitController:(IAUnitController *)unitController
{
    return self;
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

