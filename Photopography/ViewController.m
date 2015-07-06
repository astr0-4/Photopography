//
//  ViewController.m
//  Photopography
//
//  Created by Daniel Hooper on 2015-07-06.
//  Copyright (c) 2015 Daniel Hooper. All rights reserved.
//

#import "ViewController.h"
#import <INTULocationManager/INTULocationManager.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *requestCurrentLocationButton;

@property (assign, nonatomic) INTULocationRequestID locationRequestID;

@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

- (void)startSingleLocationRequest
{
    __weak __typeof(self) weakSelf = self;
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    self.locationRequestID = [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyBlock
                                                                timeout:10
                                                                  block:
                              ^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                  __typeof(weakSelf) strongSelf = weakSelf;
                                  
                                  if (status == INTULocationStatusSuccess) {
                                      // achievedAccuracy is at least the desired accuracy (potentially better)
                                      strongSelf.statusLabel.text = [NSString stringWithFormat:@"Location request successful! Current Location:\n%@", currentLocation];
                                  }
                                  else if (status == INTULocationStatusTimedOut) {
                                      // You may wish to inspect achievedAccuracy here to see if it is acceptable, if you plan to use currentLocation
                                      strongSelf.statusLabel.text = [NSString stringWithFormat:@"Location request timed out. Current Location:\n%@", currentLocation];
                                  }
                                  else {
                                      // An error occurred
//                                      strongSelf.statusLabel.text = [strongSelf getErrorDescription:status];
                                  }
                                  
                                  self.longitude = currentLocation.coordinate.longitude;
                                  self.latitude = currentLocation.coordinate.latitude;
                                  NSLog (@"coordinate 1: %f, coordinate 2: %f\n", self.longitude, self.latitude);

                                  
//                                  strongSelf.locationRequestID = NSNotFound;
                              }];
}

- (IBAction)startButtonTapped:(id)sender {
    [self startSingleLocationRequest];
}






@end

