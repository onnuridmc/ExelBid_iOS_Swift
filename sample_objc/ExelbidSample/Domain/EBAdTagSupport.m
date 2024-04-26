//
//  EBAdTagSupport.m
//
//  Created by s Jeong on 2022/08/16.
//

#import "EBAdTagSupport.h"
#import <AdSupport/AdSupport.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <sys/utsname.h>

NSString * const kIDFA = @"idfa";
NSString * const kCOPPA = @"coppa";

NSString * const kYob = @"yob";
NSString * const kGender = @"gender";
NSString * const kSegments = @"segments";

NSString * const kAppVersion = @"app_version";

NSString * const kISOCountryCode = @"iso_country_code";
NSString * const kMobileCountryCode = @"mobile_country_code";
NSString * const kMobileNetworkCode = @"mobile_network_code";
NSString * const kCarrierName = @"carrier_name";

NSString * const kCountryCode = @"country_code";
NSString * const kOsVersion = @"os_version";
NSString * const kDeviceModel = @"device_model";
NSString * const kDeviceMake = @"device_make";
NSString * const kGeoLat = @"geo_lat";
NSString * const kGeoLon = @"geo_lon";


@interface EBAdTagSupport () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;

@end

@implementation EBAdTagSupport

static EBAdTagSupport *shared = nil;

+ (instancetype)sharedProvider
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

- (instancetype)init
{
    self = [super init];

    if (self) {
        
        // Device Model
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        
        // Location
        _locationManager = [[CLLocationManager alloc] init];
        
        [self locationStart];
        
        CLLocation *existingLocation = _locationManager.location;
        if (existingLocation && existingLocation.horizontalAccuracy > 0) {
            [self updateLastLocation:existingLocation];
        }

        // Avoid processing location updates when the application enters the background.
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [self.locationManager stopUpdatingLocation];
        }];

        // Re-activate location updates when the application comes back to the foreground.
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [self.locationManager startUpdatingLocation];
        }];

        // Location update
        [_locationManager startUpdatingLocation];
    }

    return self;
}

- (NSString *)params
{
    NSMutableDictionary * adTagModel = [[NSMutableDictionary alloc] init];
    
    // IDFA
    [adTagModel setValue:[[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString] forKey:kIDFA];
    
    // COPPA
    [adTagModel setValue:[NSNumber numberWithBool:self.coppa] forKey:kCOPPA];
    [adTagModel setValue:self.yob forKey:kYob];
    [adTagModel setValue:self.gender forKey:kGender];
    [adTagModel setValue:self.segment forKey:kSegments];
    
    // App Version
    [adTagModel setValue:NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"] forKey:kAppVersion];

    // Carrier
    CTCarrier * carrier = [self getCarrierInfo];
    [adTagModel setValue:carrier.isoCountryCode forKey:kISOCountryCode];
    [adTagModel setValue:carrier.mobileCountryCode forKey:kMobileCountryCode];
    [adTagModel setValue:carrier.mobileNetworkCode forKey:kMobileNetworkCode];
    [adTagModel setValue:carrier.carrierName forKey:kCarrierName];
    
    // Device CountryCode
    [adTagModel setValue:[[NSLocale autoupdatingCurrentLocale] countryCode] forKey:kCountryCode];
    
    // Device Model
    [adTagModel setValue:UIDevice.currentDevice.systemVersion forKey:kOsVersion];
    [adTagModel setValue:[self getDeviceModel] forKey:kDeviceModel];
    [adTagModel setValue:@"APPLE" forKey:kDeviceMake];
    
    [adTagModel setValue:[NSNumber numberWithDouble:self.lastLocation.coordinate.latitude] forKey:kGeoLat];
    [adTagModel setValue:[NSNumber numberWithDouble:self.lastLocation.coordinate.longitude] forKey:kGeoLon];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:adTagModel options:NSJSONWritingPrettyPrinted error:&error];
    if (jsonData) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return @"";
}

- (NSString *)getDeviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);

    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

- (CTCarrier *)getCarrierInfo
{
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSDictionary<NSString *, CTCarrier *> *serviceProviders = [networkInfo serviceSubscriberCellularProviders];
    return [serviceProviders objectForKey:[[serviceProviders allKeys] firstObject]];
}

- (void)locationStart
{
    // CLLocationDistance
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 100.0;
}

- (void)updateLastLocation:(CLLocation *)location
{
    NSLog(@"GEO LAT : %@, LON : %@", [NSNumber numberWithDouble:location.coordinate.latitude], [NSNumber numberWithDouble:location.coordinate.longitude]);
    self.lastLocation = location;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
}

- (NSString *)toJSONString
{
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:self.adUnitInfo options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

#pragma mark - <CLLocationManagerDelegate>

// iOS (14.0, *)
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager
{
    if (@available(iOS 14.0, *)) {
        switch (manager.authorizationStatus) {
            case kCLAuthorizationStatusNotDetermined:
                [manager requestWhenInUseAuthorization];
                break;
            case kCLAuthorizationStatusDenied:
            case kCLAuthorizationStatusRestricted:
                [manager stopUpdatingLocation];
                break;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
#else
            case kCLAuthorizationStatusAuthorized:
#endif
                [manager startUpdatingLocation];
                break;
            default:
                break;
        }
    }
}

// iOS (4.2, 14.0)
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            [manager requestWhenInUseAuthorization];
            break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            [manager stopUpdatingLocation];
            break;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
#else
        case kCLAuthorizationStatusAuthorized:
#endif
            [manager startUpdatingLocation];
            break;
        default:
            break;
    }
}

#pragma mark - <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"didUpdateLocations");
    for (CLLocation *location in locations) {
        if ([location.timestamp timeIntervalSinceDate:self.lastLocation.timestamp] < 0) {
            [self updateLastLocation:location];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError : %@", error);
    if (error.code == kCLErrorDenied) {
        [self.locationManager stopUpdatingLocation];
    }
}

#pragma mark - <CLLocationManagerDelegate> (iOS < 6.0)

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation");
    if ([newLocation.timestamp timeIntervalSinceDate:self.lastLocation.timestamp] < 0) {
        [self updateLastLocation:newLocation];
    }
}

@end
