//
//  LoginViewController.m
//  Greeker
//
//  Created by Thohd on 4/14/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "Utility.h"
@interface LoginViewController () <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *textUsername;
@property (strong, nonatomic) IBOutlet UITextField *textPassword;
- (IBAction)fbAction:(UIButton *)sender;
- (IBAction)tabAction:(UIButton *)sender;
- (IBAction)forgotAction:(UIButton *)sender;

@end

@implementation LoginViewController

{
    NSUserDefaults *userDefault ;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textUsername.background = [UIImage imageNamed:@"textfieldbg"];
    self.textPassword.background = [UIImage imageNamed:@"textfieldbg"];
    
    userDefault = [NSUserDefaults standardUserDefaults];
    
    // check already login
    
    NSString *username = [userDefault objectForKey:@"username"];
    NSString *password = [userDefault objectForKey:@"password"];
    if (username != nil && password != nil) {
        [self doLogin:username password:password];
    }
    
}


- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"lookupChapter"]) {
        return NO;
    }
    return YES;
}

- (IBAction)fbAction:(UIButton *)sender {
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",@"user_friends",@"email",@"user_about_me",@"user_birthday",@"user_location",@"user_hometown"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {

        // NSString* accessToken = session.accessTokenData.accessToken;
         if (error) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:error.localizedDescription
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
         } else if (FB_ISSESSIONOPENWITHSTATE(state)) {
             [MBProgressHUD showHUDAddedTo:self.view animated:YES];
             //hud.labelText = @"Getting user info...";
             [FBRequestConnection startWithGraphPath:@"me" parameters:[NSDictionary dictionaryWithObject:@"picture,id,birthday,email,name, first_name, last_name,gender" forKey:@"fields"] HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 
                 int gender = [result[@"gender"] isEqualToString:@"male"] ? 1 : 0;
                NSString *birthday = @"";
                 if (result[@"birthday"] != nil) {
                     birthday = [Utility convertDate:result[@"birthday"] formatFrom:kFACEBOOK_DATE_FORMAT toFormat:kSERVER_DATE_FORMAT];
                 }
                 
                 NSString *deviceToken = [userDefault objectForKey:@"device_token"];
                 if (deviceToken == nil)
                 {
                     deviceToken = @"No Token";
                 }
                 
                 NSDictionary *parameters =@{@"username" : result[@"id"],
                                             @"password" : @"",
                                             @"firstname": result[@"first_name"],
                                             @"lastname": result[@"last_name"],
                                             @"birthday": birthday,
                                             @"email": result[@"email"],
                                             @"photo": result[@"picture"][@"data"][@"url"],
                                             @"gender": [NSString stringWithFormat:@"%d", gender],
                                             @"facebook" : result[@"id"],
                                             @"school" : @"",
                                             @"org" :@"",
                                             @"hometown" : @"",
                                             @"device_token" : deviceToken
                                             };
                 
                 AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:[kBASE_NEW_API stringByAppendingString:kSIGNUP_API]]];
                 
                 NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                     
                 }];
                 
                 [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                 
                 AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                 
                 [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
                  {
                      id jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                      [MBProgressHUD hideHUDForView:self.view animated:YES];
                      NSLog(@"............%@", jsons);
                      NSArray * result = (NSArray *) jsons;
                      NSMutableDictionary *user = [NSMutableDictionary dictionaryWithDictionary:result[0]];
                      
                      [[AppDelegate sharedDelegate] setUser:user];
                      [[AppDelegate sharedDelegate] setUpdateLocation];

                      if ([user[@"approved"] intValue] == 0) {
                          [user setValue:@"0" forKey:@"org_id"];
                      }
                      
                      
                      
                      [[AppDelegate sharedDelegate] setUpdateLocation];
                      
                      NSString *firstLogin = [userDefault objectForKey:@"firstLogin"];
                       int orgid = [result[0][@"org_id"] intValue];
                      
                      NSLog(@"Test FB login khi cai lai app : %@ %@, %d",jsons, user, orgid);

                      
                      if (orgid > 0) {
                          [self performSegueWithIdentifier:@"tabSegue" sender:nil];
                          return;
                      }
                      
                      if (firstLogin == nil || [firstLogin isEqualToString:@"1"]) {
                          [userDefault setValue:@"0" forKey:@"firstLogin"];
                          [self performSegueWithIdentifier:@"lookupChapter" sender:nil];
                      }
                        else
                      {
                          [self performSegueWithIdentifier:@"tabSegue" sender:nil];
                      }
                      
                      
                      
                  }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error)
                  {
                      [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                      [MBProgressHUD hideHUDForView:self.view animated:YES];
                  }];
                 
                 [operation start];
             }];
         }
     }];
}

