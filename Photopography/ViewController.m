//
//  ViewController.m
//  Photopography
//
//  Created by Daniel Hooper on 2015-07-06.
//  Copyright (c) 2015 Daniel Hooper. All rights reserved.
//

#import "ViewController.h"
#import <INTULocationManager/INTULocationManager.h>
#import "FlickrPhotoViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *requestCurrentLocationButton;

@property (assign, nonatomic) INTULocationRequestID locationRequestID;

@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic) CLLocationDegrees latitude;
//@property (strong, nonatomic) Location *userLocation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 //   [self startSingleLocationRequest];
    [self getLocationUpdates];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-30);
    verticalMotionEffect.maximumRelativeValue = @(30);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-30);
    horizontalMotionEffect.maximumRelativeValue = @(30);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
    [self.backgroundImageView addMotionEffect:group];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark startSingleLocationRequest

//subscribe to updates instead of single location request

//- (void)startSingleLocationRequest {
//    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
//    self.locationRequestID = [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyBlock
//                                                                timeout:10
//                                                                  block:
//                              ^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
//                                  
//                                  if (status == INTULocationStatusSuccess) {
//                                      self.userLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
//                                      self.userLocation.latitude = currentLocation.coordinate.latitude;
//                                      self.userLocation.longitude = currentLocation.coordinate.longitude;
//                                      
//                                      NSLog (@"coordinate 1: %f, coordinate 2: %f\n", self.userLocation.longitude, self.userLocation.latitude);
//                                      
//                                  }
//                              }];
//}

-(void)getLocationUpdates {
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    self.locationRequestID = [locMgr subscribeToLocationUpdatesWithBlock:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        NSLog(@"current location: %f, %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
      //  self.userLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
                                              self.latitude = currentLocation.coordinate.latitude;
                                              self.longitude = currentLocation.coordinate.longitude;
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showPhotos"]){
    FlickrPhotoViewController *destinationViewController = (FlickrPhotoViewController *)segue.destinationViewController;
    destinationViewController.managedObjectContext = self.managedObjectContext;
        destinationViewController.latitude = self.latitude;
        destinationViewController.longitude = self.longitude;
    }
}




@end

