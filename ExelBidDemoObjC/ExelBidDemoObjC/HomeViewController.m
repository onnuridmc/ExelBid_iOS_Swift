#import "HomeViewController.h"
#import "DesignSystem.h"
@import ExelBidSDK;
@import AppTrackingTransparency;

@interface HomeViewController ()
@property (nonatomic, strong) EBInfoRow *attRow;
@property (nonatomic, strong) UISegmentedControl *logSegments;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.title = @"ExelBid Demo";

    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;

    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    scroll.alwaysBounceVertical = YES;
    [self.view addSubview:scroll];

    UIStackView *container = [[UIStackView alloc] init];
    container.axis = UILayoutConstraintAxisVertical;
    container.spacing = EBSpacingL;
    container.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:container];

    [container addArrangedSubview:[self makeHeroCard]];
    [container addArrangedSubview:[self makeATTCard]];
    [container addArrangedSubview:[self makeLogLevelCard]];

    [NSLayoutConstraint activateConstraints:@[
        [scroll.topAnchor      constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [scroll.bottomAnchor   constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [scroll.leadingAnchor  constraintEqualToAnchor:self.view.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],

        [container.topAnchor      constraintEqualToAnchor:scroll.contentLayoutGuide.topAnchor constant:EBSpacingL],
        [container.bottomAnchor   constraintEqualToAnchor:scroll.contentLayoutGuide.bottomAnchor constant:-EBSpacingXXL],
        [container.leadingAnchor  constraintEqualToAnchor:scroll.frameLayoutGuide.leadingAnchor constant:EBSpacingL],
        [container.trailingAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.trailingAnchor constant:-EBSpacingL]
    ]];

    [self refreshATTStatus];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshATTStatus];
}

- (UIView *)makeHeroCard {
    EBCardView *card = [[EBCardView alloc] init];
    [card addArranged:[EBSectionLabel make:@"SDK"]];
    [card addArranged:[EBTypography title:@"ExelBid iOS"]];
    [card addArranged:[EBTypography footnote:@"v3 통합 데모입니다. Ads / Mediation / MPartners 탭에서 각 광고 surface를 둘러볼 수 있습니다. 광고 ID는 AdUnitIds 한 곳에서 관리합니다."]];
    [card addArranged:[[EBInfoRow alloc] initWithKey:@"SDK version" value:ExelBid.shared.sdkVersion]];
    [card addArranged:[[EBInfoRow alloc] initWithKey:@"Deployment" value:@"iOS 13.0+"]];
    return card;
}

- (UIView *)makeATTCard {
    EBCardView *card = [[EBCardView alloc] init];
    [card addArranged:[EBSectionLabel make:@"App Tracking Transparency"]];
    self.attRow = [[EBInfoRow alloc] initWithKey:@"ATT status" value:@"-"];
    [card addArranged:self.attRow];

    UIButton *attButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [attButton setTitle:@"Request ATT prompt" forState:UIControlStateNormal];
    attButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [attButton setTitleColor:EBBrandAccentColor() forState:UIControlStateNormal];
    attButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeading;
    [attButton addTarget:self action:@selector(handleATT) forControlEvents:UIControlEventTouchUpInside];
    [card addArranged:attButton];
    return card;
}

- (UIView *)makeLogLevelCard {
    EBCardView *card = [[EBCardView alloc] init];
    [card addArranged:[EBSectionLabel make:@"Log level"]];

    self.logSegments = [[UISegmentedControl alloc] initWithItems:@[@"off", @"warn", @"info", @"debug"]];
    self.logSegments.selectedSegmentIndex = 3;
    [self.logSegments addTarget:self action:@selector(handleLogChanged:) forControlEvents:UIControlEventValueChanged];
    [card addArranged:self.logSegments];

    [card addArranged:[EBTypography footnote:@"SDK 내부 os_log 출력 레벨. 운영 빌드에서는 warn 권장."]];
    return card;
}

- (void)handleATT {
    if (@available(iOS 14, *)) {
        __weak typeof(self) weakSelf = self;
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf refreshATTStatus];
            });
        }];
    }
}

- (void)handleLogChanged:(UISegmentedControl *)sender {
    LogLevel levels[] = { LogLevelOff, LogLevelWarning, LogLevelInfo, LogLevelDebug };
    ExelBid.shared.logLevel = levels[sender.selectedSegmentIndex];
}

- (void)refreshATTStatus {
    if (@available(iOS 14, *)) {
        NSString *title;
        switch (ATTrackingManager.trackingAuthorizationStatus) {
            case ATTrackingManagerAuthorizationStatusAuthorized:    title = @"authorized";    break;
            case ATTrackingManagerAuthorizationStatusDenied:        title = @"denied";        break;
            case ATTrackingManagerAuthorizationStatusRestricted:    title = @"restricted";    break;
            case ATTrackingManagerAuthorizationStatusNotDetermined: title = @"not determined"; break;
            default: title = @"unknown"; break;
        }
        [self.attRow setValue:title];
    } else {
        [self.attRow setValue:@"not available (<iOS 14)"];
    }
}

@end
