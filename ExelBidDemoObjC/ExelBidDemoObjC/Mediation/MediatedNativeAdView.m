#import "MediatedNativeAdView.h"

@implementation MediatedNativeAdView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }

    self.backgroundColor = UIColor.secondarySystemBackgroundColor;
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;
    [self setupLayout];
    return self;
}

#pragma mark - EBNativeAdRendering

- (UILabel *)nativeTitleTextLabel        { return self.titleLabel; }
- (UILabel *)nativeMainTextLabel         { return self.bodyLabel; }
- (UILabel *)nativeCallToActionTextLabel { return self.ctaLabel; }
- (UILabel *)nativeSponsoredTextLabel    { return self.sponsoredLabel; }
- (UIImageView *)nativeIconImageView     { return self.iconView; }
- (UIImageView *)nativeMainImageView     { return self.mainImageView; }
- (UIImageView *)nativePrivacyInformationIconImageView { return self.privacyIconView; }
- (UIView *)nativeMediaView              { return self.mediaContainer; }
- (UIView *)nativeAdChoicesView          { return self.adChoicesContainer; }

#pragma mark - Layout

- (void)setupLayout {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.titleLabel.numberOfLines = 2;

    self.bodyLabel = [[UILabel alloc] init];
    self.bodyLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    self.bodyLabel.numberOfLines = 3;
    self.bodyLabel.textColor = UIColor.secondaryLabelColor;

    self.sponsoredLabel = [[UILabel alloc] init];
    self.sponsoredLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    self.sponsoredLabel.textColor = UIColor.tertiaryLabelColor;

    self.ctaLabel = [[UILabel alloc] init];
    self.ctaLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.ctaLabel.textColor = UIColor.systemBlueColor;
    self.ctaLabel.textAlignment = NSTextAlignmentRight;

    self.iconView = [[UIImageView alloc] init];
    self.iconView.contentMode = UIViewContentModeScaleAspectFill;
    self.iconView.clipsToBounds = YES;
    self.iconView.layer.cornerRadius = 4;

    self.mainImageView = [[UIImageView alloc] init];
    self.mainImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.mainImageView.clipsToBounds = YES;

    self.mediaContainer = [[UIView alloc] init];
    self.mediaContainer.backgroundColor = UIColor.clearColor;
    self.mediaContainer.clipsToBounds = YES;

    self.adChoicesContainer = [[UIView alloc] init];
    self.adChoicesContainer.backgroundColor = UIColor.clearColor;
    self.adChoicesContainer.clipsToBounds = YES;

    self.privacyIconView = [[UIImageView alloc] init];
    self.privacyIconView.contentMode = UIViewContentModeScaleAspectFit;
    self.privacyIconView.clipsToBounds = YES;
    self.privacyIconView.userInteractionEnabled = YES;

    UIStackView *topRow = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.iconView, self.titleLabel, self.ctaLabel
    ]];
    topRow.spacing = 8;
    topRow.alignment = UIStackViewAlignmentCenter;

    // mediaSlot stacks the main image and the network media container in
    // the same frame — only one is populated at a time.
    UIView *mediaSlot = [[UIView alloc] init];
    mediaSlot.translatesAutoresizingMaskIntoConstraints = NO;
    self.mainImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mediaContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [mediaSlot addSubview:self.mainImageView];
    [mediaSlot addSubview:self.mediaContainer];

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[
        topRow, mediaSlot, self.bodyLabel, self.sponsoredLabel
    ]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 8;
    stack.layoutMarginsRelativeArrangement = YES;
    stack.layoutMargins = UIEdgeInsetsMake(12, 12, 12, 12);
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:stack];

    self.privacyIconView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.privacyIconView];

    self.adChoicesContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.adChoicesContainer];

    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor  constraintEqualToAnchor:self.leadingAnchor],
        [stack.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [stack.topAnchor      constraintEqualToAnchor:self.topAnchor],
        [stack.bottomAnchor   constraintEqualToAnchor:self.bottomAnchor],
        [self.iconView.widthAnchor  constraintEqualToConstant:40],
        [self.iconView.heightAnchor constraintEqualToConstant:40],

        [mediaSlot.heightAnchor constraintEqualToConstant:180],
        [self.mainImageView.topAnchor      constraintEqualToAnchor:mediaSlot.topAnchor],
        [self.mainImageView.bottomAnchor   constraintEqualToAnchor:mediaSlot.bottomAnchor],
        [self.mainImageView.leadingAnchor  constraintEqualToAnchor:mediaSlot.leadingAnchor],
        [self.mainImageView.trailingAnchor constraintEqualToAnchor:mediaSlot.trailingAnchor],
        [self.mediaContainer.topAnchor      constraintEqualToAnchor:mediaSlot.topAnchor],
        [self.mediaContainer.bottomAnchor   constraintEqualToAnchor:mediaSlot.bottomAnchor],
        [self.mediaContainer.leadingAnchor  constraintEqualToAnchor:mediaSlot.leadingAnchor],
        [self.mediaContainer.trailingAnchor constraintEqualToAnchor:mediaSlot.trailingAnchor],

        [self.privacyIconView.topAnchor      constraintEqualToAnchor:mediaSlot.topAnchor constant:6],
        [self.privacyIconView.trailingAnchor constraintEqualToAnchor:mediaSlot.trailingAnchor constant:-6],
        [self.privacyIconView.widthAnchor    constraintEqualToConstant:20],
        [self.privacyIconView.heightAnchor   constraintEqualToConstant:20],

        [self.adChoicesContainer.topAnchor     constraintEqualToAnchor:mediaSlot.topAnchor constant:6],
        [self.adChoicesContainer.leadingAnchor constraintEqualToAnchor:mediaSlot.leadingAnchor constant:6],
        [self.adChoicesContainer.widthAnchor   constraintEqualToConstant:20],
        [self.adChoicesContainer.heightAnchor  constraintEqualToConstant:20]
    ]];
}

@end
