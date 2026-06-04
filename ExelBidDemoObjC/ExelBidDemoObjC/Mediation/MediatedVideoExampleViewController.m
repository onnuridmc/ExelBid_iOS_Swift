#import "MediatedVideoExampleViewController.h"
#import "DesignSystem.h"
#import "StatusBadge.h"
#import "AdUnitIds.h"
@import ExelBidSDK;

/// Mediated fullscreen video. `load` → `presentFrom:` 2-stage. Single use.
/// When the ExelBid adapter wins, `onProgress` reports VAST quartile
/// boundaries (0/25/50/75/100). AdMob / FAN play their video creative as an
/// interstitial video (not rewarded) and `onProgress` is approximated with
/// start (0) and end (100) only.
@interface MediatedVideoExampleViewController ()
@property (nonatomic, strong) EBStatusBadge *badge;
@property (nonatomic, strong) EBInfoRow *winnerRow;
@property (nonatomic, strong) EBInfoRow *progressRow;
@property (nonatomic, strong) EBLogView *logView;
@property (nonatomic, weak) UIButton *presentButton;
@property (nonatomic, strong, nullable) EBMediatedVideoAd *videoAd;
@end

@implementation MediatedVideoExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.title = @"Mediated Video";

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
    [intro addArranged:[EBSectionLabel make:@"Mediated Video"]];
    [intro addArranged:[EBTypography body:@"EBMediatedVideoAd — load → presentFrom:. 1회 재생 후 isReady가 NO로 돌아갑니다. 다음 재생은 다시 load부터.\n\nExelBid 외 네트워크(AdMob/FAN)는 video 포맷을 전면 비디오로 노출하며 onProgress는 시작(0)/종료(100) 두 시점만 근사 보고됩니다."]];
    [stack addArrangedSubview:intro];

    EBCardView *status = [[EBCardView alloc] init];
    [status addArranged:[EBSectionLabel make:@"Status"]];
    self.badge = [[EBStatusBadge alloc] initWithFrame:CGRectZero];
    [status addArranged:self.badge];
    self.winnerRow = [[EBInfoRow alloc] initWithKey:@"Winning network" value:@"-"];
    [status addArranged:self.winnerRow];
    self.progressRow = [[EBInfoRow alloc] initWithKey:@"Progress" value:@"-"];
    [status addArranged:self.progressRow];
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
    [self.progressRow setValue:@"-"];
    [self setState:EBStatusBadgeStateLoading text:@"loading…"];
    self.presentButton.enabled = NO;

    EBMediatedVideoAd *ad = [[EBMediatedVideoAd alloc] initWithAdUnitId:AdUnitIds.video];
    ad.perNetworkTimeout = 5.0;
    __weak typeof(self) weakSelf = self;
    ad.rootViewControllerProvider = ^UIViewController * _Nullable { return weakSelf; };
    ad.options.videoSkipMin = 10;
    ad.options.videoSkipAfter = 5;

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
    ad.onProgress = ^(NSInteger percent) {
        [weakSelf.progressRow setValue:[NSString stringWithFormat:@"%ld%%", (long)percent]];
        [weakSelf.logView append:[NSString stringWithFormat:@"onProgress %ld", (long)percent]];
    };
    ad.onWillAppear    = ^{ [weakSelf.logView append:@"onWillAppear"]; };
    ad.onDidAppear     = ^{ [weakSelf setState:EBStatusBadgeStateImpression text:@"playing"]; };
    ad.onWillDisappear = ^{ [weakSelf.logView append:@"onWillDisappear"]; };
    ad.onClick         = ^{ [weakSelf setState:EBStatusBadgeStateClicked    text:@"clicked"]; };
    ad.onLeaveApp      = ^{ [weakSelf.logView append:@"onLeaveApp"]; };
    ad.onDidDisappear  = ^{
        [weakSelf setState:EBStatusBadgeStateIdle text:@"dismissed — reload to play again"];
        weakSelf.presentButton.enabled = NO;
        weakSelf.videoAd = nil;
    };
    [ad load];
    self.videoAd = ad;
}

- (void)handlePresent {
    if (!self.videoAd || !self.videoAd.isReady) {
        [self setState:EBStatusBadgeStateFailed text:@"not ready — load first"];
        return;
    }
    [self.videoAd presentFrom:self];
}

- (void)setState:(EBStatusBadgeState)state text:(NSString *)text {
    [self.badge setState:state text:text];
    [self.logView append:text];
}

@end
