#import "DesignSystem.h"

const CGFloat EBSpacingXS  = 4;
const CGFloat EBSpacingS   = 8;
const CGFloat EBSpacingM   = 12;
const CGFloat EBSpacingL   = 16;
const CGFloat EBSpacingXL  = 20;
const CGFloat EBSpacingXXL = 28;

const CGFloat EBCardCornerRadius   = 14;
const CGFloat EBButtonCornerRadius = 12;

UIColor *EBBrandAccentColor(void) {
    return UIColor.systemBlueColor;
}

static UIFont *EBFontWithWeight(UIFont *font, UIFontWeight weight) {
    UIFontDescriptor *descriptor = [font.fontDescriptor fontDescriptorByAddingAttributes:@{
        UIFontDescriptorTraitsAttribute: @{UIFontWeightTrait: @(weight)}
    }];
    return [UIFont fontWithDescriptor:descriptor size:0];
}

#pragma mark - EBCardView

@interface EBCardView ()
@property (nonatomic, strong) UIStackView *stack;
@end

@implementation EBCardView

- (instancetype)init {
    return [self initWithSpacing:EBSpacingM
                          insets:UIEdgeInsetsMake(16, 16, 16, 16)];
}

- (instancetype)initWithSpacing:(CGFloat)spacing insets:(UIEdgeInsets)insets {
    self = [super initWithFrame:CGRectZero];
    if (!self) { return nil; }

    self.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
    self.layer.cornerRadius = EBCardCornerRadius;
    self.layer.cornerCurve = kCACornerCurveContinuous;

    _stack = [[UIStackView alloc] init];
    _stack.axis = UILayoutConstraintAxisVertical;
    _stack.spacing = spacing;
    _stack.alignment = UIStackViewAlignmentFill;
    _stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_stack];

    [NSLayoutConstraint activateConstraints:@[
        [_stack.topAnchor      constraintEqualToAnchor:self.topAnchor      constant:insets.top],
        [_stack.bottomAnchor   constraintEqualToAnchor:self.bottomAnchor   constant:-insets.bottom],
        [_stack.leadingAnchor  constraintEqualToAnchor:self.leadingAnchor  constant:insets.left],
        [_stack.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-insets.right]
    ]];
    return self;
}

- (void)addArranged:(UIView *)view {
    [self.stack addArrangedSubview:view];
}

- (void)addArrangedSubviews:(NSArray<UIView *> *)views {
    for (UIView *v in views) { [self.stack addArrangedSubview:v]; }
}

- (void)setCustomSpacing:(CGFloat)spacing afterView:(UIView *)view {
    [self.stack setCustomSpacing:spacing afterView:view];
}

@end

#pragma mark - EBSectionLabel

@implementation EBSectionLabel
+ (UILabel *)make:(NSString *)text {
    UILabel *l = [[UILabel alloc] init];
    l.text = text.uppercaseString;
    l.font = EBFontWithWeight([UIFont preferredFontForTextStyle:UIFontTextStyleCaption1], UIFontWeightSemibold);
    l.textColor = UIColor.secondaryLabelColor;
    l.adjustsFontForContentSizeCategory = YES;
    return l;
}
@end

#pragma mark - EBTypography

@implementation EBTypography

+ (UILabel *)title:(NSString *)text {
    UILabel *l = [[UILabel alloc] init];
    l.text = text;
    l.font = EBFontWithWeight([UIFont preferredFontForTextStyle:UIFontTextStyleTitle2], UIFontWeightBold);
    l.numberOfLines = 0;
    l.adjustsFontForContentSizeCategory = YES;
    return l;
}

+ (UILabel *)body:(NSString *)text {
    UILabel *l = [[UILabel alloc] init];
    l.text = text;
    l.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    l.textColor = UIColor.labelColor;
    l.numberOfLines = 0;
    l.adjustsFontForContentSizeCategory = YES;
    return l;
}

