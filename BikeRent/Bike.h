//
//  Bike.h
//  BikeRent
//
//  Created by Ivan Oschepkov on 25.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bike : NSObject

@property (strong, nonatomic) NSString *bike_id;
@property (strong, nonatomic) NSNumber *bike_number;

+ (instancetype)bikeWithId:(NSString *)id number:(NSNumber *)number;
@end
