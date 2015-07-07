//
//  NSString+Words.m
//  RottenMangoes
//
//  Created by Alex on 2015-07-03.
//  Copyright (c) 2015 Alex. All rights reserved.
//

#import "NSString+Words.h"

@implementation NSString (Words)

-(NSString *)getFirstWord {
    return [[self componentsSeparatedByString:@" "] firstObject];
}

@end
