//
//  FlickrPhotoViewController.h
//  
//
//  Created by Alex on 2015-07-04.
//
//

#import <UIKit/UIKit.h>
#import "Photo.h"
#import <CoreLocation/CoreLocation.h>


@interface FlickrPhotoViewController : UICollectionViewController

@property (assign, nonatomic) BOOL initialLocationSet;
@property (strong, nonatomic) NSArray *photoObjects;
@property (strong, nonatomic) CLLocation *userLocation;

@end
