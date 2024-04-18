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
        [EBAdInfo infoWithTitle:@"배너광고" ID:@"08377f76c8b3e46c4ed36c82e434da2b394a4dfa" type:EBAdInfoBanner],
        [EBAdInfo infoWithTitle:@"전면광고" ID:@"615217b82a648b795040baee8bc81986a71d0eb7" type:EBAdInfoAllBanner],
        [EBAdInfo infoWithTitle:@"다이얼로그광고" ID:@"615217b82a648b795040baee8bc81986a71d0eb7,5792d262715cbd399d6910200437b40a95dcc0f6" type:EBAdInfoDailBanner]
    ]];
 
    return ads;
}

+ (NSArray *)nativeAds
{
    return @[
        [EBAdInfo infoWithTitle:@"네이티브" ID:@"5792d262715cbd399d6910200437b40a95dcc0f6" type:EBAdInfoNative],
        [EBAdInfo infoWithTitle:@"네이티브 Banner" ID:@"5792d262715cbd399d6910200437b40a95dcc0f6" type:EBAdInfoNativeBanner],
        [EBAdInfo infoWithTitle:@"네이티브 Ad (CollectionView)" ID:@"5792d262715cbd399d6910200437b40a95dcc0f6" type:EBAdInfoNativeInCollectionView],
        [EBAdInfo infoWithTitle:@"네이티브 Ad (TableView)" ID:@"5792d262715cbd399d6910200437b40a95dcc0f6" type:EBAdInfoNativeTableViewPlacer],
    ];
}

+ (NSArray *)videoAds
{
    return @[
        [EBAdInfo infoWithTitle:@"비디오 전면" ID:@"3f548c41c3c6539ee7051aeb58ada2d4c039bc07" type:EBAdInfoVideo],
        [EBAdInfo infoWithTitle:@"비디오 네이티브" ID:@"5792d262715cbd399d6910200437b40a95dcc0f6" type:EBAdInfoNativeVideo]
    ];
}

+ (NSArray *)etcAds
{
    return @[
        [EBAdInfo infoWithTitle:@"미디에이션 Banner" ID:@"08377f76c8b3e46c4ed36c82e434da2b394a4dfa" type:EBAdInfoMediationBanner],
        [EBAdInfo infoWithTitle:@"미디에이션 Interstitial" ID:@"615217b82a648b795040baee8bc81986a71d0eb7" type:EBAdInfoMediationInterstitial],
        [EBAdInfo infoWithTitle:@"미디에이션 Interstitial Video" ID:@"202748c414a9f9a0be6c73893bc1589c6bc9af4a" type:EBAdInfoMediationInterstitial],
        [EBAdInfo infoWithTitle:@"미디에이션 Native" ID:@"5792d262715cbd399d6910200437b40a95dcc0f6" type:EBAdInfoMediationNative],
        [EBAdInfo infoWithTitle:@"미디에이션 Native Video" ID:@"a43a885cdb49fb515b18d2db5e14c58a735fe7ee" type:EBAdInfoMediationNative],
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
