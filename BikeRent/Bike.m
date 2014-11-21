//
//  Bike.m
//  BikeRent
//
//  Created by Ivan Oschepkov on 25.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "Bike.h"

@implementation Bike

+ (instancetype)bikeWithId:(NSString *)id number:(NSNumber *)number{
    Bike *bike = [[Bike alloc] init];
    
    bike.bike_id = id;
    bike.bike_number = number;
    
    return bike;
}

@end
