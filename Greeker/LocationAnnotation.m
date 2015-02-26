//
//  LocationAnnotation.m
//  Greeker
//
//  Created by Hoang Nguyen on 15/10/2014.
//  Copyright (c) Năm 2014 Thohd. All rights reserved.
//

#import "LocationAnnotation.h"

@implementation LocationAnnotation


-(NSString*) title
{
    return [NSString stringWithFormat:@"%@ (%@)", self.locationTitle, self.locationAddress];
}

-(CLLocationCoordinate2D) coordinate {
    return self.locationCoordinate;
}

@end
