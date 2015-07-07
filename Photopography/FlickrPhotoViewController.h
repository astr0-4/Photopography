//
//  FlickrPhotoViewController.h
//  
//
//  Created by Alex on 2015-07-04.
//
//

#import <UIKit/UIKit.h>
#import "Photo.h"
#import <CoreData/CoreData.h>
#import <INTULocationManager/INTULocationManager.h>
#import "NSString+Words.h"

@interface FlickrPhotoViewController : UICollectionViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (assign, nonatomic) BOOL initialLocationSet;
@property (strong, nonatomic) NSArray *photoObjects;
@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic) CLLocationDegrees latitude;


@end
