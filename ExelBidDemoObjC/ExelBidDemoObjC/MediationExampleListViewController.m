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
    [intro addArranged:[EBTypography body:@"서버가 정한 순서대로 여러 광고 네트워크를 시도해, 가장 먼저 응답한 광고를 노출합니다. 예제에서는 ExelBid · AdMob · FAN · AdFit 네 가지 네트워크가 등록되어 있습니다."]];
    [stack addArrangedSubview:intro];
    [stack setCustomSpacing:EBSpacingL afterView:intro];

    __weak typeof(self) weakSelf = self;
    NSArray<EBSurfaceCardView *> *cards = @[
        [[EBSurfaceCardView alloc] initWithTitle:@"Mediated Banner" subtitle:@"여러 네트워크의 배너 광고를 순차 시도"
                                          symbol:@"rectangle"
                                          action:^{ [weakSelf push:[[MediatedBannerExampleViewController alloc] init]]; }],
        [[EBSurfaceCardView alloc] initWithTitle:@"Mediated Interstitial" subtitle:@"여러 네트워크의 전면 광고를 순차 시도"
                                          symbol:@"rectangle.fill.on.rectangle.fill"
                                          action:^{ [weakSelf push:[[MediatedInterstitialExampleViewController alloc] init]]; }],
        [[EBSurfaceCardView alloc] initWithTitle:@"Mediated Native" subtitle:@"여러 네트워크의 네이티브 광고를 순차 시도"
                                          symbol:@"doc.text.image"
                                          action:^{ [weakSelf push:[[MediatedNativeExampleViewController alloc] init]]; }],
        [[EBSurfaceCardView alloc] initWithTitle:@"Mediated Video" subtitle:@"여러 네트워크의 비디오 광고를 순차 시도"
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
