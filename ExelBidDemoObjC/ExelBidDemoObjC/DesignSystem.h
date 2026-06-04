#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Tokens

extern const CGFloat EBSpacingXS;
extern const CGFloat EBSpacingS;
extern const CGFloat EBSpacingM;
extern const CGFloat EBSpacingL;
extern const CGFloat EBSpacingXL;
extern const CGFloat EBSpacingXXL;

extern const CGFloat EBCardCornerRadius;
extern const CGFloat EBButtonCornerRadius;

UIColor *EBBrandAccentColor(void);

#pragma mark - Primitives

/// Container that visually groups related controls. Use `addArranged:` to
/// stack subviews vertically inside the card with the standard padding.
@interface EBCardView : UIView
- (instancetype)init;
- (instancetype)initWithSpacing:(CGFloat)spacing insets:(UIEdgeInsets)insets NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (void)addArranged:(UIView *)view;
- (void)addArrangedSubviews:(NSArray<UIView *> *)views;
- (void)setCustomSpacing:(CGFloat)spacing afterView:(UIView *)view;
@end

@interface EBSectionLabel : NSObject
+ (UILabel *)make:(NSString *)text;
@end

@interface EBTypography : NSObject
+ (UILabel *)title:(NSString *)text;
+ (UILabel *)body:(NSString *)text;
+ (UILabel *)footnote:(NSString *)text;
@end

/// `key — value` two-column row used in info / status cards.
@interface EBInfoRow : UIView
- (instancetype)initWithKey:(NSString *)key value:(NSString *)value NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (void)setValue:(NSString *)text;
@end

@interface EBPrimaryButton : NSObject
+ (UIButton *)filled:(NSString *)title target:(nullable id)target action:(SEL)action;
+ (UIButton *)tinted:(NSString *)title target:(nullable id)target action:(SEL)action;
@end

/// Tappable card used by the Home / Ads / Mediation / MPartners list screens.
/// Icon + title + subtitle + chevron, tappable.
@interface EBSurfaceCardView : UIView
- (instancetype)initWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
                       symbol:(NSString *)symbolName
                       action:(void (^)(void))action NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
@end

/// Monospaced append-only log used by example screens to surface SDK
/// lifecycle callbacks. Always scrolls to the latest line.
@interface EBLogView : UIView
- (void)append:(NSString *)line;
- (void)clear;
@end

NS_ASSUME_NONNULL_END
