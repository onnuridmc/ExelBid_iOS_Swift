//
//  EBMediationNativeVideoAdViewController.m
//
//  Created by Jaeuk Jeong on 2023/02/09.
//

#import "EBMediationNativeVideoAdViewController.h"

#import "EBNativeAdView.h"
#import <ExelBidSDK/ExelBidSDK-Swift.h>

// AdMob
#import "EBAdMobNativeAdView.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

// Pangle
#import "EBPangleNativeAdView.h"
#import <PAGAdSDK/PAGAdSDK.h>

// TargetPick
#import <LibADPlus/LibADPlus-Swift.h>

@interface EBMediationNativeVideoAdViewController ()<UITextFieldDelegate, EBNativeAdDelegate, GADNativeAdLoaderDelegate, GADNativeAdDelegate, PAGLNativeAdDelegate>

@property (nonatomic, strong) EBMediationManager *mediationManager;
@property (nonatomic, strong) EBNativeAd *ebNativeAd;

// AdMob
@property (nonatomic, strong) GADAdLoader *gaAdLoad;
@property (nonatomic, strong) EBAdMobNativeAdView *gaNativeAdView;
@property(nonatomic, strong) NSLayoutConstraint *gaHeightConstraint;

// Pangle
@property (nonatomic, strong) PAGLNativeAd *pagNativeAd;

// TargetPick
@property (nonatomic, assign) NSInteger tpPublisherId;
@property (nonatomic, assign) NSInteger tpMediaId;

@end

@implementation EBMediationNativeVideoAdViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _tpPublisherId = 1761;
        _tpMediaId = 33372;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showAdButton.hidden = YES;
    self.keywordsTextField.text = self.info.ID;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                                EBMediationTypes.targetpick,
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

