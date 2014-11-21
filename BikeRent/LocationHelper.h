//
// Created by Sergey Pronin on 5/29/14.
// Copyright (c) 2014 Sergey Pronin. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString *const kLocationChangedNotification;

/**
* Helps get location in singleton way
*/
@interface LocationHelper : NSObject

+ (instancetype)sharedInstance;

- (BOOL)isDenied;
- (BOOL)isAuthorized;

- (void)startUpdatingLocation;

/**
* Async get location
*/
- (void)updateLocationWithCallback:(void(^)(CLLocation *location))callback;

@property (nonatomic, strong) CLLocation *lastLocation;

@end