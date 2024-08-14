//
//  EBMPartnersBannerAdViewController.m
//

#import "EBMPartnersBannerAdViewController.h"
#import <ExelBidSDK/ExelBidSDK-Swift.h>

@interface EBMPartnersBannerAdViewController ()<UITextFieldDelegate,EBAdViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *keywordsTextField;
@property (weak, nonatomic) IBOutlet UIButton *loadAdButton;

@property (nonatomic, strong) EBAdView *adView;

@end

@implementation EBMPartnersBannerAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.keywordsTextField.text = self.info.ID;
   [self.loadAdButton.layer setCornerRadius:3.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loadAdClicked:(id)sender
{
    if (self.adView) {
        [self.adView removeFromSuperview];
    }
    [_keywordsTextField resignFirstResponder];
    
    self.adView = [[MPartnersAdView alloc] initWithAdUnitId:self.keywordsTextField.text size:self.adViewContainer.bounds.size];
    self.adView.delegate = self;
    [self.adView setYob:@"1976"];
    [self.adView setGender:@"M"];
    [self.adView setFullWebView:YES];
    [self.adView setTesting:YES];
    
    [self.adViewContainer addSubview:self.adView];
    
    [self setAdViewAutolayoutConstraint:self.adViewContainer mine:self.adView];
    
    [self.adView loadAd];
    
    self.spinner.hidden = NO;
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

// iOS7
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.adView rotateToOrientation:toInterfaceOrientation];
}

- (void)setAdViewAutolayoutConstraint:(UIView *)target mine:(UIView *)_mine
{
    [target addSubview:_mine];
    
    [_mine setTranslatesAutoresizingMaskIntoConstraints:NO];
    [target addConstraint:[NSLayoutConstraint
                           constraintWithItem:_mine
                           attribute:NSLayoutAttributeTop
                           relatedBy:NSLayoutRelationEqual
                           toItem:target
                           attribute:NSLayoutAttributeTop
                           multiplier:1
                           constant:0]];
    
    [target addConstraint:[NSLayoutConstraint
                           constraintWithItem:_mine
                           attribute:NSLayoutAttributeBottom
                           relatedBy:NSLayoutRelationEqual
                           toItem:target
                           attribute:NSLayoutAttributeBottom
                           multiplier:1
                           constant:0]];
    
    [target addConstraint:[NSLayoutConstraint
                           constraintWithItem:_mine
                           attribute:NSLayoutAttributeLeading
                           relatedBy:NSLayoutRelationEqual
                           toItem:target
                           attribute:NSLayoutAttributeLeading
                           multiplier:1
                           constant:0]];
    
    [target addConstraint:[NSLayoutConstraint
                           constraintWithItem:_mine
                           attribute:NSLayoutAttributeTrailing
                           relatedBy:NSLayoutRelationEqual
                           toItem:target
                           attribute:NSLayoutAttributeTrailing
                           multiplier:1
                           constant:0]];
    
    CGFloat _height = 0.0f;
    _height = 50.0f;
    
    [target addConstraint:[NSLayoutConstraint
                           constraintWithItem:_mine
                           attribute:NSLayoutAttributeHeight
                           relatedBy:NSLayoutRelationEqual
                           toItem:nil
                           attribute:NSLayoutAttributeNotAnAttribute
                           multiplier:1
                           constant:_height]];
    
    [_mine setNeedsUpdateConstraints];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_keywordsTextField resignFirstResponder];
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

- (void)adViewDidLoadAd:(EBAdView *)view
{
    _spinner.hidden = YES;
}

- (void)adViewDidFailToLoadAd:(EBAdView *)view
{
    _spinner.hidden = YES;
}

- (void)willLoadViewForAd:(EBAdView *)view {
    
}

- (void)didLoadViewForAd:(EBAdView *)view {
    
}

- (void)willLeaveApplicationFromAd:(EBAdView *)view {
    
}
@end
