//
//  UIViewController+Appearance.m
//  BikeRent
//
//  Created by Ivan Oschepkov on 25.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "UIViewController+Appearance.h"

@implementation UIViewController (Appearance)

- (void)br_setTitle:(NSString *)title {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 44)];
    titleLabel.textColor = [UIColor colorWithRed:60./255 green:60./255 blue:60./255 alpha:1.];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Helvetica Light" size:24];
    titleLabel.text = title;
    [self.navigationItem setTitleView:titleLabel];
}

@end
