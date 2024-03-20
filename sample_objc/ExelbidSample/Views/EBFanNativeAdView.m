//
//  EBFanNativeAdView.m
//
//  Created by Jaeuk Jeong on 2/29/24.
//

#import "EBFanNativeAdView.h"

@interface EBFanNativeAdView ()

@end

@implementation EBFanNativeAdView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (id)initWithNativeAd:(FBNativeAd *)nativeAd frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _adTitleLabel.text = nativeAd.advertiserName;
        _adBodyLabel.text = nativeAd.bodyText;
        _adSocialContextLabel.text = nativeAd.socialContext;
        _sponsoredLabel.text = nativeAd.sponsoredTranslation;
        [_adCallToActionButton setTitle:nativeAd.callToAction forState:UIControlStateNormal];
        _adOptionsView.nativeAd = nativeAd;
    }
    return self;
}

@end
