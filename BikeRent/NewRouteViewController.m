//
//  PayPalAuthViewController.m
//  BikeRent
//
//  Created by Ivan Oschepkov on 25.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "NewRouteViewController.h"
#import "RideViewController.h"
#import "PayPalMobile.h"
#import "ClientInfo.h"
#import "Ride.h"
#import "Bike.h"
#import "MBProgressHUD.h"

#import <Parse/Parse.h>

@interface NewRouteViewController () <PayPalFuturePaymentDelegate>{
    NSString *correlationId;
    NSString *authCode;
}
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@property (weak, nonatomic) IBOutlet UIButton *payPalButton;
@property (weak, nonatomic) IBOutlet UIButton *goButton;

@property (nonatomic, strong, readwrite) PayPalConfiguration *payPalConfiguration;
@end

@implementation NewRouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self br_setTitle:@"New Ride"];
    self.navigationController.navigationBar.topItem.title = @"";
    
    _payPalConfiguration = [[PayPalConfiguration alloc] init];
    _payPalConfiguration.merchantName = @"Cool Bike Rent";
    _payPalConfiguration.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.omega.supreme.example/privacy"];
    _payPalConfiguration.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.omega.supreme.example/user_agreement"];
    
    self.priceLabel.textColor = [UIColor br_defaultBlueColor];
    self.currencyLabel.textColor = [UIColor br_defaultBlueColor];
    
    [self.payPalButton addTarget:self action:@selector(paypalButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.goButton.backgroundColor = [UIColor br_defaultBlueColor];
    self.goButton.layer.cornerRadius = self.goButton.frame.size.height / 2;
    self.goButton.layer.masksToBounds = YES;
    [self.goButton addTarget:self action:@selector(goButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.goButton.enabled = NO;
    self.goButton.alpha = 0.2f;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Start out working with the mock environment. When you are ready, switch to PayPalEnvironmentProduction.
    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
}

- (IBAction)paypalButtonClick:(id)sender{
    correlationId = [PayPalMobile applicationCorrelationIDForEnvironment:PayPalEnvironmentProduction];
    [self obtainConsent];
}
- (IBAction)goButtonClick:(id)sender{
    if(authCode && correlationId){
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{@"bike_id":@"4654283186241536",
                                                                                       @"paypal_auth_code": authCode,
                                                                                       @"app_corellation_id":correlationId}];
        if([ClientInfo sharedInstance].clientId){
            [params setObject:[ClientInfo sharedInstance].clientId forKey:@"user_id"];
        }
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[BRAPIClient sharedClient] POST:@"rent/start"
                              parameters:params
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     NSLog(@"%@", responseObject);
                                     [[ClientInfo sharedInstance] setNewClientId:responseObject[@"user_id"]];
                                     
                                     [[Ride sharedInstance] startNewRide];
                                     [[Ride sharedInstance] changeRideId:responseObject[@"ride_id"]];
                                     
                                     [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"channel_%@", [Ride sharedInstance].rideId]];
                                     
                                     [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                     RideViewController *rideVC = [RideViewController new];
                                     [self.navigationController pushViewController:rideVC animated:YES];
                                 }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     NSLog(@"%@", error);
                                     
                                     [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                     
                                     [[[UIAlertView alloc] initWithTitle:@"Error!"
                                                                 message:@"Unexpected Error. Please try again"
                                                                delegate:self
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil] show];
                                 }];
    }
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
    // User cancelled login. Dismiss the PayPalLoginViewController, breathe deeply.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalFuturePaymentViewController:(PayPalFuturePaymentViewController *)futurePaymentViewController
                didAuthorizeFuturePayment:(NSDictionary *)futurePaymentAuthorization {
    // The user has successfully logged into PayPal, and has consented to future payments.
    
    NSLog(@"%@", futurePaymentAuthorization);
    authCode = futurePaymentAuthorization[@"response"][@"code"];
    
    if(![Ride sharedInstance].active){
        self.goButton.enabled = YES;
        self.goButton.alpha = 1.0f;
    }
    
    // Be sure to dismiss the PayPalLoginViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
