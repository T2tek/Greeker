//
//  MemberAnnotation.h
//  Greeker
//
//  Created by Hoang Nguyen on 9/1/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MemberAnnotation : NSObject<MKAnnotation>

@property (nonatomic, strong) NSDictionary * memberData;

@end
