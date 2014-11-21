//
//  ViewController.m
//  BikeRent
//
//  Created by Ivan Oschepkov on 25.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "StartViewController.h"
#import "QRCodeViewController.h"
#import "QRCodeScannerViewController.h"
#import "NewRouteViewController.h"
#import "RideViewController.h"
#import "BeaconListener.h"
#import "PayPalMobile.h"
#import "MBProgressHUD.h"

#import "Station.h"
#import "Bike.h"
#import "Ride.h"
#import "ClientInfo.h"

#import <BlocksKit/UIGestureRecognizer+BlocksKit.h>

@interface StartViewController () <QRCodeScannerVCDelegate, BeaconListenerDelegate, PayPalFuturePaymentDelegate>{
    BOOL autoMoved;
    NSString *correlationId;
    NSString *authCode;
}
@property (weak, nonatomic) IBOutlet UILabel *wantTakeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *wantTakeSwitch;
@property (weak, nonatomic) IBOutlet UIButton *giveBikeButton;
@property (weak, nonatomic) IBOutlet UIButton *takeBikeButton;

@property (strong, nonatomic) UIButton *orderButton;
@property (strong, nonatomic) Station *nearestStation;

@property (nonatomic, strong, readwrite) PayPalConfiguration *payPalConfiguration;

@property (strong, nonatomic) NSString *rideId;

@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self br_setTitle:@"Bike Rent"];
    self.navigationController.navigationBar.topItem.title = @"";
    
    _payPalConfiguration = [[PayPalConfiguration alloc] init];
    _payPalConfiguration.merchantName = @"Ultramagnetic Omega Supreme";
    _payPalConfiguration.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.omega.supreme.example/privacy"];
    _payPalConfiguration.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.omega.supreme.example/user_agreement"];
    
    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
    
    self.giveBikeButton.backgroundColor = [UIColor br_defaultBlueColor];
    self.giveBikeButton.layer.cornerRadius = self.giveBikeButton.frame.size.height / 2;
    self.giveBikeButton.layer.masksToBounds = YES;
    [self.giveBikeButton addTarget:self action:@selector(giveBikeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.takeBikeButton.backgroundColor = [UIColor br_defaultGreenColor];
    self.takeBikeButton.layer.cornerRadius = self.giveBikeButton.frame.size.height / 2;
    self.takeBikeButton.layer.masksToBounds = YES;
    [self.takeBikeButton addTarget:self action:@selector(takeBikeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.wantTakeLabel.textColor = [UIColor lightGrayColor];
    
    self.wantTakeSwitch.onTintColor = [UIColor br_defaultBlueColor];
    self.wantTakeSwitch.on = NO;
    [self.wantTakeSwitch addTarget:self action:@selector(wantSwitchClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupNewOrderButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processRemotePush) name:kBRRideStatusUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableAutoMove) name:kBRAutoTransitionNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [self reloadButtons];
}

- (void)viewDidAppear:(BOOL)animated{
    /*BeaconListener *beaconListener = [BeaconListener sharedInstance];
    beaconListener.delegate = self;
    [beaconListener startMonitoring];*/
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self didEnterInRegionWithUUID:@"FC51BCB2-4E98-437A-A96F-146EDDED4061"];
    });
    
    if([Ride sharedInstance].active && !autoMoved){
        [self goToExistingRideScreen];
        autoMoved = YES;
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadButtons{
    if([Ride sharedInstance].active){
        self.wantTakeSwitch.enabled = NO;
        self.wantTakeSwitch.on = NO;
        
        self.takeBikeButton.enabled = NO;
        self.takeBikeButton.alpha = 0.2f;
        
        self.giveBikeButton.enabled = YES;
        self.giveBikeButton.alpha = 1.0f;
        
        self.orderButton.enabled = NO;
        self.orderButton.alpha = 0.2f;
    } else {
        self.takeBikeButton.enabled = YES;
        self.takeBikeButton.alpha = 1.0f;
        self.giveBikeButton.enabled = NO;
        self.giveBikeButton.alpha = 0.2f;
    }
}

- (IBAction)giveBikeButtonClick:(id)sender{
    QRCodeViewController *qrVC = [QRCodeViewController new];
    [self.navigationController pushViewController:qrVC animated:YES];
}

- (IBAction)takeBikeButtonClick:(id)sender{
    QRCodeScannerViewController *qrScannerVC = [QRCodeScannerViewController new];
    qrScannerVC.delegate = self;
    [self.navigationController pushViewController:qrScannerVC animated:YES];
}

- (IBAction)wantSwitchClick:(UISwitch *)switchControl{
    if(switchControl.on){
        self.wantTakeLabel.textColor = [UIColor br_defaultBlueColor];
        
        [[LocationHelper sharedInstance] updateLocationWithCallback:^(CLLocation *location) {
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            if([ClientInfo sharedInstance].clientId){
                [params setObject:[ClientInfo sharedInstance].clientId forKey:@"user_id"];
            }
            [params setObject:[NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude]
                       forKey:@"coordinates"];
            
            [[BRAPIClient sharedClient] POST:@"need_bike/new"
                                  parameters:params
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSLog(@"%@", responseObject);
                                         
                                         [[ClientInfo sharedInstance] setNewClientId:responseObject[@"user_id"]];
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"%@", error);
                                         
                                         switchControl.on = !switchControl.on;
                                     }];
        }];
    } else {
        self.wantTakeLabel.textColor = [UIColor lightGrayColor];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        if([ClientInfo sharedInstance].clientId){
            [params setObject:[ClientInfo sharedInstance].clientId forKey:@"user_id"];
        }
        
        [[BRAPIClient sharedClient] DELETE:@"need_bike/delete"
                                parameters:params
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       NSLog(@"%@", responseObject);
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"%@", error);
                                       switchControl.on = !switchControl.on;
                                   }];
    }
}

