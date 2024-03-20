//
//  EBAdMobNativeAdView.h
//
//  Created by Jaeuk Jeong on 3/4/24.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface EBAdMobNativeAdView : UIView

@property(nonatomic, strong, nullable) GADNativeAd *nativeAd;

@property(nonatomic, weak, nullable) IBOutlet UIView *headlineView;

@property(nonatomic, weak, nullable) IBOutlet UIView *callToActionView;

@property(nonatomic, weak, nullable) IBOutlet UIView *iconView;

@property(nonatomic, weak, nullable) IBOutlet UIView *bodyView;

@property(nonatomic, weak, nullable) IBOutlet UIView *storeView;

@property(nonatomic, weak, nullable) IBOutlet UIView *priceView;

@property(nonatomic, weak, nullable) IBOutlet UIView *starRatingView;

@property(nonatomic, weak, nullable) IBOutlet UIView *advertiserView;

@property(nonatomic, weak, nullable) IBOutlet GADMediaView *mediaView;

@property(nonatomic, weak, nullable) IBOutlet GADAdChoicesView *adChoicesView;

@end
