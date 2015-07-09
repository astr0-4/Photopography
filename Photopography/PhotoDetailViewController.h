//
//  PhotoDetailViewController.h
//  Photopography
//
//  Created by Alex on 2015-07-07.
//  Copyright (c) 2015 Daniel Hooper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"
#import "Location.h"

@interface PhotoDetailViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Photo *photo;
@property (strong, nonatomic) Location *location;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
