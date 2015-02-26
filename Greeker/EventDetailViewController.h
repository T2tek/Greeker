//
//  EventDetailViewController.h
//  Greeker
//
//  Created by Thohd on 6/25/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDetailViewController : UIViewController
@property (nonatomic, strong) NSDictionary *eventData;
@property (nonatomic, strong) NSString  *eventId;
@end
