//
//  UIColor+Default.m
//  BikeRent
//
//  Created by Ivan Oschepkov on 25.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "UIColor+Default.h"

@implementation UIColor (Default)

+ (UIColor *)br_defaultBlueColor{
    return [UIColor colorWithRed:52./255 green:93./255 blue:213./255 alpha:1.0f];
}

+ (UIColor *)br_defaultGreenColor{
    return [UIColor colorWithRed:63./255 green:208./255 blue:150./255 alpha:1.0f];
}

+ (UIColor *)br_defaultGrayColor{
    return [UIColor colorWithWhite:0.90 alpha:1.0f];
}

@end
