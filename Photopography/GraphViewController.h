//
//  GraphViewController.h
//  Photopography
//
//  Created by Daniel Hooper on 2015-07-08.
//  Copyright (c) 2015 Daniel Hooper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMSimpleLineGraphView.h"

@interface GraphViewController : UIViewController <BEMSimpleLineGraphDelegate, BEMSimpleLineGraphDataSource>

@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *graphView;

@end
