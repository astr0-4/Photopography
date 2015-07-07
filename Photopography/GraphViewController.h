//
//  GraphViewController.h
//  Photopography
//
//  Created by Daniel Hooper on 2015-07-07.
//  Copyright (c) 2015 Daniel Hooper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMSimpleLineGraphView.h"

@interface GraphViewController : UIViewController <BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>

@property (weak, nonatomic) IBOutlet UIView *graphView;


@end
