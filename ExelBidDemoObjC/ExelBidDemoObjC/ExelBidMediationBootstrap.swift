import Foundation
import ExelBidSDK
import ExelBidMediationAdMob
import ExelBidMediationFAN
import ExelBidMediationAdFit

/// ObjC-callable shim. `ExelBidMediationKit.shared.register(modules:)` takes
/// a Swift protocol metatype array which is unavailable to Objective-C, so
/// the registration is wrapped in a small Swift function exposed via the
/// auto-generated `ExelBidDemoObjC-Swift.h` header.
@objc public final class ExelBidMediationBootstrap: NSObject {

    @objc public static func registerModules() {
        ExelBidMediationKit.shared.register(modules: [
            ExelBidBuiltInMediationModule.self,
            AdMobMediationModule.self,
            FANMediationModule.self,
            AdFitMediationModule.self
        ])
    }
}
