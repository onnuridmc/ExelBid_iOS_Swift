#import <UIKit/UIKit.h>
@import ExelBidSDK;

NS_ASSUME_NONNULL_BEGIN

/// Reference host view implementing `EBNativeAdRendering`. Plain UIKit (no
/// nib) so the demo stays self-contained.
///
/// `mediaContainer` is the single slot for the main creative. The SDK fills
/// it — VAST inline player when the payload carries a `video` asset, an
/// internally-managed `UIImageView` loading the main image URL otherwise.
/// The host does not own a separate main-image view.
@interface CustomNativeAdView : UIView <EBNativeAdRendering>

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UIView *mediaContainer;
@property (nonatomic, strong) UIButton *ctaButton;
@property (nonatomic, strong) UILabel *sponsoredLabel;
@property (nonatomic, strong) UIImageView *privacyIconView;

@end

NS_ASSUME_NONNULL_END
