#import "AppDelegate.h"
#import "HomeViewController.h"
#import "AdsExampleListViewController.h"
#import "MediationExampleListViewController.h"
#import "MPartnersExampleViewController.h"
#import "ExelBidDemoObjC-Swift.h"
@import ExelBidSDK;
@import AppTrackingTransparency;
@import GoogleMobileAds;

@interface AppDelegate ()
@property (nonatomic, assign) BOOL didRequestATT;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers =
        @[@"2077ef9a63d2b398840261c8221a0c9b"];

    // SDK-wide configuration. Apply once at launch.
    ExelBid.shared.logLevel = LogLevelDebug;

    // Mediation modules — registered via the Swift bootstrap (Swift protocol
    // metatype array isn't ObjC-callable). ExelBid built-in is mandatory;
    // FAN/AdFit modules are registered but their host SDKs are not linked
    // here, so the waterfall will log `adapterNotRegistered` and fall back.
    [ExelBidMediationBootstrap registerModules];

    UITabBarController *tabs = [[UITabBarController alloc] init];
    tabs.viewControllers = @[
        [self makeNav:[[HomeViewController alloc] init]
                title:@"Home"
                 icon:[UIImage systemImageNamed:@"house"]],
        [self makeNav:[[AdsExampleListViewController alloc] init]
                title:@"Ads"
                 icon:[UIImage systemImageNamed:@"rectangle.stack"]],
        [self makeNav:[[MediationExampleListViewController alloc] init]
                title:@"Mediation"
                 icon:[UIImage systemImageNamed:@"rectangle.3.group"]],
        [self makeNav:[[MPartnersExampleViewController alloc] init]
                title:@"MPartners"
                 icon:[UIImage systemImageNamed:@"network"]]
    ];

    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = tabs;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (self.didRequestATT) { return; }
    self.didRequestATT = YES;
    if (@available(iOS 14.0, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {}];
    }
}

- (UINavigationController *)makeNav:(UIViewController *)root
                              title:(NSString *)title
                               icon:(UIImage *)icon {
    root.title = title;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:root];
    nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:icon tag:0];
    nav.navigationBar.prefersLargeTitles = YES;
    return nav;
}

@end
