import UIKit
import ExelBidSDK
import ExelBidMediationAdMob
import ExelBidMediationFAN
import ExelBidMediationAdFit
import AppTrackingTransparency
import GoogleMobileAds

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var didRequestATT = false

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        let testDeviceIdentifiers = ["2077ef9a63d2b398840261c8221a0c9b"]
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = testDeviceIdentifiers

        // SDK-wide configuration. Apply once at launch.
        let kit = ExelBid.shared
        kit.logLevel = .debug

        // Mediation modules. ExelBid built-in is mandatory; AdMob auto-links
        // GoogleMobileAds via SPM. FAN/AdFit are registered but their SDKs
        // are not linked in the demo — their adapters report isAvailable=false
        // at runtime, so the waterfall logs an `adapterNotRegistered` lose
        // and falls back to the next network.
        ExelBidMediationKit.shared.register(modules: [
            ExelBidBuiltInMediationModule.self,
            AdMobMediationModule.self,
            FANMediationModule.self,
            AdFitMediationModule.self
        ])

        let tabs = UITabBarController()
        tabs.viewControllers = [
            makeNav(HomeViewController(), title: "Home",
                    icon: UIImage(systemName: "house")),
            makeNav(AdsExampleListViewController(), title: "Ads",
                    icon: UIImage(systemName: "rectangle.stack")),
            makeNav(MediationExampleListViewController(), title: "Mediation",
                    icon: UIImage(systemName: "rectangle.3.group")),
            makeNav(MPartnersExampleViewController(), title: "MPartners",
                    icon: UIImage(systemName: "network"))
        ]

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = tabs
        window.makeKeyAndVisible()
        self.window = window

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        guard !didRequestATT else { return }
        didRequestATT = true
        if #available(iOS 14.0, *) {
            ATTrackingManager.requestTrackingAuthorization { _ in }
        }
    }

    private func makeNav(
        _ root: UIViewController,
        title: String,
        icon: UIImage?
    ) -> UINavigationController {
        root.title = title
        let nav = UINavigationController(rootViewController: root)
        nav.tabBarItem = UITabBarItem(title: title, image: icon, tag: 0)
        nav.navigationBar.prefersLargeTitles = true
        return nav
    }
}
