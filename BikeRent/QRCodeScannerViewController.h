//
//  QRCodeScannerViewController.h
//  BikeRent
//
//  Created by Ivan Oschepkov on 25.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QRCodeScannerViewController;

@protocol QRCodeScannerVCDelegate <NSObject>
@required
- (void)qrCodeScannerVCDidScanWithSuccess:(NSString *)value;
@end

@interface QRCodeScannerViewController : UIViewController

@property (weak, nonatomic) id<QRCodeScannerVCDelegate> delegate;

@end