+ (UILabel *)footnote:(NSString *)text {
    UILabel *l = [[UILabel alloc] init];
    l.text = text;
    l.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    l.textColor = UIColor.secondaryLabelColor;
    l.numberOfLines = 0;
    l.adjustsFontForContentSizeCategory = YES;
    return l;
}

@end

#pragma mark - EBInfoRow

@interface EBInfoRow ()
@property (nonatomic, strong) UILabel *valueLabel;
@end

@implementation EBInfoRow

- (instancetype)initWithKey:(NSString *)key value:(NSString *)value {
    self = [super initWithFrame:CGRectZero];
    if (!self) { return nil; }

    UILabel *keyLabel = [[UILabel alloc] init];
    keyLabel.text = key;
    keyLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    keyLabel.textColor = UIColor.secondaryLabelColor;
    keyLabel.adjustsFontForContentSizeCategory = YES;
    [keyLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    _valueLabel = [[UILabel alloc] init];
    _valueLabel.text = value;
    _valueLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _valueLabel.textColor = UIColor.labelColor;
    _valueLabel.textAlignment = NSTextAlignmentRight;
    _valueLabel.numberOfLines = 0;
    _valueLabel.adjustsFontForContentSizeCategory = YES;

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[keyLabel, _valueLabel]];
    stack.axis = UILayoutConstraintAxisHorizontal;
    stack.spacing = EBSpacingM;
    stack.alignment = UIStackViewAlignmentFirstBaseline;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor      constraintEqualToAnchor:self.topAnchor],
        [stack.bottomAnchor   constraintEqualToAnchor:self.bottomAnchor],
        [stack.leadingAnchor  constraintEqualToAnchor:self.leadingAnchor],
        [stack.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]
    ]];
    return self;
}

- (void)setValue:(NSString *)text { self.valueLabel.text = text; }

@end

#pragma mark - EBPrimaryButton

@implementation EBPrimaryButton

