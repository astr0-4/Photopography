//
//  ViewController.h
//  Photopography
//
//  Created by Daniel Hooper on 2015-07-06.
//  Copyright (c) 2015 Daniel Hooper. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NSManagedObjectContext;

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

