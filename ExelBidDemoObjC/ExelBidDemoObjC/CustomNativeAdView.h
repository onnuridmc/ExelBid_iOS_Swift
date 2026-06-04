#import <UIKit/UIKit.h>
@import ExelBidSDK;

NS_ASSUME_NONNULL_BEGIN

/// Reference host view implementing `EBNativeAdRendering`. Plain UIKit (no
/// nib) so the demo stays self-contained.
@interface CustomNativeAdView : UIView <EBNativeAdRendering>

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UIImageView *mainImageView;
@property (nonatomic, strong) UILabel *ctaLabel;
@property (nonatomic, strong) UILabel *sponsoredLabel;
@property (nonatomic, strong) UIImageView *privacyIconView;

@end

NS_ASSUME_NONNULL_END
