//
//  ShowLocationViewController.m
//  Greeker
//
//  Created by Hoang Nguyen on 14/10/2014.
//  Copyright (c) Năm 2014 Thohd. All rights reserved.
//

#import "ShowLocationViewController.h"
#import <MapKit/MapKit.h>
#import "LocationAnnotation.h"

@interface ShowLocationViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation ShowLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self.mapView addAnnotations:self.annotationArray];
    LocationAnnotation *locationAnnotation = [[LocationAnnotation alloc] init];
    locationAnnotation.locationTitle = self.locationTitle;
    locationAnnotation.locationAddress = self.locationAddress;
    CLLocationCoordinate2D locationCoordinate = [self geoCodeUsingAddress:self.locationAddress];
    locationAnnotation.locationCoordinate = locationCoordinate;
    
    [self.mapView addAnnotation:locationAnnotation];
    
    //    [self.mapView]
    CLLocationCoordinate2D noLocation = CLLocationCoordinate2DMake(0, 0);
    MKCoordinateRegion vewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 50000, 50000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:vewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
    self.mapView.showsUserLocation = NO;
    

    CLLocationDegrees latitude = locationCoordinate.latitude;
    CLLocationDegrees longiture = locationCoordinate.longitude;
    CLLocationCoordinate2D centterCoordinate = CLLocationCoordinate2DMake(latitude, longiture);
    [self.mapView setCenterCoordinate:centterCoordinate];
    [self.mapView reloadInputViews];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.Charleston
}
*/
- (IBAction)backHandle:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
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

@end
