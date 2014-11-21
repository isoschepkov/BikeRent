//
//  Compatibility.h
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
* iOS8 -> iOS7
*/
@interface Compatibility : NSObject

+ (void)registerForNotifications;
+ (NSString *)currencySymbol;

@end
