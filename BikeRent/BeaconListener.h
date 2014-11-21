//
//  BeaconListener.h
//  BikeRent
//
//  Created by Ivan Oschepkov on 25.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BeaconListener;
@protocol BeaconListenerDelegate <NSObject>

@required
- (void)didEnterInRegionWithUUID:(NSString *)uuid;
- (void)didExitFromRegion;

@end

@interface BeaconListener : NSObject

@property (weak, nonatomic) id<BeaconListenerDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)startMonitoring;

@end