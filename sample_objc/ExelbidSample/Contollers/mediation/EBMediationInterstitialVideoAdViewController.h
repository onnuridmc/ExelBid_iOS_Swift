//
//  EBMediationInterstitialVideoAdViewController.h
//
//  Created by Jaeuk Jeong on 2/27/24.
//

#import <UIKit/UIKit.h>
#import "EBAdInfo.h"

@interface EBMediationInterstitialVideoAdViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *keywordsTextField;
@property (weak, nonatomic) IBOutlet UIButton *loadAdButton;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, strong) EBAdInfo *info;

@end