- (void)clearAd
{
    // adViewContainer 내 추가된 서브뷰 제거
    [[self.adViewContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
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

// 미디에이션 목록 순차 처리
- (void)loadMediation
{
    if (self.mediationManager != nil) {
        // adViewContainer 내 추가된 서브뷰 제거
        [self clearAd];

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
    [self clearAd];
    
    ExelBidNativeManager * ebNativeManager = [[ExelBidNativeManager alloc] init:mediation.unit_id :[EBNativeAdView class]];
    [ebNativeManager testing:YES];
    [ebNativeManager yob:@"1976"];
    [ebNativeManager gender:@"M"];
    
    [ebNativeManager desiredAssets:[NSSet setWithObjects:
                                            EBNativeAsset.kAdIconImageKey,
                                            EBNativeAsset.kAdVideo,
                                            EBNativeAsset.kAdTitleKey,
                                            EBNativeAsset.kAdTextKey,
                                            EBNativeAsset.kAdCTATextKey,
                                            nil]];

    [ebNativeManager startWithCompletionHandler:^(EBNativeAdRequest *request, EBNativeAd *response, NSError *error) {
        if (error) {
            NSLog(@"================> %@", error);
            self.loadAdButton.enabled = YES;
            self.failLabel.hidden = NO;
        } else {
            NSLog(@"Received Native Ad");
            self.loadAdButton.enabled = YES;
            
            self.ebNativeAd = response;
            self.ebNativeAd.delegate = self;
            
            UIView *adView = [self.ebNativeAd retrieveAdViewWithError:nil];
            [self.adViewContainer addSubview:adView];
            adView.frame = self.adViewContainer.bounds;
        }
        
        [self.spinner setHidden:YES];
    }];
}

// AdMob 광고 호출
- (void)loadAdMob:(EBMediationWrapper *)mediation
{
    [self clearAd];

    self.gaAdLoad = [[GADAdLoader alloc] initWithAdUnitID:mediation.unit_id rootViewController:self adTypes:@[GADAdLoaderAdTypeNative] options:nil];
    self.gaAdLoad.delegate = self;
    [self.gaAdLoad loadRequest:[GADRequest request]];
}

// Pangle 광고 호출
- (void)loadPangle:(EBMediationWrapper *)mediation
{
    [self clearAd];
    
    [PAGLNativeAd loadAdWithSlotID:mediation.unit_id request:PAGNativeRequest.request completionHandler:^(PAGLNativeAd * nativeAd, NSError * error) {
        EBPangleNativeAdView * nativeAdView = [[EBPangleNativeAdView alloc] initWithFrame: self.adViewContainer.frame];
        
        nativeAd.delegate = self;
        [nativeAdView refreshWithNativeAd:nativeAd];
        [nativeAdView layoutSubviews];
        
        [self.adViewContainer addSubview:nativeAdView];
    }];
}

// TargetPick 광고 호출
- (void)loadTargetPick:(EBMediationWrapper *)mediation
{
    [self clearAd];
    
    ADMZVideoModel *model = [[ADMZVideoModel alloc]
                             initWithPublisherID:self.tpPublisherId
                             withMediaID:self.tpMediaId
                             withSectionID:[mediation.unit_id integerValue]
                             withVideoSize:CGSizeMake(320, 480)
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
                             withAutoPlay:YES
                             withAutoReplay:YES
                             withMuteOption:YES
                             withClickFull:YES
                             withClickButtonShow:YES
                             withSkipButtonShow:YES
                             withClickVideoArea:YES 
                             withCloseButtonShow:YES
                             withSoundButtonShow:YES
                             withInlineVideo:YES];
    
    ADMZVideoView * videoAd = [[ADMZVideoView alloc] init];
    [videoAd updateModelWithValue:model];

    [videoAd setFailHandlerWithValue:^(enum ADMZResponseStatusType type) {
        NSLog(@"VideoDidEventFailed");
    }];
    [videoAd setOtherHandlerWithValue:^(enum ADMZResponseStatusType type) {
        NSLog(@"VideoDidEventOther");
    }];
    [videoAd setSuccessHandlerWithValue:^(enum ADMZResponseStatusType type) {
        NSLog(@"VideoDidEventSuccess");
    }];
    [videoAd setAPIResponseHandlerWithValue:^(NSDictionary<NSString *,id> * _Nullable param) {
        NSLog(@"Result = %@",param);
    }];
    
    [self.adViewContainer addSubview:videoAd];
    [self setAdViewAutolayoutConstraint:self.adViewContainer mine:videoAd];
    
    [videoAd startVideo];
}

#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    
    return YES;
}

#pragma mark - EBNativeAdDelegate

- (void)willLoadForNativeAd:(EBNativeAd *)nativeAd
{
    NSLog(@"ExelBid - Will Load for native ad.");
}

- (void)didLoadForNativeAd:(EBNativeAd *)nativeAd
{
    NSLog(@"ExelBid - Did Load for native ad.");
}

- (void)willLeaveApplicationFromNativeAd:(EBNativeAd *)nativeAd
{
    NSLog(@"ExelBid - Will leave application from native ad.");
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

#pragma mark - GADNativeAdLoaderDelegate
- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd
{
    // AdMob Native Ad View initial
    self.gaNativeAdView = [[NSBundle mainBundle] loadNibNamed:@"EBAdMobNativeAdView" owner:nil options:nil].firstObject;
    [self.adViewContainer addSubview:self.gaNativeAdView];
    [self.gaNativeAdView setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_gaNativeAdView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_gaNativeAdView]|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_gaNativeAdView]|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewDictionary]];
    
    EBAdMobNativeAdView *nativeAdView = self.gaNativeAdView;

      // Deactivate the height constraint that was set when the previous video ad loaded.
      self.gaHeightConstraint.active = NO;

      // Set ourselves as the ad delegate to be notified of native ad events.
      nativeAd.delegate = self;

      // Populate the native ad view with the native ad assets.
      // The headline and mediaContent are guaranteed to be present in every native ad.
      ((UILabel *)nativeAdView.headlineView).text = nativeAd.headline;
      nativeAdView.mediaView.mediaContent = nativeAd.mediaContent;

      // This app uses a fixed width for the GADMediaView and changes its height
      // to match the aspect ratio of the media content it displays.
      if (nativeAd.mediaContent.aspectRatio > 0) {
        self.gaHeightConstraint =
            [NSLayoutConstraint constraintWithItem:nativeAdView.mediaView
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nativeAdView.mediaView
                                         attribute:NSLayoutAttributeWidth
                                        multiplier:(1 / nativeAd.mediaContent.aspectRatio)
                                          constant:0];
        self.gaHeightConstraint.active = YES;
      }

//      if (nativeAd.mediaContent.hasVideoContent) {
//        // By acting as the delegate to the GADVideoController, this ViewController
//        // receives messages about events in the video lifecycle.
//        nativeAd.mediaContent.videoController.delegate = self;
//
//        self.videoStatusLabel.text = @"Ad contains a video asset.";
//      } else {
//        self.videoStatusLabel.text = @"Ad does not contain a video.";
//      }
    
    // Set the mediaContent on the GADMediaView to populate it with available
    // video/image asset.
    nativeAdView.mediaView.mediaContent = nativeAd.mediaContent;
    
    // Populate the native ad view with the native ad assets.
    // The headline is guaranteed to be present in every native ad.
    ((UILabel *)nativeAdView.headlineView).text = nativeAd.headline;

    // These assets are not guaranteed to be present. Check that they are before
    // showing or hiding them.
    ((UILabel *)nativeAdView.bodyView).text = nativeAd.body;
    nativeAdView.bodyView.hidden = nativeAd.body ? NO : YES;

    [((UIButton *)nativeAdView.callToActionView) setTitle:nativeAd.callToAction
                                               forState:UIControlStateNormal];
    nativeAdView.callToActionView.hidden = nativeAd.callToAction ? NO : YES;

    ((UIImageView *)nativeAdView.iconView).image = nativeAd.icon.image;
    nativeAdView.iconView.hidden = nativeAd.icon ? NO : YES;

    ((UIImageView *)nativeAdView.starRatingView).image = [self imageForStars:nativeAd.starRating];
    nativeAdView.starRatingView.hidden = nativeAd.starRating ? NO : YES;

    ((UILabel *)nativeAdView.storeView).text = nativeAd.store;
    nativeAdView.storeView.hidden = nativeAd.store ? NO : YES;

    ((UILabel *)nativeAdView.priceView).text = nativeAd.price;
    nativeAdView.priceView.hidden = nativeAd.price ? NO : YES;

    ((UILabel *)nativeAdView.advertiserView).text = nativeAd.advertiser;
    nativeAdView.advertiserView.hidden = nativeAd.advertiser ? NO : YES;

    // In order for the SDK to process touch events properly, user interaction
    // should be disabled.
    nativeAdView.callToActionView.userInteractionEnabled = NO;

    // Associate the native ad view with the native ad object. This is
    // required to make the ad clickable.
    // Note: this should always be done after populating the ad views.
    nativeAdView.nativeAd = nativeAd;
}

/// Gets an image representing the number of stars. Returns nil if rating is
/// less than 3.5 stars.
- (UIImage *)imageForStars:(NSDecimalNumber *)numberOfStars {
  double starRating = numberOfStars.doubleValue;
  if (starRating >= 5) {
    return [UIImage imageNamed:@"stars_5"];
  } else if (starRating >= 4.5) {
    return [UIImage imageNamed:@"stars_4_5"];
  } else if (starRating >= 4) {
    return [UIImage imageNamed:@"stars_4"];
  } else if (starRating >= 3.5) {
    return [UIImage imageNamed:@"stars_3_5"];
  } else {
    return nil;
  }
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"AdMob - didFailToReceiveAdWithError - error : %@", error.localizedDescription);
    [self loadMediation];
}

- (void)adLoaderDidFinishLoading:(GADAdLoader *)adLoader
{
    
}

#pragma mark - PAGLNativeAdDelegate

- (void)adDidShow:(PAGLNativeAd *)ad
{
    
}

- (void)adDidClick:(PAGLNativeAd *)ad
{
    
}

- (void)adDidDismiss:(PAGLNativeAd *)ad
{
    
}


@end

