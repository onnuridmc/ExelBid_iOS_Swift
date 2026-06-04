#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Central place to configure ExelBid ad unit IDs for the demo app.
/// Replace each value with the ad unit ID issued from the ExelBid console
/// for the corresponding ad format.
@interface AdUnitIds : NSObject
@property (class, nonatomic, readonly) NSString *banner;
@property (class, nonatomic, readonly) NSString *interstitial;
@property (class, nonatomic, readonly) NSString *native;
@property (class, nonatomic, readonly) NSString *video;
@end

/// MPartners ad unit IDs. MPartners uses a separate ad network and the
/// unit IDs are issued separately from the standard ones above.
@interface AdUnitIdsMPartners : NSObject
@property (class, nonatomic, readonly) NSString *banner;
@property (class, nonatomic, readonly) NSString *interstitial;
@property (class, nonatomic, readonly) NSString *native;
@end

NS_ASSUME_NONNULL_END
