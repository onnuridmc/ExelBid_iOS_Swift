//
//  EBMediationBizBoardViewController.m
//
//  Created by Jaeuk Jeong on 2023/02/09.
//

/**
 * AdFit Bizboard 템플릿 샘플
 */

#import "EBMediationBizBoardViewController.h"
#import "EBNativeAdView.h"
#import <ExelBidSDK/ExelBidSDK-Swift.h>

// AdFit
#import "EBAdFitNativeAdView.h"
#import <AdFitSDK/AdFitSDK.h>

@interface EBMediationBizBoardViewController ()<UITextFieldDelegate, EBNativeAdDelegate, AdFitNativeAdDelegate, AdFitNativeAdLoaderDelegate>

@property (weak, nonatomic) IBOutlet UITextField *keywordsTextField;
@property (weak, nonatomic) IBOutlet UIButton *loadAdButton;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;

@property (nonatomic, strong) EBMediationManager *mediationManager;
@property (nonatomic, strong) EBNativeAd *nativeAd;
@property (nonatomic, strong) AdFitNativeAdLoader *afLoader;
@property (nonatomic, strong) AdFitNativeAd *afNativeAd;
@property (nonatomic, strong) BizBoardTemplate *afNativeAdView;

@end

@implementation EBMediationBizBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.showAdButton.hidden = YES;
    self.keywordsTextField.text = self.info.ID;
    [self.loadAdButton.layer setCornerRadius:3.0f];
    [self.showAdButton.layer setCornerRadius:3.0f];
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
    self.logView.text = @"";
    
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
        // adViewContainer 내 추가된 서브뷰 제거
        [[self.adViewContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        // ExelBid 미디에이션 순서대로 가져오기 (더이상 없으면 nil)
        EBMediationWrapper *mediation = [self.mediationManager next];
        
        if (mediation == nil) {
            [self emptyMediation];
        } else if ([mediation.id isEqualToString:EBMediationTypes.exelbid]) {
            [self loadExelBid:mediation];
        } else if ([mediation.id isEqualToString:EBMediationTypes.adfit]) {
            [self loadAdFit:mediation];
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


- (void)loadExelBid:(EBMediationWrapper *)mediation {
    ExelBidNativeManager * ebNativeManager = [[ExelBidNativeManager alloc] init:mediation.unit_id :[EBNativeAdView class]];
    [ebNativeManager testing:YES];
    [ebNativeManager yob:@"1976"];
    [ebNativeManager gender:@"M"];

    [ebNativeManager startWithCompletionHandler:^(EBNativeAdRequest *request, EBNativeAd *response, NSError *error) {
        if (error) {
            NSLog(@"================> %@", error);
            self.loadAdButton.enabled = YES;
            self.failLabel.hidden = NO;
        } else {
            NSLog(@"Received Native Ad");
            self.loadAdButton.enabled = YES;

            self.nativeAd = response;
            self.nativeAd.delegate = self;
            
            UIView *adView = [self.nativeAd retrieveAdViewWithError:nil];
            [self.adViewContainer addSubview:adView];
            adView.frame = self.adViewContainer.bounds;
        }

        [self.spinner setHidden:YES];
    }];
}

- (void)loadAdFit:(EBMediationWrapper *)mediation {
    self.afNativeAdView = [[BizBoardTemplate alloc] initWithFrame: CGRectZero];
    
    double viewWidth = self.adViewContainer.frame.size.width; // 실제 뷰의 너비
    double leftRightMargin = BizBoardTemplate.defaultEdgeInset.left + BizBoardTemplate.defaultEdgeInset.right; // 비즈보드 좌우 마진의 합
    double topBottomMargin = BizBoardTemplate.defaultEdgeInset.top + BizBoardTemplate.defaultEdgeInset.bottom; // 비즈보드 상하 마진의 합
    
    // 여백을 커스텀하게 설정하였다면 아래 값을 적용
//    double leftRightMargin = self.afNativeAdView.bgViewleftMargin + self.afNativeAdView.bgViewRightMargin;
//    double topBottomMargin = self.afNativeAdView.bgViewTopMargin + self.afNativeAdView.bgViewBottomMargin;
    
    double bizBoardWidth = viewWidth - leftRightMargin; // 뷰의 실제 너비에서 좌우 마진값을 빼주면 비즈보드 너비가 나온다.
    double bizBoardRatio = 1029.0 / 222.0; // 비즈보드 이미지의 비율
    double bizBoardHeight = bizBoardWidth / bizBoardRatio; // 비즈보드 너비에서 비율값을 나눠주면 비즈보드 높이를 계산 할 수 있다.
    double viewHeight = bizBoardHeight + topBottomMargin; // 비즈보드 높이에서 상하 마진값을 더해주면 실제 그려줄 뷰의 높이를 알 수 있다.
    
    self.afNativeAdView.frame = CGRectMake(0, 0, viewWidth, viewHeight);
    
    [self.adViewContainer addSubview:self.afNativeAdView];
    
    self.afLoader = [[AdFitNativeAdLoader alloc] initWithClientId:mediation.unit_id count:1];
    self.afLoader.delegate = self;
    self.afLoader.infoIconPosition = AdFitInfoIconPositionTopRight;
    
    [self.afLoader loadAdWithKeyword:nil];
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

#pragma mark - AdFitNativeAdDelegate

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
        
    CGRect frame = self.afNativeAdView.frame;
    frame.origin = self.view.safeAreaLayoutGuide.layoutFrame.origin;
    [self.afNativeAdView setFrame:frame];
}

- (void)nativeAdLoaderDidReceiveAd:(AdFitNativeAd *)nativeAd
{
    NSLog(@"Adfit - nativeAdLoaderDidReceiveAd");
    
    self.afNativeAd = nativeAd;
    
    //인포아이콘 조정은 바인드 전에 이뤄줘야 한다.
    self.afNativeAd.infoIconRightConstant = -20; //인포아이콘을 우에서 좌로 20
    self.afNativeAd.infoIconTopConstant = 5; //인포아이콘을 위에서 아래로 5만큼 이동

    [self.afNativeAd bind:self.afNativeAdView];
    self.afNativeAd.delegate = self;
}

- (void)nativeAdLoaderDidReceiveAds:(NSArray<AdFitNativeAd *> *)nativeAds
{
    NSLog(@"Adfit - nativeAdLoaderDidReceiveAds");
}

- (void)nativeAdLoaderDidFailToReceiveAd:(AdFitNativeAdLoader *)nativeAdLoader error:(NSError *)error
{
    NSLog(@"Adfit - nativeAdLoaderDidFailToReceiveAd - error : %@", error.localizedDescription);
}

@end

