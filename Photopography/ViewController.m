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
@property (nonatomic, strong) NSMutableArray *locations;

@end

@implementation ViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
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
-(CLLocation *)getRandomLocation{
    self.locations = [[NSMutableArray alloc] init];
    
    //alloc and init all the locations for the array
    CLLocation *newYork =[[CLLocation alloc] initWithLatitude:40.712784 longitude:-74.005941];
    [self.locations addObject:newYork];
    CLLocation *vancouver = [[CLLocation alloc] initWithLatitude:49.284905 longitude:-123.143692];
    [self.locations addObject:vancouver];
    CLLocation *moscow = [[CLLocation alloc] initWithLatitude:55.755826 longitude:37.617300];
    [self.locations addObject:moscow];
    CLLocation *tokyo = [[CLLocation alloc] initWithLatitude:35.685360 longitude:139.753372];
    [self.locations addObject:tokyo];
    CLLocation *italy =[[CLLocation alloc] initWithLatitude:44.128109 longitude:9.712391];
    [self.locations addObject:italy];
    CLLocation *sanFrancisco = [[CLLocation alloc] initWithLatitude:37.774929 longitude:-122.419416];
    [self.locations addObject:sanFrancisco];
    CLLocation *berlin = [[CLLocation alloc] initWithLatitude:52.516640 longitude:13.402318];
    [self.locations addObject:berlin];
    CLLocation *budapest = [[CLLocation alloc] initWithLatitude:47.501896 longitude:19.035133];
    [self.locations addObject:budapest];
    CLLocation *romeColosseum = [[CLLocation alloc] initWithLatitude:41.890251 longitude:12.492373];
    [self.locations addObject:romeColosseum];
    CLLocation *parisLouvre = [[CLLocation alloc] initWithLatitude:48.860294 longitude:2.338629];
    [self.locations addObject:parisLouvre];
    CLLocation *boraBora = [[CLLocation alloc] initWithLatitude:-16.500413 longitude:-151.74149];
    [self.locations addObject:boraBora];
    CLLocation *stonehenge = [[CLLocation alloc] initWithLatitude:51.179531 longitude:-1.828945];
    [self.locations addObject:stonehenge];
    CLLocation *iceland = [[CLLocation alloc] initWithLatitude:64.135338 longitude:-21.89521];
    [self.locations addObject:iceland];
    CLLocation *pyramidsEgypt = [[CLLocation alloc] initWithLatitude:29.976480 longitude:31.131302];
    [self.locations addObject:pyramidsEgypt];
    CLLocation *chernobyl = [[CLLocation alloc] initWithLatitude:51.405556 longitude:30.056944];
    [self.locations addObject:chernobyl];
    CLLocation *petraJordan =[[CLLocation alloc] initWithLatitude:30.322003 longitude:35.451605];
    [self.locations addObject:petraJordan];
    CLLocation *dubrovnik =[[CLLocation alloc] initWithLatitude:42.641573 longitude:18.116133];
    [self.locations addObject:dubrovnik];
//    CLLocation *ago =[[CLLocation alloc] initWithLatitude:43.6536066 longitude:-79.3925123];
//    [self.locations addObject:ago];
    

    NSUInteger randomIndex = arc4random() % [self.locations count];
    
    return [self.locations objectAtIndex:randomIndex];
}

#pragma mark getLocationUpdates


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
    if([segue.identifier isEqualToString:@"feelingLucky"]) {
        FlickrPhotoViewController *destinationViewController = (FlickrPhotoViewController *)segue.destinationViewController;
        destinationViewController.managedObjectContext = self.managedObjectContext;
        
        CLLocation *randomLocation = [self getRandomLocation];
        destinationViewController.latitude = randomLocation.coordinate.latitude;
        destinationViewController.longitude = randomLocation.coordinate.longitude;
    }
}




@end

