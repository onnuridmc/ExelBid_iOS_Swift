#import "MediatedBannerExampleViewController.h"
#import "DesignSystem.h"
#import "StatusBadge.h"
#import "AdUnitIds.h"
@import ExelBidSDK;

/// Mediated 320x50 banner. ObjC demo omits the waterfall log card —
/// `EBWaterfallEvent` is a Swift enum and isn't bridged to ObjC.
@interface MediatedBannerExampleViewController ()
@property (nonatomic, strong) EBStatusBadge *badge;
@property (nonatomic, strong) EBInfoRow *winnerRow;
@property (nonatomic, strong) EBLogView *logView;
@property (nonatomic, strong) UIView *bannerHost;
@property (nonatomic, strong, nullable) EBMediatedBannerAd *bannerAd;
@end

@implementation MediatedBannerExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.title = @"Mediated Banner";

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
    [intro addArranged:[EBSectionLabel make:@"Mediated Banner"]];
    [intro addArranged:[EBTypography body:@"EBMediatedBannerAd — 서버가 정한 순서대로 어댑터를 순차 시도하고 첫 성공 네트워크의 광고를 노출합니다. autoRefresh는 지원되지 않습니다."]];
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
    [actions addArranged:[EBPrimaryButton filled:@"Load mediated banner" target:self action:@selector(handleLoad)]];
    [stack addArrangedSubview:actions];

    EBCardView *hostCard = [[EBCardView alloc] init];
    [hostCard addArranged:[EBSectionLabel make:@"Creative"]];
    self.bannerHost = [[UIView alloc] init];
    self.bannerHost.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.bannerHost.heightAnchor constraintEqualToConstant:50]
    ]];
    [hostCard addArranged:self.bannerHost];
    [stack addArrangedSubview:hostCard];

    EBCardView *logCard = [[EBCardView alloc] init];
    [logCard addArranged:[EBSectionLabel make:@"Lifecycle log"]];
    self.logView = [[EBLogView alloc] initWithFrame:CGRectZero];
    [logCard addArranged:self.logView];
    [stack addArrangedSubview:logCard];

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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.bannerAd stop];
}

- (void)handleLoad {
    EBMediatedBannerAd *ad = self.bannerAd ?: [self makeBannerAd];
    [ad stop];
    [self.winnerRow setValue:@"-"];
    [self setState:EBStatusBadgeStateLoading text:@"loading…"];
    [ad load];
}

- (EBMediatedBannerAd *)makeBannerAd {
    EBMediatedBannerAd *banner = [[EBMediatedBannerAd alloc] initWithAdUnitId:AdUnitIds.banner
                                                                        size:CGSizeMake(320, 50)];
    banner.perNetworkTimeout = 5.0;
    __weak typeof(self) weakSelf = self;
    banner.rootViewControllerProvider = ^UIViewController * _Nullable { return weakSelf; };
    banner.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bannerHost addSubview:banner];
    [NSLayoutConstraint activateConstraints:@[
        [banner.centerXAnchor constraintEqualToAnchor:self.bannerHost.centerXAnchor],
        [banner.centerYAnchor constraintEqualToAnchor:self.bannerHost.centerYAnchor],
        [banner.widthAnchor   constraintEqualToConstant:320],
        [banner.heightAnchor  constraintEqualToConstant:50]
    ]];

    __weak typeof(banner) weakBanner = banner;
    banner.onLoad = ^{
        [weakSelf.winnerRow setValue:weakBanner.winningNetwork ?: @"-"];
        [weakSelf setState:EBStatusBadgeStateReady text:@"loaded"];
    };
    banner.onFailureBlock = ^(NSError *error) {
        [weakSelf setState:EBStatusBadgeStateFailed
                      text:[NSString stringWithFormat:@"failed: %@", error.localizedDescription]];
    };
    banner.onClick        = ^{ [weakSelf setState:EBStatusBadgeStateClicked text:@"clicked"]; };
    banner.onLeaveApp     = ^{ [weakSelf setState:EBStatusBadgeStateClicked text:@"left app"]; };
    banner.onClickFinish  = ^{ [weakSelf setState:EBStatusBadgeStateReady   text:@"click finished"]; };
    self.bannerAd = banner;
    return banner;
}

- (void)setState:(EBStatusBadgeState)state text:(NSString *)text {
    [self.badge setState:state text:text];
    [self.logView append:text];
}

@end
