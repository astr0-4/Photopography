//
//  GraphViewController.h
//  Photopography
//
//  Created by Daniel Hooper on 2015-07-07.
//  Copyright (c) 2015 Daniel Hooper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMSimpleLineGraphView.h"
#import <CoreLocation/CoreLocation.h>
#import <INTULocationManager/INTULocationManager.h>

@interface GraphViewController : UIViewController <BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>

@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *graphView;

@property (strong, nonatomic) NSString *firstDay;
@property (strong, nonatomic) NSString *lastDay;

@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic) CLLocationDegrees latitude;

@end
