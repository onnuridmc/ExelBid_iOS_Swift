import Foundation

/// Central place to configure ExelBid ad unit IDs for the demo app.
///
/// Replace each value with the ad unit ID issued from the ExelBid
/// console for the corresponding ad format. All example view controllers
/// in the demo read their ad unit ID from here.
enum AdUnitIds {

    /// Banner ad (320x50). Used by `BannerExampleViewController`.
    static let banner = "08377f76c8b3e46c4ed36c82e434da2b394a4dfa"

    /// Native ad. Used by `NativeExampleViewController`.
    static let native = "5792d262715cbd399d6910200437b40a95dcc0f6"

    /// interstitial video. Used by `VideoExampleViewController`.
    static let video = "3f548c41c3c6539ee7051aeb58ada2d4c039bc07"

    /// HTML interstitial. Used by `InterstitialExampleViewController`.
    /// Replace with the interstitial ad unit ID issued from the ExelBid console.
    static let interstitial = "615217b82a648b795040baee8bc81986a71d0eb7"

    /// MPartners ad unit IDs. MPartners uses a separate ad network and
    /// the unit IDs are issued separately from the standard ones above.
    /// Replace with the ad unit IDs issued from the MPartners side of
    /// the ExelBid console.
    enum MPartners {
        static let banner       = "exelbiddev"
        static let interstitial = "exelbiddev"
        static let native       = "exelbiddev"
    }
}
