//
// Created by Sergey Pronin on 7/14/13.
// Copyright (c) 2013 Bingo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreLocation/CoreLocation.h>
#import "LocationHelper.h"


NSString *const kLocationChangedNotification = @"kLocationChanged";

#define LOCATION_CACHE_TIME 5*60.f

@interface LocationHelper() <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) void(^callback)(id);
@property (nonatomic, strong) NSDate *lastLocationDate;
@end


@implementation LocationHelper {
}

-(void)dealloc {
    [self.locationManager stopUpdatingLocation];
}

+(id)sharedInstance {
    static dispatch_once_t once;
    static LocationHelper *instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

-(id)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        self.locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
        self.locationManager.delegate = self;
    }
    return self;
}

-(BOOL)isDenied {
    return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied;
}

-(BOOL)isAuthorized {
    return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized;
}

-(void)startUpdatingLocation {
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]
        && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    } else {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)updateLocationWithCallback:(void (^)(CLLocation *location))callback {
    self.callback = callback;

    [self startUpdatingLocation];
}

#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.lastLocation = [locations lastObject];
    self.lastLocationDate = [NSDate date];

    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationChangedNotification object:self.lastLocation];

    if (self.callback) {
        self.callback(self.lastLocation);
        self.callback = nil;
    }

    [self.locationManager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            break;
            
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            if (self.callback) {
                self.callback(nil);
                self.callback = nil;
            }
            break;
        default:
            [self.locationManager startUpdatingLocation];
            break;
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {

    if (self.callback) {
        self.callback(nil);
        self.callback = nil;
    }

    [self.locationManager stopUpdatingLocation];
}

@end