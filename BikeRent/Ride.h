//
//  Ride.h
//  BikeRent
//
//  Created by Ivan Oschepkov on 25.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NOTIFICATION_RIDE_DATA_CHANGED @"RideDataChanged"
#define NOTIFICATION_NEW_STAGE @"RideNewStage"

@class Ride;

@protocol RideDelegate <NSObject>
@required
- (void)rideDidUpdateTime:(Ride*)ride;
@end

@interface Ride : NSObject

//@property (nonatomic) double totalWay;
@property (strong, nonatomic, readonly) NSString *rideId;
@property (strong, nonatomic) NSDate *startTime;
@property (nonatomic) int totalTime;
@property (nonatomic) double totalSum;
@property (nonatomic) int timeToNextStep;
@property (nonatomic) double sumOnNextStep;

@property (nonatomic) BOOL active;

+ (instancetype)sharedInstance;

- (void)startNewRide;
- (void)stopCurrentRide;

- (void)changeRideId:(NSString *)rideId;

@end
