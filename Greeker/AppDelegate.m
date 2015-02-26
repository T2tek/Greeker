//
//  AppDelegate.m
//  Greeker
//
//  Created by Thohd on 4/11/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <MapKit/MapKit.h>
#import <AFNetworking/AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
@implementation AppDelegate

+ (AppDelegate*)sharedDelegate{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

-(void) setUser:(NSMutableDictionary *)user
{
    _user = user;
    if (user == nil) {
        return;
    }
}



-(void) setUpdateLocation
{
    if (locationManager == nil) {
        locationManager = [[CLLocationManager alloc] init];
    }
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if([CLLocationManager locationServicesEnabled]) {
        
        NSLog(@"Location Services Enabled");
        NSLog(@"AppDelegate: CLLocationManager authorizationStatus: %d", [CLLocationManager authorizationStatus]);
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"App Permission Denied"
                                                             message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
            [alert show];
        } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
        {
            if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [locationManager requestAlwaysAuthorization];
            }
        }
    }
    [self updateLocationToServer];
    timer = [NSTimer scheduledTimerWithTimeInterval: (5 * 60) target:self selector:@selector(updateLocationToServer) userInfo:nil repeats:YES];
}




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    application.applicationIconBadgeNumber = 0;
    // Override point for customization after application launch.
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:10.0f],
                                                        NSForegroundColorAttributeName : [UIColor blackColor]
                                                        } forState:UIControlStateSelected];
    
    
    // doing this results in an easier to read unselected state then the default iOS 7 one
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:10.0f],
                                                        NSForegroundColorAttributeName : [UIColor blackColor]
                                                        } forState:UIControlStateNormal];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor blackColor]];
    [[UITabBar appearance] setTintColor:[UIColor blackColor]];
    
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    if(launchOptions!=nil){
        NSString *msg = [NSString stringWithFormat:@"%@", launchOptions];
        NSLog(@"%@",msg);
        //[self createAlert:msg];
    }

    return YES;
}
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
   
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:token forKey:@"device_token"] ;
     NSLog(@"Device Token: %@ and after bam: %@", deviceToken, token);
//    [[[UIAlertView alloc] initWithTitle:@"token" message:token delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
    NSLog(@"Failed to register with error : %@", error);
//    [[[UIAlertView alloc] initWithTitle:@"token" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    application.applicationIconBadgeNumber = 0;
    //NSString *msg = [NSString stringWithFormat:@"%@", userInfo];
    NSDictionary * aps = userInfo[@"aps"];
    NSString *msg = aps[@"alert"];
    NSLog(@"%@",msg);
    [self createAlert:msg];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder"
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }

    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}

- (void)createAlert:(NSString *)msg {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message Received" message:[NSString stringWithFormat:@"%@", msg]delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

-(void) updateLocationToServer
{
    [locationManager startUpdatingLocation];
    NSLog(@"AppDelegate: locationManager startUpdatingLocation");
}


- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to get your location!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [errorAlert show];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location  = locations[0];
    
    NSDictionary * user = self.user;
    
    self.user[@"long"] = [NSString stringWithFormat: @"%.8f" ,location.coordinate.longitude];
    self.user[@"lat"] = [NSString stringWithFormat: @"%.8f" ,location.coordinate.latitude];
    
    NSLog(@"App Delegate DidUpdateLocation: %f, %f", location.coordinate.latitude, location.coordinate.latitude);
    
    NSDictionary *parameters =@{
                                @"user_id" : user[@"id"],
                                @"long" : [NSString stringWithFormat: @"%.8f" ,location.coordinate.longitude],
                                @"lat" : [NSString stringWithFormat: @"%.8f" ,location.coordinate.latitude]
                                };
    NSString * url = [kBASE_NEW_API stringByAppendingString:@"/updatelocation"];
    
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:url]];
    
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSObject *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
         NSLog(@"AppDelegate: Update location state: %@",jsons);
         [locationManager stopUpdatingLocation];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {

         NSLog(@"AppDelegate Send location to Server: %@", [operation error]);
         
     }];
    
    [operation start];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}
- (void) switchToTabView{
    UINavigationController* nav = (UINavigationController*)self.window.rootViewController;
    [nav popToRootViewControllerAnimated:NO];
    UIViewController* rootViewController = [nav viewControllers][0];
    [rootViewController performSegueWithIdentifier:@"tabSegue" sender:nil];
}
@end
