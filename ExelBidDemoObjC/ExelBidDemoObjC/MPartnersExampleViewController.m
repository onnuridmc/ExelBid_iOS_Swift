#import "MPartnersExampleViewController.h"
#import "DesignSystem.h"
#import "MPartnersBannerController.h"
#import "MPartnersInterstitialController.h"
#import "MPartnersNativeController.h"

@implementation MPartnersExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.title = @"MPartners";
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
    [intro addArranged:[EBSectionLabel make:@"MPartners"]];
    [intro addArranged:[EBTypography body:@"MPartners는 별도 광고 네트워크입니다. 공개 API는 일반 광고와 1:1로 대응되며, autoRefresh / SKAdNetwork / MRC 50·100% 타이머는 미지원입니다."]];
    [stack addArrangedSubview:intro];
    [stack setCustomSpacing:EBSpacingL afterView:intro];

    __weak typeof(self) weakSelf = self;
    NSArray<EBSurfaceCardView *> *cards = @[
        [[EBSurfaceCardView alloc] initWithTitle:@"Banner" subtitle:@"EBMPartnersBannerAd"
                                          symbol:@"rectangle"
                                          action:^{ [weakSelf push:[[MPartnersBannerController alloc] init]]; }],
        [[EBSurfaceCardView alloc] initWithTitle:@"Interstitial" subtitle:@"EBMPartnersInterstitialAd"
                                          symbol:@"rectangle.fill.on.rectangle.fill"
                                          action:^{ [weakSelf push:[[MPartnersInterstitialController alloc] init]]; }],
        [[EBSurfaceCardView alloc] initWithTitle:@"Native" subtitle:@"EBMPartnersNativeAdLoader"
                                          symbol:@"doc.text.image"
                                          action:^{ [weakSelf push:[[MPartnersNativeController alloc] init]]; }]
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
