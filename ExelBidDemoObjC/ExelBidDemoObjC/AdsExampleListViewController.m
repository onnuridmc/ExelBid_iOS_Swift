#import "AdsExampleListViewController.h"
#import "DesignSystem.h"
#import "BannerExampleViewController.h"
#import "InterstitialExampleViewController.h"
#import "NativeExampleViewController.h"
#import "VideoExampleViewController.h"

@implementation AdsExampleListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.title = @"Ads";
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
    [intro addArranged:[EBSectionLabel make:@"Ads"]];
    [intro addArranged:[EBTypography body:@"ExelBid 베이스 광고 surface 4종입니다. 항목을 선택하면 해당 화면으로 이동합니다."]];
    [stack addArrangedSubview:intro];
    [stack setCustomSpacing:EBSpacingL afterView:intro];

    __weak typeof(self) weakSelf = self;
    NSArray<EBSurfaceCardView *> *cards = @[
        [[EBSurfaceCardView alloc] initWithTitle:@"Banner" subtitle:@"320x50, autoRefresh"
                                          symbol:@"rectangle"
                                          action:^{ [weakSelf push:[[BannerExampleViewController alloc] init]]; }],
        [[EBSurfaceCardView alloc] initWithTitle:@"Interstitial" subtitle:@"전체화면 HTML, 1회 노출"
                                          symbol:@"rectangle.fill.on.rectangle.fill"
                                          action:^{ [weakSelf push:[[InterstitialExampleViewController alloc] init]]; }],
        [[EBSurfaceCardView alloc] initWithTitle:@"Native" subtitle:@"EBNativeAdRendering + attach"
                                          symbol:@"doc.text.image"
                                          action:^{ [weakSelf push:[[NativeExampleViewController alloc] init]]; }],
        [[EBSurfaceCardView alloc] initWithTitle:@"Video (VAST)" subtitle:@"1회 재생, onProgress 콜백"
                                          symbol:@"play.rectangle"
                                          action:^{ [weakSelf push:[[VideoExampleViewController alloc] init]]; }]
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
