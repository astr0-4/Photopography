//
//  Photo.h
//  FlickrGetter
//
//  Created by Alex on 2015-07-04.
//  Copyright (c) 2015 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject

@property (nonatomic, strong) NSString *farm;
@property (nonatomic, strong) NSString *photoID;
@property (nonatomic, strong) NSString *secret;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSString *photoLocation;
@property (nonatomic, strong) NSString *photoTitle;
@property (nonatomic, strong) NSString *photographer;

@end
