//
//  EBMediationBannerAdViewController.m
//
//  Created by Jaeuk Jeong on 2023/02/09.
//

#import "EBMediationBannerAdViewController.h"
#import <ExelBidSDK/ExelBidSDK-Swift.h>

// AdMob
#import <GoogleMobileAds/GoogleMobileAds.h>

// Facebook
#import <FBAudienceNetwork/FBAudienceNetwork.h>

// AdFit
#import <AdFitSDK/AdFitSDK-Swift.h>

// Digital Turbine
#import <IASDKCore/IASDKCore.h>

// Pangle
#import <PAGAdSDK/PAGAdSDK.h>

@interface EBMediationBannerAdViewController ()<UITextFieldDelegate, EBAdViewDelegate, GADBannerViewDelegate, FBAdViewDelegate, AdFitBannerAdViewDelegate, IAUnitDelegate, PAGBannerAdDelegate>

@property (nonatomic, strong) EBMediationManager *mediationManager;
@property (nonatomic, strong) EBAdView *ebAdView;

// AdMob
@property (nonatomic, strong) GADBannerView *gaBannerView;

// Facebook
@property (nonatomic, strong) FBAdView *fanAdView;

// AdFit
@property (nonatomic, strong) AdFitBannerAdView *adfitBannerAdView;

// Digital Turbine
@property (nonatomic, strong) IAAdSpot *dtAdSpot;
@property (nonatomic, strong) IAViewUnitController *dtUnitController;

// Pangle
@property (nonatomic, strong) PAGBannerAd *pagBannerAd;


@end

@implementation EBMediationBannerAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showAdButton.hidden = YES;
    self.keywordsTextField.text = self.info.ID;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)didTapLoadButton:(id)sender
{
    [self.keywordsTextField endEditing:YES];
    
    self.spinner.hidden = NO;
    self.showAdButton.hidden = YES;
    self.loadAdButton.enabled = NO;
    self.failLabel.hidden = YES;
    
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
    // 순차적으로 미디에이션 호출
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
        } else if ([mediation.id isEqualToString:EBMediationTypes.facebook]) {
            [self loadFan:mediation];
        } else if ([mediation.id isEqualToString:EBMediationTypes.adfit]) {
            [self loadAdFit:mediation];
        } else if ([mediation.id isEqualToString:EBMediationTypes.digitalturbine]) {
            [self loadDT:mediation];
        } else if ([mediation.id isEqualToString:EBMediationTypes.pangle]) {
            [self loadPangle:mediation];
        } else {
            [self loadMediation];
        }
    }
}

- (void)clearAd {
    // adViewContainer 내 추가된 서브뷰 제거
    [[self.adViewContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)emptyMediation
{
    NSLog(@"Mediation Empty");
    // 미디에이션 리셋 또는 광고 없음 처리
//     [self.mediationManager reset];
//     [self loadMediation];
}


- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

// iOS7
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.ebAdView rotateToOrientation:toInterfaceOrientation];
}

- (void)setAdViewAutolayoutConstraint:(UIView *)target mine:(UIView *)_mine
{
    [target addSubview:_mine];
    
    [_mine setTranslatesAutoresizingMaskIntoConstraints:NO];
    [target addConstraint:[NSLayoutConstraint
                           constraintWithItem:_mine
                           attribute:NSLayoutAttributeTop
                           relatedBy:NSLayoutRelationEqual
                           toItem:target
                           attribute:NSLayoutAttributeTop
                           multiplier:1
                           constant:0]];
    
    [target addConstraint:[NSLayoutConstraint
                           constraintWithItem:_mine
                           attribute:NSLayoutAttributeBottom
                           relatedBy:NSLayoutRelationEqual
                           toItem:target
                           attribute:NSLayoutAttributeBottom
                           multiplier:1
                           constant:0]];
    
    [target addConstraint:[NSLayoutConstraint
                           constraintWithItem:_mine
                           attribute:NSLayoutAttributeLeading
                           relatedBy:NSLayoutRelationEqual
                           toItem:target
                           attribute:NSLayoutAttributeLeading
                           multiplier:1
                           constant:0]];
    
    [target addConstraint:[NSLayoutConstraint
                           constraintWithItem:_mine
                           attribute:NSLayoutAttributeTrailing
                           relatedBy:NSLayoutRelationEqual
                           toItem:target
                           attribute:NSLayoutAttributeTrailing
                           multiplier:1
                           constant:0]];
    
    CGFloat _height = 0.0f;
    _height = 50.0f;
    
    [target addConstraint:[NSLayoutConstraint
                           constraintWithItem:_mine
                           attribute:NSLayoutAttributeHeight
                           relatedBy:NSLayoutRelationEqual
                           toItem:nil
                           attribute:NSLayoutAttributeNotAnAttribute
                           multiplier:1
                           constant:_height]];
    
    [_mine setNeedsUpdateConstraints];
}

