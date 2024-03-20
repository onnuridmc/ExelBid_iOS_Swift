//
//  EBAdInfo.m
//  ExelbidSample
//
//  Created by HeroK on 2016. 10. 24..
//  Copyright © 2016년 Zionbi. All rights reserved.
//

#import "EBAdInfo.h"
#import <UIKit/UIKit.h>

@implementation EBAdInfo

+ (NSDictionary *)supportedAddedAdTypes
{
    static NSDictionary *adTypes = nil;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        adTypes = @{@"Banner":@(EBAdInfoBanner), @"Native":@(EBAdInfoNative)};
    });
    
    return adTypes;
}

//+ (NSArray *)bannerAds
//{
//    NSMutableArray *ads = [NSMutableArray array];
//    
//    [ads addObjectsFromArray:@[
//                               [EBAdInfo infoWithTitle:@"배너광고" ID:@"d7865ee82b3a1a54f8beaddf817acb975098f312" type:EBAdInfoBanner],
////                               [EBAdInfo infoWithTitle:@"배너광고" ID:@"f4151549162fe4e09eb33927ed2df3b6d2804e37" type:EBAdInfoBanner],
//                               [EBAdInfo infoWithTitle:@"전면광고" ID:@"196b7524e0682351c794650dcb35dc7a032c7fab" type:EBAdInfoAllBanner],
//                               [EBAdInfo infoWithTitle:@"다이얼로그광고" ID:@"196b7524e0682351c794650dcb35dc7a032c7fab,e7ae59cf167c7b6c0fd3f71f329a22826ddb6b0d" type:EBAdInfoDailBanner],
//                               ]];
//    
//    return ads;
//}
//
//+ (NSArray *)nativeAds
//{
//    return @[
//             [EBAdInfo infoWithTitle:@"네이티브" ID:@"e7ae59cf167c7b6c0fd3f71f329a22826ddb6b0d" type:EBAdInfoNative],
//             [EBAdInfo infoWithTitle:@"네이티브 Banner" ID:@"e7ae59cf167c7b6c0fd3f71f329a22826ddb6b0d" type:EBAdInfoNativeBanner],
//             [EBAdInfo infoWithTitle:@"네이티브 Ad (CollectionView)" ID:@"e7ae59cf167c7b6c0fd3f71f329a22826ddb6b0d" type:EBAdInfoNativeInCollectionView],
//             [EBAdInfo infoWithTitle:@"네이티브 Ad (TableView)" ID:@"e7ae59cf167c7b6c0fd3f71f329a22826ddb6b0d" type:EBAdInfoNativeTableViewPlacer],
//             ];
//}
//
//+ (NSArray *)etcAds
//{
//    return @[
//             [EBAdInfo infoWithTitle:@"미디에이션 Banner" ID:@"d7865ee82b3a1a54f8beaddf817acb975098f312" type:EBAdInfoMediationBanner],
//             [EBAdInfo infoWithTitle:@"미디에이션 Native" ID:@"e7ae59cf167c7b6c0fd3f71f329a22826ddb6b0d" type:EBAdInfoMediationNative],
//             [EBAdInfo infoWithTitle:@"미디에이션 BizboardView" ID:@"e7ae59cf167c7b6c0fd3f71f329a22826ddb6b0d" type:EBAdInfoMediationBizboardView],
//             [EBAdInfo infoWithTitle:@"애드태그" ID:@"d7865ee82b3a1a54f8beaddf817acb975098f312" type:EBAdInfoAdTag]
//             ];
//}

+ (NSArray *)bannerAds
{
    NSMutableArray *ads = [NSMutableArray array];
 
    [ads addObjectsFromArray:@[
        [EBAdInfo infoWithTitle:@"배너광고" ID:@"cd54f7365c637fc41327422e3b7dee8d7fb3dcec" type:EBAdInfoBanner],
        [EBAdInfo infoWithTitle:@"전면광고" ID:@"e88b95b25a0c736cb218135814f84f644dfd4248" type:EBAdInfoAllBanner]
    ]];
 
    return ads;
}

+ (NSArray *)nativeAds
{
    return @[
        [EBAdInfo infoWithTitle:@"네이티브" ID:@"7590634941fa4bd366b49bb46eb3043bc63d42d6" type:EBAdInfoNative],
        [EBAdInfo infoWithTitle:@"네이티브 Banner" ID:@"7590634941fa4bd366b49bb46eb3043bc63d42d6" type:EBAdInfoNativeBanner],
        [EBAdInfo infoWithTitle:@"네이티브 Ad (CollectionView)" ID:@"7590634941fa4bd366b49bb46eb3043bc63d42d6" type:EBAdInfoNativeInCollectionView],
        [EBAdInfo infoWithTitle:@"네이티브 Ad (TableView)" ID:@"7590634941fa4bd366b49bb46eb3043bc63d42d6" type:EBAdInfoNativeTableViewPlacer],
    ];
}

+ (NSArray *)etcAds
{
    return @[
        [EBAdInfo infoWithTitle:@"미디에이션 Banner" ID:@"cd54f7365c637fc41327422e3b7dee8d7fb3dcec" type:EBAdInfoMediationBanner],
        [EBAdInfo infoWithTitle:@"미디에이션 Interstitial" ID:@"e88b95b25a0c736cb218135814f84f644dfd4248" type:EBAdInfoMediationInterstitial],
        [EBAdInfo infoWithTitle:@"미디에이션 Native" ID:@"7590634941fa4bd366b49bb46eb3043bc63d42d6" type:EBAdInfoMediationNative],
        [EBAdInfo infoWithTitle:@"미디에이션 BizboardView" ID:@"7590634941fa4bd366b49bb46eb3043bc63d42d6" type:EBAdInfoMediationBizboardView],
        [EBAdInfo infoWithTitle:@"애드태그" ID:@"cd54f7365c637fc41327422e3b7dee8d7fb3dcec" type:EBAdInfoAdTag]
    ];
}


+ (EBAdInfo *)infoWithTitle:(NSString *)title ID:(NSString *)ID type:(EBAdInfoType)type
{
    EBAdInfo *info = [[EBAdInfo alloc] init];
    info.title = title;
    info.ID = ID;
    info.type = type;
    return info;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.ID = [aDecoder decodeObjectForKey:@"ID"];
        self.type = [aDecoder decodeIntegerForKey:@"type"];
        self.keywords = [aDecoder decodeObjectForKey:@"keywords"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeInteger:self.type forKey:@"type"];
    [aCoder encodeObject:((self.keywords != nil) ? self.keywords : @"") forKey:@"keywords"];
}


@end
