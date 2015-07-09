//
//  Photo.h
//  
//
//  Created by Alex on 2015-07-09.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@class Location;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * farm;
@property (nonatomic, retain) NSDate * photoDate;
@property (nonatomic, retain) NSString * photographer;
@property (nonatomic, retain) NSString * photoID;
@property (nonatomic, retain) NSString * photoCountry;
@property (nonatomic, retain) NSString * photoTitle;
@property (nonatomic, retain) NSString * secret;
@property (nonatomic, retain) NSString * server;
@property (nonatomic, retain) NSString * photoCity;
@property (nonatomic, retain) Location *userLocation;
@property (nonatomic, strong) UIImage *photoImage;

@end
