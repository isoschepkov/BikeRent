//
//  ClientInfo.h
//  BikeRent
//
//  Created by Ivan Oschepkov on 25.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClientInfo : NSObject

@property (strong, nonatomic, readonly) NSString *clientId;

+ (instancetype)sharedInstance;

- (void)setNewClientId:(NSString *)clientId;

@end
