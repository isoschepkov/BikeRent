//
//  RideViewController.m
//  BikeRent
//
//  Created by Ivan Oschepkov on 26.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "RideViewController.h"
#import "Station.h"
#import "Ride.h"

#import "GoogleMaps.h"

@interface RideViewController ()
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalSumLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeToNextLabel;
@property (weak, nonatomic) IBOutlet UILabel *sumOnNextStepLabel;
@property (weak, nonatomic) IBOutlet UIView *mapViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (strong, nonatomic) Ride *ride;
@property (strong, nonatomic) NSMutableArray *stations;

@property (strong, nonatomic) GMSMapView *mapView;

@end

@implementation RideViewController

- (void)viewDidLoad{
    
    [self br_setTitle:@"Ride Info"];
    self.navigationController.navigationBar.topItem.title = @"";
    
    self.ride = [Ride sharedInstance];
    self.stations = [[NSMutableArray alloc] init];
    
    self.totalTimeLabel.textColor = [UIColor br_defaultBlueColor];
    self.totalSumLabel.textColor = [UIColor br_defaultBlueColor];
    self.timeToNextLabel.textColor = [UIColor br_defaultBlueColor];
    self.sumOnNextStepLabel.textColor = [UIColor br_defaultBlueColor];
    self.bottomLabel.textColor = [UIColor br_defaultBlueColor];
    self.separatorView.backgroundColor = [UIColor br_defaultGreenColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataChangedNotification:) name:NOTIFICATION_RIDE_DATA_CHANGED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewStateNotification:) name:NOTIFICATION_NEW_STAGE object:nil];
    
    [Ride sharedInstance];
    [self handleDataChangedNotification:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [[LocationHelper sharedInstance] updateLocationWithCallback:^(CLLocation *location) {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                                                longitude:location.coordinate.longitude
                                                                     zoom:12.f];
        CGRect rect = self.mapViewContainer.frame;
        rect.origin.y = 0;
        rect.origin.x = 0;
        self.mapView = [GMSMapView mapWithFrame:rect camera:camera];
        [self.mapViewContainer addSubview:self.mapView];
        
        [self updateStationsInfo];
        [self updateUsersInfo];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kBRAutoTransitionNotification object:nil]];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleDataChangedNotification:(NSNotification *)notification{
    self.totalSumLabel.text = [NSString stringWithFormat:@"Total %d $", (int)self.ride.totalSum];
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d in use", self.ride.totalTime / 3600, (self.ride.totalTime % 3600) / 60, self.ride.totalTime % 60];
    
    self.sumOnNextStepLabel.text = [NSString stringWithFormat:@"%d $/Hour", (int)self.ride.sumOnNextStep];
    self.timeToNextLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", self.ride.timeToNextStep / 3600, (self.ride.timeToNextStep % 3600) / 60, self.ride.timeToNextStep % 60];
}

- (void)handleNewStateNotification:(NSNotification *)notification{
    [[[UIAlertView alloc] initWithTitle:@""
                                message:[NSString stringWithFormat:@"You total sum has increased to %d", (int)self.ride.totalSum]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)updateStationsInfo{
    [[BRAPIClient sharedClient] GET:@"stations"
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                NSLog(@"%@", responseObject);
                                for (NSDictionary *responseStation in responseObject[@"stations"]){
                                    [self.stations addObject:[Station stationFromResponseObject:responseStation]];
                                }
                                
                                for(Station *station in self.stations){
                                    GMSMarker *marker = [[GMSMarker alloc] init];
                                    marker.position = station.location;
                                    marker.snippet = [NSString stringWithFormat:@"Available bicycles: %d", [station.bikes count]];
                                    
                                    marker.map = self.mapView;
                                }
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                            }];
}

- (void)updateUsersInfo{
    [[BRAPIClient sharedClient] GET:@"need_bike"
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                NSLog(@"%@", responseObject);
                                
                                for(NSDictionary *user in responseObject[@"users"]){
                                    GMSMarker *marker = [[GMSMarker alloc] init];
                                    marker.position = CLLocationCoordinate2DMake([user[@"lat"] doubleValue], [user[@"lon"] doubleValue]);
                                    marker.map = self.mapView;
                                }
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                            }];
}

@end
