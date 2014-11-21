//
//  BeaconListener.m
//  BikeRent
//
//  Created by Ivan Oschepkov on 25.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "BeaconListener.h"
#import "AFHTTPRequestOperationManager.h"

#define ENTER_REGION @"enter"
#define EXIT_REGION @"exit"
//#define UUID @"EBEFD083-70A2-47C8-9837-E7B5634DF525"
#define UUID @"FC51BCB2-4E98-437A-A96F-146EDDED4061"
//#define UUID @"EBA4A285-90C1-4743-A0CC-E09A0EED5164"

@interface BeaconListener () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL notified;

@end


@implementation BeaconListener

+ (instancetype)sharedInstance
{
    static BeaconListener *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [BeaconListener new];
    });
    return instance;
}

-(instancetype)init{
    self = [super init];
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.notified = NO;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    return self;
}


-(void)startMonitoring{
   
    [self.locationManager requestAlwaysAuthorization];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc]
                                                                                initWithUUIDString:UUID]
                                                                    identifier:@"Estimote"];
        region.notifyEntryStateOnDisplay = YES;
        region.notifyOnEntry = YES;
        region.notifyOnExit = YES;
        [self.locationManager startMonitoringForRegion:region];
        [self.locationManager startRangingBeaconsInRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"region: %@ state: %d", [region description], (int)state);
    CLRegionState regionState = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lastRegionState"] integerValue];
    
    if(state != regionState)
        [self sendEventWithState:state];
    
    [[NSUserDefaults standardUserDefaults] setObject:@(state) forKey:@"lastRegionState"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self sendBeaconEvent:ENTER_REGION];
    [[NSUserDefaults standardUserDefaults] setObject:@(CLRegionStateInside) forKey:@"lastRegionState"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self sendBeaconEvent:EXIT_REGION];
    [[NSUserDefaults standardUserDefaults] setObject:@(CLRegionStateOutside) forKey:@"lastRegionState"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if([beacons count] > 0)
        [self sendBeaconEvent:ENTER_REGION];
    else
        [self sendBeaconEvent:EXIT_REGION];
}

- (void)sendEventWithState:(CLRegionState)state{
    if(state == CLRegionStateInside){
        [self sendBeaconEvent:ENTER_REGION];
    } else {
        [self sendBeaconEvent:EXIT_REGION];
    }
}

- (void)sendBeaconEvent:(NSString *)event{
    if(!self.notified){
        self.notified = YES;
        if([event isEqualToString:ENTER_REGION]){
            if([self.delegate respondsToSelector:@selector(didEnterInRegionWithUUID:)])
                [self.delegate didEnterInRegionWithUUID:UUID];
        }
        if([event isEqualToString:EXIT_REGION]){
            if([self.delegate respondsToSelector:@selector(didExitFromRegion)])
                [self.delegate didExitFromRegion];
            self.notified = NO;
        }
    }
}



@end
