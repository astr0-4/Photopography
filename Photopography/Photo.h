//
//  Photo.h
//  
//
//  Created by Alex on 2015-07-07.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * farm;
@property (nonatomic, retain) NSString * photoID;
@property (nonatomic, retain) NSString * secret;
@property (nonatomic, retain) NSString * server;
@property (nonatomic, retain) NSString * photoLocation;
@property (nonatomic, retain) NSString * photoTitle;
@property (nonatomic, retain) NSString * photographer;
@property (nonatomic, retain) NSDate * photoDate;
@property (nonatomic, retain) Location *userLocation;

@end
