//
//  MapViewController.m
//  Greeker
//
//  Created by Thohd on 6/18/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "MemberAnnotation.h"

#import "AppDelegate.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/AFNetworking.h>
#import <QuartzCore/QuartzCore.h>


@interface MapViewController () <CLLocationManagerDelegate, UITextFieldDelegate>
{
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)backAction:(UIButton *)sender;

@property (strong, nonatomic) NSMutableArray * annotationArray;
@property (strong, nonatomic) NSArray *memberArray;

@property (weak, nonatomic) IBOutlet UISwitch *switchShareLocation;
@property (weak, nonatomic) IBOutlet UITextField *searchText;

@end

@implementation MapViewController

// getter
-(NSMutableArray *) annotationArray
{
    if (!_annotationArray) {
        _annotationArray = [[NSMutableArray alloc] init];
    }
    return _annotationArray;
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

// change options

- (IBAction)shareLocationChange:(id)sender {
    
    NSDictionary * user = [AppDelegate sharedDelegate].user;
    
    int share_location = self.switchShareLocation.on ? 1 : 0;
    
    NSDictionary *parameters =@{
                                @"user_id" : user[@"id"],
                                @"share_location" : [NSString stringWithFormat: @"%d" , share_location]
                                };
    NSString * url = [kBASE_NEW_API stringByAppendingString:@"/changesharelocation"];
    NSLog(@"URL: %@, parametter: %@", url, parameters);
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:url]];
    
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
    }];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSObject *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
         NSLog(@"Update location state: %@",jsons);
         [user setValue:[NSString stringWithFormat: @"%d" , share_location] forKeyPath:@"share_location"];
         [AppDelegate sharedDelegate].user = [NSMutableDictionary dictionaryWithDictionary:user];
         [self getMemberList];
         [MBProgressHUD hideHUDForView:self.view animated:YES];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if([operation.response statusCode] == 403)
         {
             NSLog(@"Upload Failed");
             return;
         }
         NSLog(@"error: %@", [operation error]);
         [MBProgressHUD hideHUDForView:self.view animated:YES];

     }];
    
    [operation start];
    
}

- (IBAction)searchButtonTouch:(id)sender {
    
    
    NSString* searchText = [self.searchText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([searchText length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter any search text" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", searchText];
    
    NSArray * filterArray = [self.annotationArray filteredArrayUsingPredicate:predicate];
    
    NSLog(@"after predicate textsearch: %@ %@", searchText, filterArray);
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:filterArray];
    
    [self.searchText resignFirstResponder];
}

// set member data
-(void) setMemberArray: (NSArray *) memberArray
{
        _memberArray = memberArray;
         [self.mapView removeAnnotations: self.mapView.annotations];
        [self.annotationArray removeAllObjects];
        
        for (NSDictionary * member in _memberArray) {
            // if member has location data
            if ([member[@"share_location"] intValue] == 0) {
                continue;
            }
            
            if ([member[@"long"] isKindOfClass:[NSNull class]]) {
                continue;
            }
            
            MemberAnnotation * memberAnnotation = [[MemberAnnotation alloc] init];
            memberAnnotation.memberData = member;
            
           // NSLog(@"Add annotation:%@", member[@"username"]);
            
            [self.annotationArray addObject:memberAnnotation];
        }
        [self.mapView addAnnotations:self.annotationArray];
        //NSLog(@"Annotation: %@",self.annotationArray);
        [self.mapView reloadInputViews];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (CLLocationCoordinate2D) geoCodeUsingAddress: (NSString *) address
{
    //
    double latitude = 0, longitude = 0;
    NSString *addr = [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", addr];
    NSString *res = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    if(res)
    {
        NSScanner *scanner = [NSScanner scannerWithString:res];
        if([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil])
        {
            [scanner scanDouble:&latitude];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
            }
        }
    }
    
    CLLocationCoordinate2D center;
    center.longitude = longitude;
    center.latitude = latitude;
    return center;
    // return center;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.searchText.delegate = self;
    NSDictionary * user = [AppDelegate sharedDelegate].user;
    
    
    
    
    NSString *shareLocation = (NSString *) user[@"share_location"];
    
    if ([shareLocation isEqualToString:@"0"]) {
        [self.switchShareLocation setOn:NO animated:YES ];
    } else {
        [self.switchShareLocation setOn:YES animated:YES];
    }
    
    // Do any additional setup after loading the view.
    
    [self getMemberList];
    
    [self.mapView addAnnotations:self.annotationArray];
//    [self.mapView]
    CLLocationCoordinate2D noLocation = CLLocationCoordinate2DMake(0, 0);
    MKCoordinateRegion vewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 50000, 50000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:vewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
    self.mapView.showsUserLocation = NO;
    
    if (![user[@"long"] isKindOfClass:NSNull.class]) {
        CLLocationDegrees latitude = [user[@"lat"] doubleValue];
        CLLocationDegrees longiture = [user[@"long"] doubleValue];
        CLLocationCoordinate2D centterCoordinate = CLLocationCoordinate2DMake(latitude, longiture);
        [self.mapView setCenterCoordinate:centterCoordinate];
        [self.mapView reloadInputViews];
    } else {
        [self getClubCity];
    }
   //
}

-(void) getClubCity
{
    
    
    NSDictionary * user = [AppDelegate sharedDelegate].user;
    
    NSDictionary *parameters =@{
                                @"club_id" : user[@"org_id"]
                                };
    NSString * url = [kBASE_NEW_API stringByAppendingString:@"/clubcity"];
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:url]];
    
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSObject *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
         NSLog(@"Clubcity: %@", jsons);
         if ([jsons isKindOfClass:NSDictionary.class]) {
            NSDictionary * club_city = (NSDictionary *) jsons;
             CLLocationCoordinate2D center = [self geoCodeUsingAddress:club_city[@"city_name"]];
            [self.mapView setCenterCoordinate:center];
         }
         
     }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
         
     }];
    
    [operation start];
}

-(void) getMemberList
{
    
    
    NSDictionary * user = [AppDelegate sharedDelegate].user;
    
    NSDictionary *parameters =@{
                                @"club_id" : user[@"org_id"]
                                };
    NSString * url = [kBASE_NEW_API stringByAppendingString:kMEMBER_LIST];
    NSLog(@"URL: %@", url);
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:url]];
    
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSObject *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
         
         if ([jsons isKindOfClass:NSDictionary.class]) {
             NSLog(@"Khong co ket qua: %@", jsons);
         } else {
             
             NSLog(@"-------------");
             self.memberArray = (NSArray*)jsons;
         }
         
     }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
         
     }];
    
    [operation start];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
