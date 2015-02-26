//
//  Utility.m
//  MoveCar
//
//  Created by Thohd on 5/29/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (NSString*) convertDate:(NSString*)dateString formatFrom:(NSString*)fromFormat toFormat:(NSString*)toFormat
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:fromFormat];
    NSDate* date = [formatter dateFromString:dateString];
    [formatter setDateFormat:toFormat];
    return [formatter stringFromDate:date];
}
+ (NSInteger) ageFromBirth:(NSDate*)birth
{
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:birth
                                       toDate:[NSDate date]
                                       options:0];
    return [ageComponents year];

}
+ (NSString *) currentDate
{
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDate = [DateFormatter stringFromDate:[NSDate date]];
    return currentDate;
}
@end