- (void)loadExelBid:(EBMediationWrapper *)mediation
{
    [self clearAd];
    
    self.ebAdView = [[EBAdView alloc] initWithAdUnitId:mediation.unit_id size:self.adViewContainer.bounds.size];
    self.ebAdView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.ebAdView.delegate = self;
    [self.ebAdView setYob:@"1976"];
    [self.ebAdView setGender:@"M"];
    [self.ebAdView setFullWebView:YES];
    [self.ebAdView setTesting:YES];
    
    [_adViewContainer addSubview:self.ebAdView];
    
    [self setAdViewAutolayoutConstraint:self.adViewContainer mine:self.ebAdView];
    
    [self.ebAdView loadAd];
}

- (void)loadAdMob:(EBMediationWrapper *)mediation
{
    [self clearAd];
    
    CGRect frame = UIEdgeInsetsInsetRect(self.adViewContainer.frame, self.adViewContainer.safeAreaInsets);
    CGFloat viewWidth = frame.size.width;

    GADAdSize adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth);
    
    self.gaBannerView = [[GADBannerView alloc] initWithAdSize:adaptiveSize];
    self.gaBannerView.delegate = self;
    self.gaBannerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.gaBannerView.adUnitID = mediation.unit_id;
    self.gaBannerView.rootViewController = self;

    [self.gaBannerView loadRequest:[GADRequest request]];
}

- (void)loadFan:(EBMediationWrapper *)mediation
{
    [self clearAd];

    self.fanAdView = [[FBAdView alloc] initWithPlacementID:mediation.unit_id adSize:kFBAdSizeHeight50Banner rootViewController:self];
    self.fanAdView.frame = CGRectMake(0, 0, 320, 250);
    self.fanAdView.delegate = self;
    [self.fanAdView loadAd];
}

- (void)loadAdFit:(EBMediationWrapper *)mediation
{
    [self clearAd];
    
    self.adfitBannerAdView = [[AdFitBannerAdView alloc] initWithClientId:mediation.unit_id adUnitSize:@"320x50"];
    self.adfitBannerAdView.frame = CGRectMake(0.f, 0.f, _adViewContainer.bounds.size.width, _adViewContainer.bounds.size.height);
    self.adfitBannerAdView.rootViewController = self;

    [_adViewContainer addSubview:self.adfitBannerAdView];
    
    [self.adfitBannerAdView loadAd];
}

- (void)loadDT:(EBMediationWrapper *)mediation
{
    [self clearAd];
    
    IASDKCore.sharedInstance.userData = [IAUserData build:^(id<IAUserDataBuilder>  _Nonnull builder) {
        builder.age = 30;
        builder.gender = IAUserGenderTypeMale;
        builder.zipCode = @"90210";
    }];
    IASDKCore.sharedInstance.keywords = @"swimming, music";
    
    IAAdRequest *adRequest = [IAAdRequest build:^(id<IAAdRequestBuilder>  _Nonnull builder) {
        builder.useSecureConnections = NO;
        builder.spotID = mediation.unit_id;
        builder.timeout = 5;
    }];
    
    self.dtUnitController =
    [IAViewUnitController build:^(id<IAViewUnitControllerBuilder>  _Nonnull builder) {
        builder.unitDelegate = self;
    }];
    
    self.dtAdSpot = [IAAdSpot build:^(id<IAAdSpotBuilder>  _Nonnull builder) {
        builder.adRequest = adRequest;
        [builder addSupportedUnitController:self.dtUnitController];
    }];
    
    __weak typeof(self) weakSelf = self;
    [self.dtAdSpot fetchAdWithCompletion:^(IAAdSpot * adSpot, IAAdModel * adModel, NSError * error) {
        if (error) {
            NSLog(@"Failed to get an ad: %@\n", error);
        } else {
            if (adSpot.activeUnitController == weakSelf.dtUnitController) {
                [weakSelf.dtUnitController showAdInParentView:weakSelf.adViewContainer];
            }
        }
    }];
}

