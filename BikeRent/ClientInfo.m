//
//  ClientInfo.m
//  BikeRent
//
//  Created by Ivan Oschepkov on 25.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "ClientInfo.h"

@implementation ClientInfo

+ (id)sharedInstance {
    static dispatch_once_t once;
    static ClientInfo *instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _clientId = [[NSUserDefaults standardUserDefaults] stringForKey:@"clientId"] ?: nil;
    }
    return self;
}

- (void)setNewClientId:(NSString *)clientId{
    if(clientId){
        _clientId = clientId;
        
        [self synchronise];
    }
}

- (void)synchronise{
    [[NSUserDefaults standardUserDefaults] setObject:self.clientId forKey:@"clientId"];
}

@end
