//
//  Station.h
//  BikeRent
//
//  Created by Ivan Oschepkov on 25.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Station : NSObject

@property (strong, nonatomic) NSString *station_id;
@property (strong, nonatomic) NSArray *bikes;
@property (nonatomic) CLLocationCoordinate2D location;

+ (Station *)stationFromResponseObject:(NSDictionary *)responseStation;

@end
