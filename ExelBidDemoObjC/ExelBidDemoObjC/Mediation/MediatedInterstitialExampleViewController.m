#import "MediatedInterstitialExampleViewController.h"
#import "DesignSystem.h"
#import "StatusBadge.h"
#import "AdUnitIds.h"
@import ExelBidSDK;

@interface MediatedInterstitialExampleViewController ()
@property (nonatomic, strong) EBStatusBadge *badge;
@property (nonatomic, strong) EBInfoRow *winnerRow;
@property (nonatomic, strong) EBLogView *logView;
@property (nonatomic, weak) UIButton *presentButton;
@property (nonatomic, strong, nullable) EBMediatedInterstitialAd *interstitial;
@end

@implementation MediatedInterstitialExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.title = @"Mediated Interstitial";

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
    [intro addArranged:[EBSectionLabel make:@"Mediated Interstitial"]];
    [intro addArranged:[EBTypography body:@"여러 네트워크의 전면 광고를 폴백 처리합니다. 광고를 미리 로드한 뒤 원하는 시점에 노출합니다. 일부 네트워크는 로드 시점부터 화면 컨트롤러가 필요하므로, 미리 설정해 두는 것이 좋습니다."]];
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
    UIButton *loadBtn = [EBPrimaryButton tinted:@"Load" target:self action:@selector(handleLoad)];
    UIButton *presentBtn = [EBPrimaryButton filled:@"Present" target:self action:@selector(handlePresent)];
    presentBtn.enabled = NO;
    self.presentButton = presentBtn;
    UIStackView *buttons = [[UIStackView alloc] initWithArrangedSubviews:@[loadBtn, presentBtn]];
    buttons.axis = UILayoutConstraintAxisHorizontal;
    buttons.spacing = EBSpacingM;
    buttons.distribution = UIStackViewDistributionFillEqually;
    [actions addArranged:buttons];
    [stack addArrangedSubview:actions];

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
    self.presentButton.enabled = NO;

    EBMediatedInterstitialAd *ad =
        [[EBMediatedInterstitialAd alloc] initWithAdUnitId:AdUnitIds.interstitial];
    ad.perNetworkTimeout = 5.0;
    __weak typeof(self) weakSelf = self;
    ad.rootViewControllerProvider = ^UIViewController * _Nullable { return weakSelf; };

    __weak typeof(ad) weakAd = ad;
    ad.onLoad = ^{
        [weakSelf.winnerRow setValue:weakAd.winningNetwork ?: @"-"];
        [weakSelf setState:EBStatusBadgeStateReady text:@"loaded — tap Present"];
        weakSelf.presentButton.enabled = YES;
    };
    ad.onFailureBlock = ^(NSError *error) {
        [weakSelf setState:EBStatusBadgeStateFailed
                      text:[NSString stringWithFormat:@"failed: %@", error.localizedDescription]];
    };
    ad.onWillAppear    = ^{ [weakSelf.logView append:@"onWillAppear"]; };
    ad.onDidAppear     = ^{ [weakSelf setState:EBStatusBadgeStateImpression text:@"presented"]; };
    ad.onWillDisappear = ^{ [weakSelf.logView append:@"onWillDisappear"]; };
    ad.onClick         = ^{ [weakSelf setState:EBStatusBadgeStateClicked    text:@"clicked"]; };
    ad.onLeaveApp      = ^{ [weakSelf.logView append:@"onLeaveApp"]; };
    ad.onClickFinish   = ^{ [weakSelf.logView append:@"onClickFinish"]; };
    ad.onDidDisappear  = ^{
        [weakSelf setState:EBStatusBadgeStateIdle text:@"dismissed — reload to show again"];
        weakSelf.presentButton.enabled = NO;
        weakSelf.interstitial = nil;
    };
    [ad load];
    self.interstitial = ad;
}

- (void)handlePresent {
    if (!self.interstitial || !self.interstitial.isReady) {
        [self setState:EBStatusBadgeStateFailed text:@"not ready — load first"];
        return;
    }
    [self.interstitial presentFrom:self];
}

- (void)setState:(EBStatusBadgeState)state text:(NSString *)text {
    [self.badge setState:state text:text];
    [self.logView append:text];
}

@end