- (void)loadPangle:(EBMediationWrapper *)mediation
{
    [self clearAd];
    
    PAGBannerAdSize size = kPAGBannerSize320x50;
    [PAGBannerAd loadAdWithSlotID:mediation.unit_id request:[PAGBannerRequest requestWithBannerSize:size] completionHandler:^(PAGBannerAd * bannerAd, NSError * error) {
        if (error) {
            NSLog(@"banner ad load fail : %@",error);
            [self loadMediation];
            return;
        }

        self.pagBannerAd = bannerAd;
        self.pagBannerAd.delegate = self;
        self.pagBannerAd.rootViewController = self;
        
        // get the bannerView
        UIView *bannerView = self.pagBannerAd.bannerView;
        
        bannerView.frame = CGRectMake((self.adViewContainer.frame.size.width-size.size.width)/2.0, self.adViewContainer.frame.size.height-size.size.height, size.size.width, size.size.height);
        
        [self.adViewContainer addSubview:bannerView];
    }];
}

#pragma mark - EBAdViewDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

- (void)adViewDidLoadAd:(EBAdView *)view
{
    _spinner.hidden = YES;
    NSLog(@"ExelBid - adViewDidLoadAd");
}

- (void)adViewDidFailToLoadAd:(EBAdView *)view
{
    _spinner.hidden = YES;
    [self loadMediation];
}

#pragma mark - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView
{
    [self.adViewContainer addSubview:bannerView];
    
    [self.adViewContainer addConstraints:@[
        [NSLayoutConstraint constraintWithItem:bannerView
                                   attribute:NSLayoutAttributeBottom
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:self.adViewContainer.safeAreaLayoutGuide
                                   attribute:NSLayoutAttributeBottom
                                  multiplier:1
                                    constant:0],
        [NSLayoutConstraint constraintWithItem:bannerView
                                   attribute:NSLayoutAttributeCenterX
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:self.adViewContainer
                                   attribute:NSLayoutAttributeCenterX
                                  multiplier:1
                                    constant:0]
                                    ]];
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"AdMob - didFailToReceiveAdWithError - error : %@", error.localizedDescription);
    [self loadMediation];
}


#pragma mark - FBAdViewDelegate
- (void)adViewDidClick:(FBAdView *)adView
{
    
}

- (void)adViewDidFinishHandlingClick:(FBAdView *)adView
{
    
}

- (void)adViewWillLogImpression:(FBAdView *)adView
{
    
}

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error
{
    NSLog(@"Fan - didFailWithError - error : %@", error.localizedDescription);
    [self loadMediation];
}

- (void)adViewDidLoad:(FBAdView *)adView
{
    if (self.fanAdView && self.fanAdView.isAdValid) {
        [self.adViewContainer addSubview:self.fanAdView];
    }
}



#pragma mark - AdFitBannerAdViewDelegate

- (void)adViewDidReceiveAd:(AdFitBannerAdView *)bannerAdView {
    NSLog(@"Adfit - didReceiveAd");
}

- (void)adViewDidFailToReceiveAd:(AdFitBannerAdView *)bannerAdView error:(NSError *)error {
    NSLog(@"Adfit - didFailToReceiveAd - error : %@", [error localizedDescription]);
    [self loadMediation];
}

- (void)adViewDidClickAd:(AdFitBannerAdView *)bannerAdView {
    NSLog(@"Adfit - didClickAd");
}

#pragma mark - IAUnitDelegate

- (UIViewController * )IAParentViewControllerForUnitController:(IAUnitController *)unitController
{
    return self;
}


#pragma mark - PAGBannerAdDelegate

- (void)adDidShow:(PAGLInterstitialAd *)ad {
    
}

- (void)adDidClick:(PAGLInterstitialAd *)ad {
    
}

- (void)adDidDismiss:(PAGLInterstitialAd *)ad {
    
}

- (void)adDidShowFail:(PAGLInterstitialAd *)ad error:(NSError *)error {
    
}


@end
