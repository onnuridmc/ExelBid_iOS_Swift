#import "NativeExampleViewController.h"
#import "CustomNativeAdView.h"
#import "DesignSystem.h"
#import "StatusBadge.h"
#import "AdUnitIds.h"
@import ExelBidSDK;

@interface NativeExampleViewController ()
@property (nonatomic, strong) EBStatusBadge *badge;
@property (nonatomic, strong) EBLogView *logView;
@property (nonatomic, strong) UISwitch *videoSwitch;
@property (nonatomic, strong) UIView *adContainer;
@property (nonatomic, strong, nullable) EBNativeAd *loadedAd;
@property (nonatomic, strong, nullable) EBNativeAdLoader *loader;
@end

@implementation NativeExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.title = @"Native";

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
    [intro addArranged:[EBSectionLabel make:@"Native"]];
    [intro addArranged:[EBTypography body:@"EBNativeAdLoader로 받은 응답을 호스트 앱이 그린 EBNativeAdRendering view에 attach합니다. 노출은 attach 시점에 + 50%/100% 가시성 기반으로 발사됩니다."]];
    [stack addArrangedSubview:intro];

    EBCardView *status = [[EBCardView alloc] init];
    [status addArranged:[EBSectionLabel make:@"Status"]];
    self.badge = [[EBStatusBadge alloc] initWithFrame:CGRectZero];
    [status addArranged:self.badge];
    [stack addArrangedSubview:status];

    EBCardView *nativeOptions = [[EBCardView alloc] init];
    [nativeOptions addArranged:[EBSectionLabel make:@"Native options"]];
    [nativeOptions addArranged:[self buildVideoToggleRow]];
    UILabel *videoHelp = [EBTypography body:@"ON 시 EBNativeAssetVideo를 요청 자산에 포함하고 별도의 native video 광고 유닛(AdUnitIds.nativeVideo)으로 요청합니다. 응답에 동영상이 있으면 SDK가 nativeMediaView 슬롯 안에서 음소거 인라인 재생합니다 — 호스트 추가 작업 없음."];
    videoHelp.textColor = UIColor.secondaryLabelColor;
    [nativeOptions addArranged:videoHelp];
    [stack addArrangedSubview:nativeOptions];

    EBCardView *actions = [[EBCardView alloc] init];
    [actions addArranged:[EBSectionLabel make:@"Action"]];
    [actions addArranged:[EBPrimaryButton filled:@"Load native ad" target:self action:@selector(handleLoad)]];
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

- (UIView *)buildVideoToggleRow {
    UILabel *label = [[UILabel alloc] init];
    label.text = @"Request video asset";
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    label.adjustsFontForContentSizeCategory = YES;
    self.videoSwitch = [[UISwitch alloc] init];
    UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[
        label, [[UIView alloc] init], self.videoSwitch
    ]];
    row.axis = UILayoutConstraintAxisHorizontal;
    row.alignment = UIStackViewAlignmentCenter;
    return row;
}

- (void)handleLoad {
    [self.badge setState:EBStatusBadgeStateLoading text:@"loading…"];
    [self.logView append:@"load requested"];

    BOOL wantsVideo = self.videoSwitch.isOn;
    NSString *adUnitId = wantsVideo ? AdUnitIds.nativeVideo : AdUnitIds.native;
    EBNativeAdLoader *loader = [[EBNativeAdLoader alloc] initWithAdUnitId:adUnitId];

    NSMutableArray<NSNumber *> *assets = [@[
        @(EBNativeAssetTitle), @(EBNativeAssetMain), @(EBNativeAssetIcon),
        @(EBNativeAssetCtatext), @(EBNativeAssetDesc)
    ] mutableCopy];
    if (wantsVideo) { [assets addObject:@(EBNativeAssetVideo)]; }
    loader.desiredAssetsArray = assets;
    self.loader = loader;

    [self.logView append:[NSString stringWithFormat:@"unit: %@", adUnitId]];
    [self.logView append:[NSString stringWithFormat:@"assets: %@", [assets componentsJoinedByString:@", "]]];

    __weak typeof(self) weakSelf = self;
    [loader loadWithCompletion:^(EBNativeAd * _Nullable ad, NSError * _Nullable error) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        if (!ad) {
            [strongSelf setState:EBStatusBadgeStateFailed
                            text:[NSString stringWithFormat:@"failed: %@", error.localizedDescription]];
            return;
        }
        [strongSelf.loadedAd detach];
        for (UIView *sub in strongSelf.adContainer.subviews) { [sub removeFromSuperview]; }

        CustomNativeAdView *adView = [[CustomNativeAdView alloc] init];
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
        strongSelf.loadedAd = ad;
        [strongSelf setState:EBStatusBadgeStateReady text:@"attached"];
    }];
}

- (void)setState:(EBStatusBadgeState)state text:(NSString *)text {
    [self.badge setState:state text:text];
    [self.logView append:text];
}

@end