- (IBAction)tabAction:(UIButton *)sender {
    NSString* username = [self.textUsername.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* password = self.textPassword.text;
    if ([username length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter your username" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    if ([password length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter your password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    [self doLogin:username password:password];
}

-(void) doLogin: (NSString * ) username password: (NSString*) password
{
    NSString* url = [kBASE_NEW_API stringByAppendingFormat:kLOGIN_API];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *deviceToken = [userDefault objectForKey:@"device_token"];
    if (deviceToken == nil)
    {
        deviceToken = @"No Token";
    }
    
    NSDictionary *parameters =@{@"username" : username,
                                @"password": password,
                                @"device_token": deviceToken
                                };
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:url]];
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSObject *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
         
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         
        // NSLog(@"Login response: %@",JSON);
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSDictionary * result = (NSDictionary *) JSON;
             [[[UIAlertView alloc] initWithTitle:@"Login Fails" message:result[@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
             
         }else if([JSON isKindOfClass:[NSArray class]]){
             NSArray * result = (NSArray *) JSON;
             NSMutableDictionary *user = [NSMutableDictionary dictionaryWithDictionary:result[0]];
             
             [[AppDelegate sharedDelegate] setUser:user];
             
             [[AppDelegate sharedDelegate] setUpdateLocation];
             
             [userDefault setObject:username forKey:@"username"];
             [userDefault setObject:password forKey:@"password"];

             if ([user[@"approved"] intValue] == 0) {
                 [user setValue:@"0" forKey:@"org_id"];
             }
             
             NSString *firstLogin = [userDefault objectForKey:@"firstLogin"];
             
             int orgid = [result[0][@"org_id"] intValue];
             
             if (orgid > 0) {
                 [self performSegueWithIdentifier:@"tabSegue" sender:nil];
                 return;
             }
             
             if (firstLogin == nil || [firstLogin isEqualToString:@"1"]) {
                 [userDefault setValue:@"0" forKey:@"firstLogin"];
                 [self performSegueWithIdentifier:@"lookupChapter" sender:nil];
             } else
             {
                 [self performSegueWithIdentifier:@"tabSegue" sender:nil];
             }
           
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Login error:%@",[error description]);
         [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         
     }];
    
    [operation start];
}

- (IBAction)forgotAction:(UIButton *)sender {
    
    
    NSString* username = [self.textUsername.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([username length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter your email or user name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }

    
    NSString* url = [kBASE_NEW_API stringByAppendingFormat:kFORGOT_PASS_API];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    NSDictionary *parameters =@{@"email" : self.textUsername.text};
    NSLog(@"forgot password parameters:%@",parameters);
    
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:url]];
    
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSObject *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
         NSLog(@"Forgot password response: %@",JSON);
        
         [[[UIAlertView alloc] initWithTitle:@"System Message" message:@"Please check your email for information!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
         
         [MBProgressHUD hideHUDForView:self.view animated:YES];
       
         
     }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"error:%@",[error description]);
         [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         
     }];
    
    [operation start];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [UIView animateWithDuration:.3 animations:^{
        CGRect r = self.view.frame;
        r.origin.y -= 80;
        self.view.frame = r;
        
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [UIView animateWithDuration:.3 animations:^{
        CGRect r = self.view.frame;
        r.origin.y = 0;
        self.view.frame = r;
        
    }];
}
@end
