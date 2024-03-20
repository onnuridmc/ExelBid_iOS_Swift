//
//  EBFanNativeAdView.h
//
//  Created by Jaeuk Jeong on 2/29/24.
//

#import <UIKit/UIKit.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface EBFanNativeAdView : UIView

@property (nonatomic, strong) UIView *adView;

@property (nonatomic, strong) IBOutlet FBMediaView *adIconImageView;
@property (nonatomic, strong) IBOutlet FBMediaView *adCoverMediaView;
@property (nonatomic, strong) IBOutlet UILabel *adTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *adBodyLabel;
@property (nonatomic, strong) IBOutlet UIButton *adCallToActionButton;
@property (nonatomic, strong) IBOutlet UILabel *adSocialContextLabel;
@property (nonatomic, strong) IBOutlet UILabel *sponsoredLabel;
@property (nonatomic, strong) IBOutlet FBAdChoicesView *adChoicesView;
@property (nonatomic, strong) IBOutlet FBAdOptionsView *adOptionsView;

@end