- (void)setupNewOrderButton{
    self.orderButton = [[UIButton alloc] initWithFrame:CGRectMake(self.takeBikeButton.frame.origin.x, self.view.frame.size.height, self.takeBikeButton.frame.size.width, self.takeBikeButton.frame.size.height)];
    [self.orderButton addTarget:self action:@selector(showNewOrderViewController) forControlEvents:UIControlEventTouchUpInside];
    
    self.orderButton.backgroundColor = [UIColor br_defaultGreenColor];
    [self.orderButton setTitle:@"Bike Station" forState:UIControlStateNormal];
    self.orderButton.titleLabel.textColor = self.takeBikeButton.titleLabel.textColor;
    self.orderButton.titleLabel.font = self.takeBikeButton.titleLabel.font;
    self.orderButton.layer.cornerRadius = self.takeBikeButton.layer.cornerRadius;
    self.orderButton.layer.masksToBounds = YES;
    
    [self.view addSubview:self.orderButton];
}

- (void)disableAutoMove{
    autoMoved = YES;
}

- (void)goToExistingRideScreen{
    RideViewController *rideVC = [RideViewController new];
    [self.navigationController pushViewController:rideVC animated:YES];
}

- (void)showNewOrderViewController{
    NewRouteViewController *newRouteVC = [[NewRouteViewController alloc] init];
    newRouteVC.bikes = self.nearestStation.bikes;
    [self.navigationController pushViewController:newRouteVC animated:YES];
}

- (void)showStationNotification{
    if(self.orderButton.frame.origin.y >= self.view.frame.size.height && ![Ride sharedInstance].active){
        CGRect rect = self.orderButton.frame;
        rect.origin.y = self.giveBikeButton.frame.origin.y + self.giveBikeButton.frame.size.height + 8;
        
        [UIView animateWithDuration:0.3f
                         animations:^{
                             self.orderButton.frame = rect;
                         }];
    }
}

- (void)hideStationNotification{
    CGRect rect = self.orderButton.frame;
    rect.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:3.f
                     animations:^{
                         self.orderButton.frame = rect;
                     }];
}

- (void)processRemotePush{
    [self reloadButtons];
}

#pragma mark - BeaconListenerDelegate

- (void)didEnterInRegionWithUUID:(NSString *)uuid{
    [self findStationByBeacon:uuid WithCompletionHandler:^(Station *station) {
        [self showStationNotification];
    }];
}

- (void)didExitFromRegion{
    [self hideStationNotification];
}

#pragma mark - QRCodeScannerVCDelegate

- (void)qrCodeScannerVCDidScanWithSuccess:(NSString *)value{
    self.rideId = value;
    
    correlationId = [PayPalMobile applicationCorrelationIDForEnvironment:PayPalEnvironmentProduction];
    [self obtainConsent];
}

#pragma mark - server methods

- (void)findStationByBeacon:(NSString *)uuid WithCompletionHandler:(void (^)(Station *station))handler{
    [[BRAPIClient sharedClient] GET:@"stations"
                         parameters:@{@"beacon_uuid": uuid}
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                NSLog(@"%@", responseObject);
                                NSDictionary *responseStation = responseObject[@"station"];
                                
                                Station *station = [Station stationFromResponseObject:responseStation];
                                
                                self.nearestStation = station;
                                
                                if([station.bikes count] > 0){
                                    handler(station);
                                }
                                
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                            }];
}

- (void)closeOtherUserRideAndStartNew{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"paypal_auth_code":authCode,
                                                                                  @"app_correlation_id":correlationId}];
    if([ClientInfo sharedInstance].clientId){
        [params setObject:[ClientInfo sharedInstance].clientId forKey:@"new_user_id"];
        [params setObject:self.rideId forKey:@"ride_id"];
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[BRAPIClient sharedClient] POST:@"rent/stop"
                          parameters:params
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 NSLog(@"%@", responseObject);
                                 [[ClientInfo sharedInstance] setNewClientId:responseObject[@"user_id"]];
                                 [[Ride sharedInstance] stopCurrentRide];
                                 [[Ride sharedInstance] startNewRide];
                                 [[Ride sharedInstance] changeRideId: responseObject[@"ride_id"]];
                                 
                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                 
                                 [self goToExistingRideScreen];
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"%@", error);
                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                 
                                 [[[UIAlertView alloc] initWithTitle:@"Error!"
                                                             message:@"Unexpected error, please try again"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil] show];
                             }];
}

#pragma mark - PayPal methods

- (void)obtainConsent {
    
    PayPalFuturePaymentViewController *fpViewController;
    fpViewController = [[PayPalFuturePaymentViewController alloc] initWithConfiguration:self.payPalConfiguration
                                                                               delegate:self];
    
    // Present the PayPalFuturePaymentViewController
    [self presentViewController:fpViewController animated:YES completion:nil];
}

#pragma mark - PayPalFuturePaymentDelegate

- (void)payPalFuturePaymentDidCancel:(PayPalFuturePaymentViewController *)futurePaymentViewController {
    [[[UIAlertView alloc] initWithTitle:@"Error!"
                                message:@"Cannot login in PayPal"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalFuturePaymentViewController:(PayPalFuturePaymentViewController *)futurePaymentViewController
                didAuthorizeFuturePayment:(NSDictionary *)futurePaymentAuthorization {
    // The user has successfully logged into PayPal, and has consented to future payments.
    
    NSLog(@"%@", futurePaymentAuthorization);
    authCode = futurePaymentAuthorization[@"response"][@"code"];
    
    [self closeOtherUserRideAndStartNew];
    
    // Be sure to dismiss the PayPalLoginViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
