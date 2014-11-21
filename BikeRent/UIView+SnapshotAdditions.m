//
// Created by Sergey Pronin on 8/23/13.
// Copyright (c) 2013 Empatika. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "UIView+SnapshotAdditions.h"


@implementation UIView (SnapshotAdditions)

- (UIImage *)snapshotImage {
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.f);
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
        UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return snapshot;
    } else {
        return nil;
    }
}

@end