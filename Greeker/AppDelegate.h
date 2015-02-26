//
//  AppDelegate.h
//  Greeker
//
//  Created by Thohd on 4/11/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    NSTimer *timer;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableDictionary* user;
+ (AppDelegate*)sharedDelegate;
- (void) switchToTabView;

-(void) setUpdateLocation;

@end
