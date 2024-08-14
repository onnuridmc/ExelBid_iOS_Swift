//
//  EBMPartnersBannerAdViewController.h
//

#import <UIKit/UIKit.h>
#import "EBAdInfo.h"

@interface EBMPartnersBannerAdViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *adViewContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *failLabel;

@property (nonatomic, strong) EBAdInfo *info;

@end
