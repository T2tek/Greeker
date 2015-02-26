//
//  LocationAnnotation.h
//  Greeker
//
//  Created by Hoang Nguyen on 15/10/2014.
//  Copyright (c) Năm 2014 Thohd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LocationAnnotation : NSObject<MKAnnotation>

@property (strong, nonatomic) NSString *locationTitle;
@property (strong, nonatomic) NSString *locationAddress;
@property (nonatomic) CLLocationCoordinate2D locationCoordinate;

@end
