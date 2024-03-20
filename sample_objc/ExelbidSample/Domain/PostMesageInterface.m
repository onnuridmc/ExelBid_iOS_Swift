//
//  PostMesageInterface.m
//  test-webview
//
//  Created by Jaeuk Jeong on 2022/08/16.
//

#import "PostMessageInterface.h"
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
NSString * const kCountryCode = @"country_code";
NSString * const kOsVersion = @"os_version";
NSString * const kDeviceModel = @"device_model";
NSString * const kDeviceMake = @"device_make";
NSString * const kGeoLat = @"geo_lat";
NSString * const kGeoLon = @"geo_lon";

@interface PostMessageInterface () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;

@end

@implementation PostMessageInterface

@synthesize adUnitInfo = _adUnitInfo;

- (instancetype)init
{
    self = [super init];

    if (self) {
        
        _adUnitInfo = [[NSMutableDictionary alloc] init];
        
        // IDFA
        [_adUnitInfo setValue:[[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString] forKey:kIDFA];
        
        // COPPA
        [_adUnitInfo setValue:[NSNumber numberWithBool:YES] forKey:kCOPPA];
        
        // App Version
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [_adUnitInfo setValue:appVersion forKey:kAppVersion];
        
        // Carrier Info
        CTTelephonyNetworkInfo *cttni = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *ctCarrier = [cttni subscriberCellularProvider];
        
        [_adUnitInfo setValue:ctCarrier.isoCountryCode forKey:kISOCountryCode];
        [_adUnitInfo setValue:ctCarrier.mobileCountryCode forKey:kMobileCountryCode];
        [_adUnitInfo setValue:ctCarrier.mobileNetworkCode forKey:kMobileNetworkCode];
        
        // Device CountryCode
        [_adUnitInfo setValue:[[NSLocale autoupdatingCurrentLocale] countryCode] forKey:kCountryCode];
        
        // OS Version
        [_adUnitInfo setValue:[[UIDevice currentDevice] systemVersion] forKey:kOsVersion];
        
        // Device Model
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        
        [_adUnitInfo setValue:deviceModel forKey:kDeviceModel];
        [_adUnitInfo setValue:@"APPLE" forKey:kDeviceMake];
        
        // Location
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 100.0;
        
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

- (void)updateLastLocation:(CLLocation *)location
{
    NSLog(@"GEO LAT : %@, LON : %@", [NSNumber numberWithDouble:location.coordinate.latitude], [NSNumber numberWithDouble:location.coordinate.longitude]);
    [_adUnitInfo setValue:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:kGeoLat];
    [_adUnitInfo setValue:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:kGeoLon];
    
    self.lastLocation = location;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
}

- (void)setCoppa:(BOOL)isCoppa
{
    [self.adUnitInfo setValue:[NSNumber numberWithBool:isCoppa] forKey:kCOPPA];
}

- (void)setYob:(NSString *)yob
{
    [self.adUnitInfo setValue:yob forKey:kYob];
}

- (void)setGender:(NSString *)gender
{
    [self.adUnitInfo setValue:gender forKey:kGender];
}

- (void)addSegment:(NSString *)value key:(NSString *)key
{
    NSMutableDictionary *segments;
    if ([_adUnitInfo objectForKey:kSegments]) {
        segments = [_adUnitInfo objectForKey:kSegments];
    } else {
        segments = [[NSMutableDictionary alloc] init];
    }
    
    [segments setValue:value forKey:key];
    [_adUnitInfo setObject:segments forKey:kSegments];
}

- (void)setSegment:(NSString *)value key:(NSString *)key
{
    NSMutableDictionary *segment = [[NSMutableDictionary alloc] initWithDictionary:@{key:value}];
    [_adUnitInfo setObject:segment forKey:kSegments];
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
