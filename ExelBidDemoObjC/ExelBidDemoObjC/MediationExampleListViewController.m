#import "MediationExampleListViewController.h"
#import "DesignSystem.h"
#import "MediatedBannerExampleViewController.h"
#import "MediatedInterstitialExampleViewController.h"
#import "MediatedNativeExampleViewController.h"
#import "MediatedVideoExampleViewController.h"

@implementation MediationExampleListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.title = @"Mediation";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;

    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    scroll.alwaysBounceVertical = YES;
    [self.view addSubview:scroll];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = EBSpacingM;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:stack];

    EBCardView *intro = [[EBCardView alloc] init];
    [intro addArranged:[EBSectionLabel make:@"Mediation"]];
    [intro addArranged:[EBTypography body:@"서버 워터폴을 받아 어댑터를 자동 폴백 처리합니다. 데모는 ExelBid / AdMob / FAN / AdFit 4개 어댑터를 등록하지만, FAN·AdFit 호스트 SDK는 링크하지 않아 isAvailable=false로 동작합니다. ObjC 데모는 EBWaterfallEvent(Swift enum) 미사용으로 워터폴 단계별 로그는 표시하지 않습니다."]];
    [stack addArrangedSubview:intro];
    [stack setCustomSpacing:EBSpacingL afterView:intro];

    __weak typeof(self) weakSelf = self;
    NSArray<EBSurfaceCardView *> *cards = @[
        [[EBSurfaceCardView alloc] initWithTitle:@"Mediated Banner" subtitle:@"EBMediatedBannerAd"
                                          symbol:@"rectangle"
                                          action:^{ [weakSelf push:[[MediatedBannerExampleViewController alloc] init]]; }],
        [[EBSurfaceCardView alloc] initWithTitle:@"Mediated Interstitial" subtitle:@"EBMediatedInterstitialAd"
                                          symbol:@"rectangle.fill.on.rectangle.fill"
                                          action:^{ [weakSelf push:[[MediatedInterstitialExampleViewController alloc] init]]; }],
        [[EBSurfaceCardView alloc] initWithTitle:@"Mediated Native" subtitle:@"EBMediatedNativeAdLoader"
                                          symbol:@"doc.text.image"
                                          action:^{ [weakSelf push:[[MediatedNativeExampleViewController alloc] init]]; }],
        [[EBSurfaceCardView alloc] initWithTitle:@"Mediated Video" subtitle:@"EBMediatedVideoAd"
                                          symbol:@"play.rectangle"
                                          action:^{ [weakSelf push:[[MediatedVideoExampleViewController alloc] init]]; }]
    ];
    for (EBSurfaceCardView *c in cards) { [stack addArrangedSubview:c]; }

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
}

- (void)push:(UIViewController *)vc {
    [self.navigationController pushViewController:vc animated:YES];
}

@end
