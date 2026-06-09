#import "BannerExampleViewController.h"
#import "DesignSystem.h"
#import "StatusBadge.h"
#import "AdUnitIds.h"
@import ExelBidSDK;

@interface BannerExampleViewController ()
@property (nonatomic, strong) EBStatusBadge *badge;
@property (nonatomic, strong) EBLogView *logView;
@property (nonatomic, strong) UIView *bannerHost;
@property (nonatomic, strong, nullable) EBBannerAd *bannerAd;
@end

@implementation BannerExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.title = @"Banner";

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
    [intro addArranged:[EBSectionLabel make:@"Banner"]];
    [intro addArranged:[EBTypography body:@"320×50 사이즈 배너 광고입니다. 자동 갱신을 켜두면 서버에서 지정한 주기에 맞춰 다음 광고를 자동으로 요청합니다."]];
    [stack addArrangedSubview:intro];

    EBCardView *status = [[EBCardView alloc] init];
    [status addArranged:[EBSectionLabel make:@"Status"]];
    self.badge = [[EBStatusBadge alloc] initWithFrame:CGRectZero];
    [status addArranged:self.badge];
    [stack addArrangedSubview:status];

    EBCardView *actions = [[EBCardView alloc] init];
    [actions addArranged:[EBSectionLabel make:@"Action"]];
    [actions addArranged:[EBPrimaryButton filled:@"Load banner" target:self action:@selector(handleLoad)]];
    [stack addArrangedSubview:actions];

    EBCardView *hostCard = [[EBCardView alloc] init];
    [hostCard addArranged:[EBSectionLabel make:@"Creative"]];
    self.bannerHost = [[UIView alloc] init];
    self.bannerHost.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.bannerHost.heightAnchor constraintEqualToConstant:100]
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
    EBBannerAd *ad = self.bannerAd ?: [self makeBannerAd];
    [ad stop];
    [self setState:EBStatusBadgeStateLoading text:@"loading…"];
    [ad load];
}

- (EBBannerAd *)makeBannerAd {
    EBBannerAd *banner = [[EBBannerAd alloc] initWithAdUnitId:AdUnitIds.banner
                                                         size:CGSizeMake(320, 50)];
    banner.autoRefresh = YES;
    banner.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bannerHost addSubview:banner];
    [NSLayoutConstraint activateConstraints:@[
        [banner.widthAnchor  constraintEqualToAnchor:self.bannerHost.widthAnchor],
        [banner.heightAnchor constraintEqualToAnchor:self.bannerHost.heightAnchor]
    ]];

    __weak typeof(self) weakSelf = self;
    banner.onLoad         = ^{ [weakSelf setState:EBStatusBadgeStateReady   text:@"loaded"]; };
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
