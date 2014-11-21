//
//  Station.m
//  BikeRent
//
//  Created by Ivan Oschepkov on 25.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "Station.h"
#import "Bike.h"

@implementation Station

+ (Station *)stationFromResponseObject:(NSDictionary *)responseStation{
    Station *station = [[Station alloc] init];
    
    if(responseStation){
        NSMutableArray *bikes = [[NSMutableArray alloc] init];
        
        for(NSDictionary *responseBike in responseStation[@"bikes"]){
            Bike *bike = [Bike bikeWithId:responseBike[@"id"] number:responseBike[@"number"]];
            [bikes addObject:bike];
        }
        
        station = [[Station alloc] init];
        station.station_id = responseStation[@"id"];
        station.bikes = bikes;
        station.location = CLLocationCoordinate2DMake([responseStation[@"lat"] doubleValue], [responseStation[@"lon"] doubleValue]);
    }
    
    return station;
}

@end
