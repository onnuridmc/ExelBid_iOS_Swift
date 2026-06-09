#import "MediatedNativeExampleViewController.h"
#import "MediatedNativeAdView.h"
#import "DesignSystem.h"
#import "StatusBadge.h"
#import "AdUnitIds.h"
@import ExelBidSDK;

/// Mediated native ad. Uses `MediatedNativeAdView` — same `EBNativeAdRendering`
/// protocol as the standard native demo plus the optional `nativeMediaView`
/// and `nativeAdChoicesView` slots that AdMob / FAN adapters need.
@interface MediatedNativeExampleViewController ()
@property (nonatomic, strong) EBStatusBadge *badge;
@property (nonatomic, strong) EBInfoRow *winnerRow;
@property (nonatomic, strong) EBLogView *logView;
@property (nonatomic, strong) UIView *adContainer;
@property (nonatomic, strong, nullable) EBMediatedNativeAd *loadedAd;
@property (nonatomic, strong, nullable) EBMediatedNativeAdLoader *loader;
@end

@implementation MediatedNativeExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.title = @"Mediated Native";

    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    scroll.alwaysBounceVertical = YES;
    [self.view addSubview:scroll];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = EBSpacingL;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:stack];

    EBCardView *intro = [[EBCardView alloc] init];
    [intro addArranged:[EBSectionLabel make:@"Mediated Native"]];
    [intro addArranged:[EBTypography body:@"여러 네트워크의 네이티브 광고를 폴백 처리합니다. 광고 자산은 낙찰된 네트워크에 맞춰 자동으로 뷰에 바인딩됩니다."]];
    [stack addArrangedSubview:intro];

    EBCardView *status = [[EBCardView alloc] init];
    [status addArranged:[EBSectionLabel make:@"Status"]];
    self.badge = [[EBStatusBadge alloc] initWithFrame:CGRectZero];
    [status addArranged:self.badge];
    self.winnerRow = [[EBInfoRow alloc] initWithKey:@"Winning network" value:@"-"];
    [status addArranged:self.winnerRow];
    [stack addArrangedSubview:status];

    EBCardView *actions = [[EBCardView alloc] init];
    [actions addArranged:[EBSectionLabel make:@"Action"]];
    [actions addArranged:[EBPrimaryButton filled:@"Load mediated native ad" target:self action:@selector(handleLoad)]];
    [stack addArrangedSubview:actions];

    EBCardView *creative = [[EBCardView alloc] init];
    [creative addArranged:[EBSectionLabel make:@"Creative"]];
    self.adContainer = [[UIView alloc] init];
    self.adContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [creative addArranged:self.adContainer];
    [stack addArrangedSubview:creative];

    EBCardView *log = [[EBCardView alloc] init];
    [log addArranged:[EBSectionLabel make:@"Lifecycle log"]];
    self.logView = [[EBLogView alloc] initWithFrame:CGRectZero];
    [log addArranged:self.logView];
    [stack addArrangedSubview:log];

    [NSLayoutConstraint activateConstraints:@[
        [scroll.topAnchor      constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [scroll.bottomAnchor   constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [scroll.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [stack.topAnchor      constraintEqualToAnchor:scroll.contentLayoutGuide.topAnchor constant:EBSpacingL],
        [stack.bottomAnchor   constraintEqualToAnchor:scroll.contentLayoutGuide.bottomAnchor constant:-EBSpacingXXL],
        [stack.leadingAnchor  constraintEqualToAnchor:scroll.frameLayoutGuide.leadingAnchor constant:EBSpacingL],
        [stack.trailingAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.trailingAnchor constant:-EBSpacingL]
    ]];

    [self.badge setState:EBStatusBadgeStateIdle text:@"Tap to load"];
}

- (void)handleLoad {
    [self.winnerRow setValue:@"-"];
    [self setState:EBStatusBadgeStateLoading text:@"loading…"];

    EBMediatedNativeAdLoader *loader =
        [[EBMediatedNativeAdLoader alloc] initWithAdUnitId:AdUnitIds.native];
    loader.perNetworkTimeout = 5.0;
    // NOTE: `desiredAssets` (Swift Set<EBNativeAsset>) is not exposed to ObjC
    // on EBMediatedNativeAdLoader — see docs/INTEGRATION_OBJC.md. The ad unit's
    // configured default asset list is used. Swift demo specifies 5 assets
    // explicitly via `loader.desiredAssets = [.title, .main, .icon, .ctatext, .desc]`.
    __weak typeof(self) weakSelf = self;
    loader.rootViewControllerProvider = ^UIViewController * _Nullable { return weakSelf; };
    self.loader = loader;

    [loader loadWithCompletion:^(EBMediatedNativeAd * _Nullable ad, NSError * _Nullable error) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        if (!ad) {
            [strongSelf setState:EBStatusBadgeStateFailed
                            text:[NSString stringWithFormat:@"failed: %@", error.localizedDescription]];
            return;
        }
        [strongSelf.loadedAd detach];
        for (UIView *sub in strongSelf.adContainer.subviews) { [sub removeFromSuperview]; }

        MediatedNativeAdView *adView = [[MediatedNativeAdView alloc] init];
        adView.translatesAutoresizingMaskIntoConstraints = NO;
        [strongSelf.adContainer addSubview:adView];
        [NSLayoutConstraint activateConstraints:@[
            [adView.leadingAnchor  constraintEqualToAnchor:strongSelf.adContainer.leadingAnchor],
            [adView.trailingAnchor constraintEqualToAnchor:strongSelf.adContainer.trailingAnchor],
            [adView.topAnchor      constraintEqualToAnchor:strongSelf.adContainer.topAnchor],
            [adView.bottomAnchor   constraintEqualToAnchor:strongSelf.adContainer.bottomAnchor]
        ]];

        ad.presenterProvider = ^UIViewController * _Nullable { return weakSelf; };
        ad.onImpression    = ^{ [weakSelf setState:EBStatusBadgeStateImpression text:@"impression"]; };
        ad.onImpression50  = ^{ [weakSelf setState:EBStatusBadgeStateImpression text:@"impression 50%"]; };
        ad.onImpression100 = ^{ [weakSelf setState:EBStatusBadgeStateImpression text:@"impression 100%"]; };
        ad.onClick         = ^{ [weakSelf setState:EBStatusBadgeStateClicked    text:@"clicked"]; };
        ad.onLeaveApp      = ^{ [weakSelf setState:EBStatusBadgeStateClicked    text:@"left app"]; };
        ad.onClickFinish   = ^{ [weakSelf setState:EBStatusBadgeStateReady      text:@"click finished"]; };

        [ad attachTo:adView];
        [strongSelf.winnerRow setValue:ad.winningNetwork];
        strongSelf.loadedAd = ad;
        [strongSelf setState:EBStatusBadgeStateReady
                        text:[NSString stringWithFormat:@"attached — won: %@", ad.winningNetwork]];
    }];
}

- (void)setState:(EBStatusBadgeState)state text:(NSString *)text {
    [self.badge setState:state text:text];
    [self.logView append:text];
}

@end
