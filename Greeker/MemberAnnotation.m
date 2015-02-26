//
//  MemberAnnotation.m
//  Greeker
//
//  Created by Hoang Nguyen on 9/1/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "MemberAnnotation.h"

@implementation MemberAnnotation

-(NSString*) title
{
    return [NSString stringWithFormat:@"%@ %@", self.memberData[@"first_name"], self.memberData[@"last_name"]];
}

-(CLLocationCoordinate2D) coordinate {
    CLLocationDegrees latitude;
    CLLocationDegrees longitude;
    if ([[self.memberData objectForKey:@"lat"] isKindOfClass:[NSNull class]]) {
         latitude = [[self.memberData objectForKey:@"lat"] doubleValue];
         longitude = [[self.memberData objectForKey:@"long"] doubleValue];
    } else  {
         latitude = [[self.memberData objectForKey:@"lat"] doubleValue];
         longitude = [[self.memberData objectForKey:@"long"] doubleValue];
    }
    return CLLocationCoordinate2DMake(latitude, longitude);
    
    
}

@end
