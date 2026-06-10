#import <UIKit/UIKit.h>
@import ExelBidSDK;

NS_ASSUME_NONNULL_BEGIN

/// Native rendering view for the mediation demo. Adds the two optional
/// `EBNativeAdRendering` slots that AdMob / FAN adapters need:
///   - `nativeMediaView` — single slot for the main creative. The SDK or
///     the winning adapter fills it: VAST inline player for ExelBid video
///     natives, the network's own media view (`GADMediaView` / `FBMediaView`)
///     for AdMob / FAN, or an internally-managed image view for static
///     payloads.
///   - `nativeAdChoicesView` — overlay slot for AdChoices / privacy badges.
@interface MediatedNativeAdView : UIView <EBNativeAdRendering>

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UIView *mediaContainer;
@property (nonatomic, strong) UIView *adChoicesContainer;
@property (nonatomic, strong) UIButton *ctaButton;
@property (nonatomic, strong) UILabel *sponsoredLabel;
@property (nonatomic, strong) UIImageView *privacyIconView;

@end

NS_ASSUME_NONNULL_END
