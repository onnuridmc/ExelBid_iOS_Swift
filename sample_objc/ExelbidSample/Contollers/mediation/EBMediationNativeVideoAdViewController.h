//
//  EBMediationNativeVideoAdViewController.h
//
//  Created by Jaeuk Jeong on 2023/02/09.
//

#import <UIKit/UIKit.h>
#import "EBAdInfo.h"

@interface EBMediationNativeVideoAdViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *keywordsTextField;
@property (weak, nonatomic) IBOutlet UIButton *loadAdButton;
@property (weak, nonatomic) IBOutlet UIButton *showAdButton;
@property (weak, nonatomic) IBOutlet UIView *adViewContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *failLabel;

@property (nonatomic, strong) EBAdInfo *info;

@end
