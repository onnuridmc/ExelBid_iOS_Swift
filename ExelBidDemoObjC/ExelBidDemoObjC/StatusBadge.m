#import "StatusBadge.h"

@interface EBStatusBadge ()
@property (nonatomic, strong) UIView *dot;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign, readwrite) EBStatusBadgeState state;
@end

@implementation EBStatusBadge

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    self.layer.cornerRadius = 14;
    self.layer.cornerCurve = kCACornerCurveContinuous;
    self.layer.masksToBounds = YES;

    _dot = [[UIView alloc] init];
    _dot.layer.cornerRadius = 4;
    _dot.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_dot];

    _label = [[UILabel alloc] init];
    _label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _label.numberOfLines = 0;
    _label.adjustsFontForContentSizeCategory = YES;
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_label];

    [NSLayoutConstraint activateConstraints:@[
        [_dot.leadingAnchor  constraintEqualToAnchor:self.leadingAnchor constant:12],
        [_dot.centerYAnchor  constraintEqualToAnchor:self.centerYAnchor],
        [_dot.widthAnchor    constraintEqualToConstant:8],
        [_dot.heightAnchor   constraintEqualToConstant:8],
        [_label.leadingAnchor  constraintEqualToAnchor:_dot.trailingAnchor constant:8],
        [_label.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12],
        [_label.topAnchor      constraintEqualToAnchor:self.topAnchor constant:8],
        [_label.bottomAnchor   constraintEqualToAnchor:self.bottomAnchor constant:-8]
    ]];

    [self setState:EBStatusBadgeStateIdle text:@"Idle"];
    return self;
}

static UIColor *EBForegroundForState(EBStatusBadgeState state) {
    switch (state) {
        case EBStatusBadgeStateIdle:       return UIColor.secondaryLabelColor;
        case EBStatusBadgeStateLoading:    return UIColor.systemOrangeColor;
        case EBStatusBadgeStateReady:      return UIColor.systemBlueColor;
        case EBStatusBadgeStateImpression: return UIColor.systemGreenColor;
        case EBStatusBadgeStateClicked:    return UIColor.systemPurpleColor;
        case EBStatusBadgeStateFailed:     return UIColor.systemRedColor;
    }
}

- (void)setState:(EBStatusBadgeState)state text:(NSString *)text {
    self.state = state;
    UIColor *fg = EBForegroundForState(state);
    self.label.text = text;
    self.label.textColor = fg;
    self.dot.backgroundColor = fg;
    self.backgroundColor = [fg colorWithAlphaComponent:0.12];
}

@end
