//
// Created by Sergey Pronin on 9/23/13.
// Copyright (c) 2013 Empatika. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

@interface BRAPIClient : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;

@end