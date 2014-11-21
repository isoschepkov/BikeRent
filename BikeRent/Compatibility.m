//
//  Compatibility.m
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "Compatibility.h"

@implementation Compatibility

+ (NSString *)currencySymbol {
    return NSLocalizedString(@"руб.", nil);
}

+ (void)registerForNotifications {
    if([Compatibility systemVersionGreaterOrEqualThan:@"8.0"]){
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound
                                          categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
}

+ (BOOL)systemVersionGreaterOrEqualThan:(NSString *)version{
    NSString *currentSystemVersion = [[UIDevice currentDevice] systemVersion];
    return [currentSystemVersion compare:version] != NSOrderedAscending;
}

@end
