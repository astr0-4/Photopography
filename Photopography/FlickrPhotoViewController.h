//
//  FlickrPhotoViewController.h
//  
//
//  Created by Alex on 2015-07-04.
//
//

#import <UIKit/UIKit.h>
#import "Photo.h"
#import "Location.h"
#import <CoreData/CoreData.h>
#import <INTULocationManager/INTULocationManager.h>
#import "NSString+Words.h"

@interface FlickrPhotoViewController : UICollectionViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Location *userLocation;
@end
