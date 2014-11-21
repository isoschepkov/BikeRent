//
//  Ride.m
//  BikeRent
//
//  Created by Ivan Oschepkov on 25.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "Ride.h"

@interface Ride (){
    int default_interval;
}

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation Ride

+ (id)sharedInstance {
    static dispatch_once_t once;
    static Ride *instance = nil;
    dispatch_once(&once, ^{ instance = [[Ride alloc] init]; });
    return instance;
}

- (instancetype)init{
    self = [super init];
    
    
    default_interval = 60*60;
    NSDictionary *ride = [[NSUserDefaults standardUserDefaults] objectForKey:@"rideInfo"];
    
    if(ride){
        _rideId = (ride[@"rideId"] && ![ride[@"rideId"] isEqualToString:@""]) ? ride[@"rideId"] : nil;
        self.active = ride[@"active"] ? [ride[@"active"] boolValue] : NO;
        //self.totalWay = ride[@"totalWay"] ? [ride[@"totalWay"] doubleValue] : 0;
        self.totalTime = ride[@"totalTime"] ? [ride[@"totalTime"] intValue] : 0;
        self.startTime = ride[@"startTime"];
        self.totalSum = ride[@"totalSum"] ? [ride[@"totalSum"] doubleValue] : 0;
        self.timeToNextStep = ride[@"timeToNextStep"] ? [ride[@"timeToNextStep"] intValue] : 0;
        self.sumOnNextStep = ride[@"sumOnNextStep"] ? [ride[@"sumOnNextStep"] doubleValue] : 0;
        
        if(self.active){
            [self startTiming];
        }
    }
    
    return self;
}

- (void)synchronize{
    NSDictionary *ride = @{@"rideId": self.rideId ?: @"",
                           @"active":@(self.active),
                           //@"totalWay":@(self.totalWay),
                           @"totalTime":@(self.totalTime),
                           @"startTime":self.startTime ?: [NSDate date],
                           @"totalSum":@(self.totalSum),
                           @"timeToNextStep":@(self.timeToNextStep),
                           @"sumOnNextStep":@(self.sumOnNextStep)};
    [[NSUserDefaults standardUserDefaults] setObject:ride forKey:@"rideInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)startNewRide{
    [self dropAll];
    
    self.active = YES;
    self.startTime = [NSDate date];
    [self startTiming];
}

- (void)stopCurrentRide{
    [self dropAll];
    
    self.timer = nil;
}

- (void)changeRideId:(NSString *)rideId{
    if(rideId){
        _rideId = rideId;
    }
    
    [self synchronize];
}

- (void)dropAll{
    _rideId = nil;
    self.active = NO;
    //self.totalWay = 0;
    self.totalTime = 0;
    self.startTime = [NSDate date];
    self.sumOnNextStep = 5;
    self.totalSum = self.sumOnNextStep;
    self.timeToNextStep = default_interval;
}

- (void)startTiming{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateAll:)
                                                    userInfo:nil
                                                     repeats:YES];
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (IBAction)updateAll:(NSTimer *)timer{
    NSDate *fireDate = timer.fireDate;
    self.totalTime = [fireDate timeIntervalSinceDate:self.startTime];
    self.timeToNextStep = default_interval - ((self.totalTime % default_interval));
    if(self.timeToNextStep < 0){
        self.totalSum += self.sumOnNextStep;
        self.timeToNextStep = default_interval;
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:NOTIFICATION_NEW_STAGE object:nil]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:NOTIFICATION_RIDE_DATA_CHANGED object:nil]];
    
    [self synchronize];
}


@end








