#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EBStatusBadgeState) {
    EBStatusBadgeStateIdle,
    EBStatusBadgeStateLoading,
    EBStatusBadgeStateReady,
    EBStatusBadgeStateImpression,
    EBStatusBadgeStateClicked,
    EBStatusBadgeStateFailed
};

/// Pill-shaped status indicator for the ad lifecycle. Tinted background +
/// matching dot so the same state reads identically across screens.
@interface EBStatusBadge : UIView
@property (nonatomic, readonly) EBStatusBadgeState state;
- (void)setState:(EBStatusBadgeState)state text:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