+ (UIButton *)filled:(NSString *)title target:(id)target action:(SEL)action {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    [b setTitle:title forState:UIControlStateNormal];
    [b setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [b setTitleColor:[UIColor.whiteColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
    b.titleLabel.font = EBFontWithWeight([UIFont preferredFontForTextStyle:UIFontTextStyleBody], UIFontWeightSemibold);
    b.titleLabel.adjustsFontForContentSizeCategory = YES;
    b.backgroundColor = EBBrandAccentColor();
    b.layer.cornerRadius = EBButtonCornerRadius;
    b.layer.cornerCurve = kCACornerCurveContinuous;
    b.contentEdgeInsets = UIEdgeInsetsMake(10, 16, 10, 16);
    if (target && action) {
        [b addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    return b;
}

+ (UIButton *)tinted:(NSString *)title target:(id)target action:(SEL)action {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    UIColor *accent = EBBrandAccentColor();
    [b setTitle:title forState:UIControlStateNormal];
    [b setTitleColor:accent forState:UIControlStateNormal];
    [b setTitleColor:[accent colorWithAlphaComponent:0.4] forState:UIControlStateDisabled];
    b.titleLabel.font = EBFontWithWeight([UIFont preferredFontForTextStyle:UIFontTextStyleBody], UIFontWeightSemibold);
    b.titleLabel.adjustsFontForContentSizeCategory = YES;
    b.backgroundColor = [accent colorWithAlphaComponent:0.12];
    b.layer.cornerRadius = EBButtonCornerRadius;
    b.layer.cornerCurve = kCACornerCurveContinuous;
    b.contentEdgeInsets = UIEdgeInsetsMake(10, 16, 10, 16);
    if (target && action) {
        [b addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    return b;
}

@end

#pragma mark - EBSurfaceCardView

@interface EBSurfaceCardView ()
@property (nonatomic, copy) void (^action)(void);
@end

@implementation EBSurfaceCardView

- (instancetype)initWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
                       symbol:(NSString *)symbolName
                       action:(void (^)(void))action {
    self = [super initWithFrame:CGRectZero];
    if (!self) { return nil; }
    _action = [action copy];

    self.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
    self.layer.cornerRadius = EBCardCornerRadius;
    self.layer.cornerCurve = kCACornerCurveContinuous;

    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:symbolName]];
    icon.tintColor = EBBrandAccentColor();
    icon.contentMode = UIViewContentModeScaleAspectFit;
    [icon setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    titleLabel.adjustsFontForContentSizeCategory = YES;

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = subtitle;
    subtitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    subtitleLabel.textColor = UIColor.secondaryLabelColor;
    subtitleLabel.numberOfLines = 0;
    subtitleLabel.adjustsFontForContentSizeCategory = YES;

    UIStackView *textStack = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, subtitleLabel]];
    textStack.axis = UILayoutConstraintAxisVertical;
    textStack.spacing = 2;

    UIImageView *chevron = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
    chevron.tintColor = UIColor.tertiaryLabelColor;
    [chevron setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[icon, textStack, chevron]];
    row.axis = UILayoutConstraintAxisHorizontal;
    row.spacing = EBSpacingM;
    row.alignment = UIStackViewAlignmentCenter;
    row.userInteractionEnabled = NO;
    row.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:row];

    [NSLayoutConstraint activateConstraints:@[
        [row.topAnchor      constraintEqualToAnchor:self.topAnchor      constant:14],
        [row.bottomAnchor   constraintEqualToAnchor:self.bottomAnchor   constant:-14],
        [row.leadingAnchor  constraintEqualToAnchor:self.leadingAnchor  constant:16],
        [row.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
        [icon.widthAnchor   constraintEqualToConstant:28],
        [icon.heightAnchor  constraintEqualToConstant:28]
    ]];

    UIButton *tap = [UIButton buttonWithType:UIButtonTypeSystem];
    tap.translatesAutoresizingMaskIntoConstraints = NO;
    [tap addTarget:self action:@selector(handleTap) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:tap];
    [NSLayoutConstraint activateConstraints:@[
        [tap.topAnchor      constraintEqualToAnchor:self.topAnchor],
        [tap.bottomAnchor   constraintEqualToAnchor:self.bottomAnchor],
        [tap.leadingAnchor  constraintEqualToAnchor:self.leadingAnchor],
        [tap.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]
    ]];
    return self;
}

- (void)handleTap { if (self.action) { self.action(); } }

@end

#pragma mark - EBLogView

@interface EBLogView ()
@property (nonatomic, strong) UITextView *textView;
@end

@implementation EBLogView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    self.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.layer.cornerRadius = 8;
    self.layer.cornerCurve = kCACornerCurveContinuous;
    self.clipsToBounds = YES;

    _textView = [[UITextView alloc] init];
    _textView.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    _textView.textColor = UIColor.labelColor;
    _textView.backgroundColor = UIColor.clearColor;
    _textView.editable = NO;
    _textView.alwaysBounceVertical = YES;
    _textView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
    _textView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_textView];
    [NSLayoutConstraint activateConstraints:@[
        [_textView.topAnchor      constraintEqualToAnchor:self.topAnchor],
        [_textView.bottomAnchor   constraintEqualToAnchor:self.bottomAnchor],
        [_textView.leadingAnchor  constraintEqualToAnchor:self.leadingAnchor],
        [_textView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_textView.heightAnchor   constraintGreaterThanOrEqualToConstant:160]
    ]];
    return self;
}

- (void)append:(NSString *)line {
    NSString *stamp = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                     dateStyle:NSDateFormatterNoStyle
                                                     timeStyle:NSDateFormatterMediumStyle];
    NSString *text = self.textView.text ?: @"";
    self.textView.text = [text stringByAppendingFormat:@"[%@] %@\n", stamp, line];
    NSRange end = NSMakeRange(self.textView.text.length, 0);
    [self.textView scrollRangeToVisible:end];
}

- (void)clear { self.textView.text = @""; }

@end
