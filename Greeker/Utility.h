//
//  Utility.h
//  MoveCar
//
//  Created by Thohd on 5/29/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

+ (NSString*) convertDate:(NSString*)dateString formatFrom:(NSString*)fromFormat toFormat:(NSString*)toFormat;
+ (NSInteger) ageFromBirth:(NSDate*)birth;
+ (NSString *) currentDate;
@end
