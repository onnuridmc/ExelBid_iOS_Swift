//
//  EBAdTagSupport.h
//
//  Created by Jaeuk Jeong on 2022/08/16.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface EBAdTagSupport : NSObject

@property (nonatomic, strong) NSMutableDictionary *adUnitInfo;

@property (nonatomic) BOOL coppa;
@property (nonatomic, strong) NSString * yob;
@property (nonatomic, strong) NSString * gender;
@property (nonatomic, strong) NSDictionary * segment;

+ (instancetype)sharedProvider;

- (NSString *)params;

@end
