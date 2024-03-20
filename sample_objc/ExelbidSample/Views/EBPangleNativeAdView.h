//
//  EBPangleNativeAdView.h
//
//  Created by Jaeuk Jeong on 3/14/24.
//

#import <UIKit/UIKit.h>
#import <PAGAdSDK/PAGAdSDK.h>

@interface EBPangleNativeAdView : UIView

@property (nonatomic, strong) PAGLNativeAdRelatedView *relatedView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;

- (void)layoutSubviews;
- (void)refreshWithNativeAd:(PAGLNativeAd *)nativeAd;

@end
