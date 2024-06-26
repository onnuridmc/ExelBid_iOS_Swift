//
//  EBPangleNativeAdView.m
//
//  Created by Jaeuk Jeong on 3/14/24.
//

#import "EBPangleNativeAdView.h"

@implementation EBPangleNativeAdView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = UIColor.lightGrayColor;
        
        self.relatedView = PAGLNativeAdRelatedView.new;
        [self addSubview:self.relatedView.mediaView];
        [self addSubview:self.relatedView.dislikeButton];
        [self addSubview:self.relatedView.logoADImageView];
        
        self.titleLabel = UILabel.new;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = UIColor.blackColor;
        [self addSubview:self.titleLabel];
        
        self.detailLabel = UILabel.new;
        self.detailLabel.textAlignment = NSTextAlignmentCenter;
        self.detailLabel.textColor = UIColor.blackColor;
        [self addSubview:self.detailLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.relatedView.mediaView.frame = self.bounds;
    self.relatedView.dislikeButton.frame = CGRectMake(0, 0, 44, 44);
    CGSize logoSize = CGSizeMake(20, 10);
    self.relatedView.logoADImageView.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - logoSize.height, logoSize.width, logoSize.height);
    self.titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 20);
    self.detailLabel.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 40, CGRectGetWidth(self.bounds), 40);
}

- (void)refreshWithNativeAd:(PAGLNativeAd *)nativeAd {
    self.titleLabel.text = nativeAd.data.AdTitle;
    self.detailLabel.text = nativeAd.data.AdDescription;
    [self.relatedView refreshWithNativeAd:nativeAd];
}

@end
