#import "InterstitialExampleViewController.h"
#import "DesignSystem.h"
#import "StatusBadge.h"
#import "AdUnitIds.h"
@import ExelBidSDK;

@interface InterstitialExampleViewController ()
@property (nonatomic, strong) EBStatusBadge *badge;
@property (nonatomic, strong) EBLogView *logView;
@property (nonatomic, weak) UIButton *presentButton;
@property (nonatomic, strong, nullable) EBInterstitialAd *interstitial;
@end

@implementation InterstitialExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.title = @"Interstitial";

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
    [intro addArranged:[EBSectionLabel make:@"Interstitial"]];
    [intro addArranged:[EBTypography body:@"EBInterstitialAd는 HTML 크리에이티브를 전체화면으로 보여주는 1회 노출 surface입니다. load → isReady → presentFrom:."]];
    [stack addArrangedSubview:intro];

    EBCardView *status = [[EBCardView alloc] init];
    [status addArranged:[EBSectionLabel make:@"Status"]];
    self.badge = [[EBStatusBadge alloc] initWithFrame:CGRectZero];
    [status addArranged:self.badge];
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
    [self.badge setState:EBStatusBadgeStateLoading text:@"loading…"];
    self.presentButton.enabled = NO;

    EBInterstitialAd *ad = [[EBInterstitialAd alloc] initWithAdUnitId:AdUnitIds.interstitial];
    __weak typeof(self) weakSelf = self;
    ad.onLoad = ^{
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
