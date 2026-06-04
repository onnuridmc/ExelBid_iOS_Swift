#import <UIKit/UIKit.h>
@import ExelBidSDK;

NS_ASSUME_NONNULL_BEGIN

/// Native rendering view for the mediation demo. Adds the two optional
/// `EBNativeAdRendering` slots that AdMob / FAN adapters need:
///   - `nativeMediaView`  — empty container the adapter fills with its own
///     media view (`GADMediaView` / `FBMediaView`). Required for AdMob / FAN
///     video native creatives.
///   - `nativeAdChoicesView` — overlay slot for AdChoices / privacy badges.
///
/// When `nativeMediaView` is provided the SDK skips populating
/// `nativeMainImageView` to avoid double rendering. ExelBid-won static-image
/// creatives still use `nativeMainImageView` (no media slot needed).
@interface MediatedNativeAdView : UIView <EBNativeAdRendering>

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UIImageView *mainImageView;
@property (nonatomic, strong) UIView *mediaContainer;
@property (nonatomic, strong) UIView *adChoicesContainer;
@property (nonatomic, strong) UILabel *ctaLabel;
@property (nonatomic, strong) UILabel *sponsoredLabel;
@property (nonatomic, strong) UIImageView *privacyIconView;

@end

NS_ASSUME_NONNULL_END
