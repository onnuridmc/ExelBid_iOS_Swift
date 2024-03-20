//
//  EBTableViewAdPlacerView.h
//  ExelbidSample
//
//  Created by HeroK on 2016. 11. 11..
//  Copyright © 2016년 Zionbi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ExelBidSDK/ExelBidSDK-Swift.h>

@interface EBTableViewAdPlacerView : UIView<EBNativeAdRendering>

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *mainTextLabel;
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UIImageView *mainImageView;
@property (strong, nonatomic) UIView *mainVideoView;
@property (strong, nonatomic) UIImageView *privacyInformationIconImageView;
@property (strong, nonatomic) UILabel *ctaLabel;

@end
