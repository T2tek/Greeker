//
//  ChapterCreatorViewController.m
//  Greeker
//
//  Created by Thohd on 4/15/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "ChapterCreatorViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "CKCalendarView.h"
#import "YCameraViewController.h"
#import "Utility.h"

@interface ChapterCreatorViewController ()<UITextFieldDelegate, CKCalendarDelegate, YCameraViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    CKCalendarView* calendar;
    UIImage* pickedImage;
    NSArray* schoollist;
    NSArray* citylist;
    BOOL showSchool;
    NSInteger pickedSchool;
    NSInteger pickedCity;
    NSArray* pledgeClasses;
    NSArray* pledgeDetailClasses;
}
@property (strong, nonatomic) IBOutlet UITextField *textClubName;
@property (strong, nonatomic) IBOutlet UITextField *textLetters;
@property (strong, nonatomic) IBOutlet UITextField *textSchool;
@property (strong, nonatomic) IBOutlet UITextField *textCity;
@property (strong, nonatomic) IBOutlet UITextField *textDateFounded;
@property (strong, nonatomic) IBOutlet UIView *vItem;
@property (strong, nonatomic) IBOutlet UIView *vPledge;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableView *pledgeTableView;
- (IBAction)backAction:(UIButton *)sender;
- (IBAction)createAction:(UIButton *)sender;
- (IBAction)dateAction:(UIButton *)sender;
- (IBAction)uploadAction:(UIButton *)sender;
- (IBAction)schoolAction:(UIButton *)sender;
- (IBAction)cityAction:(UIButton *)sender;
- (IBAction)lettersAction:(UIButton *)sender;

@end

@implementation ChapterCreatorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) getSchoolList
{
    NSString* url = [kBASE_URL stringByAppendingString:kSCHOOL_LIST];
    NSLog(@"ur:%@",url);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"json:%@",JSON);
        schoollist = [NSArray arrayWithArray:JSON];

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"error:%@",[error description]);
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }];
    [operation start];

}
- (void) getCityList
{
    NSString* url = [kBASE_URL stringByAppendingString:kCITY_LIST];
    NSLog(@"ur:%@",url);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"json:%@",JSON);
        citylist = [NSArray arrayWithArray:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"error:%@",[error description]);
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }];
    [operation start];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textClubName.background = [UIImage imageNamed:@"textfieldbg"];
    self.textLetters.background = [UIImage imageNamed:@"textfieldbg"];
    self.textCity.background = [UIImage imageNamed:@"textfieldbg"];
    self.textSchool.background = [UIImage imageNamed:@"textfieldbg"];
    self.textDateFounded.background = [UIImage imageNamed:@"textfieldbg"];
    [self getCityList];
    [self getSchoolList];
    calendar = [[CKCalendarView alloc] init];
    CGRect r = calendar.frame;
    r.origin.y = 51;
    calendar.frame = r;
    [self.view addSubview:calendar];
    calendar.delegate = self;
    calendar.hidden = YES;
    self.vPledge.hidden = YES;
    
    self.textSchool.delegate = self;
    self.textCity.delegate = self;
    
    pledgeClasses = @[@"α",@"β",@"γ",@"δ",@"ε",@"ζ",@"η",@"θ",@"ι",@"κ",@"λ",@"μ",@"ν",@"ξ",@"ο",@"π",@"ρ",@"σ",@"τ",@"υ",@"φ",@"χ",@"ψ",@"ω"];
    pledgeDetailClasses = @[@"Alpha",@"Beta",@"Gamma",@"Delta",@"Epsilon",@"Zeta",@"Eta",@"Theta",@"Iota",@"Kappa",@"Lambda",@"Mu",@"Nu",@"Ksi",@"Omicron",@"Pi",@"Rho",@"Sigma",@"Tau",@"Upsilon",@"Phi",@"Chi",@"Psi",@"Omega"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)createAction:(UIButton *)sender {
    NSString* name = [self.textClubName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([name length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter club name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    NSString* letters = [self.textLetters.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([letters length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter club letters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    NSString* school = [self.textSchool.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([school length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter school name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    NSString* city = [self.textCity.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([city length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter city name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    NSString* dateFounded = [self.textDateFounded.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([dateFounded length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter date founded" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    //#define kCREATE_CHAPTER     @"key=newchapter&name=%@&letter=%@&school=%@&city=%@founded_date=%@"

    NSData *imageToUpload = UIImageJPEGRepresentation(pickedImage, 1.0);//(uploadedImgView.image);
    NSDictionary *user = [AppDelegate sharedDelegate].user;
        NSDictionary *parameters =@{@"name":name,
                                    @"letters":letters,
                                    @"school":[NSString stringWithFormat:@"%@",school],
                                    @"city":[NSString stringWithFormat:@"%@",city],
                                    @"date_founded":[Utility convertDate:dateFounded formatFrom:kFACEBOOK_DATE_FORMAT toFormat:kSERVER_DATE_FORMAT],
                                    @"user_id" : user[@"id"]
                                    };
        NSLog(@"parameters:%@",parameters);
        AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:[kBASE_NEW_API stringByAppendingString:@"/newchapter"]]];
        
        NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
            if (imageToUpload)
            {
                [formData appendPartWithFileData: imageToUpload name:@"image[]" fileName:@"logo.jpg" mimeType:@"image/jpeg"];
            }
        }];
    
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSObject *resp = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
             NSLog(@"create chapter response: %@",resp);
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             NSDictionary *jsons = (NSDictionary *) resp;
             if (jsons[@"error_status"] != nil) {
                  [[[UIAlertView alloc] initWithTitle:@"Create Chapter Error" message:jsons[@"error_status"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
             } else {
                 [AppDelegate sharedDelegate].user = [[NSMutableDictionary alloc] initWithDictionary:jsons];
                 [[AppDelegate sharedDelegate] switchToTabView];
             }
         }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
             
         }];
        
        [operation start];
    
}

-(void) textFieldDidBeginEditing:(UITextField *)textView1
{
    self.vPledge.hidden = YES;
    self.vItem.hidden = YES;
    UITextField *textView = (UITextField*) textView1;
    
    if (textView == self.textCity || textView == self.textSchool ) {
        [UIView animateWithDuration:.3 animations:^{
            CGRect r = self.view.frame;
            r.origin.y -= 80;
            self.view.frame = r;
            
        }];
    }
}

-(void) textFieldDidEndEditing:(UITextField *)textView1
{
    UITextField *textView = (UITextField*) textView1;
    
    if (textView == self.textCity || textView == self.textSchool ) {
        [UIView animateWithDuration:.3 animations:^{
            CGRect r = self.view.frame;
            r.origin.y = 0;
            self.view.frame = r;
            
        }];
        NSLog(@"end edit");
    }
}

- (IBAction)dateAction:(UIButton *)sender {
    calendar.hidden = NO;
    self.vPledge.hidden = YES;
    self.vItem.hidden = YES;
}

- (IBAction)uploadAction:(UIButton *)sender {
    YCameraViewController *camController = [[YCameraViewController alloc] initWithNibName:@"YCameraViewController" bundle:nil];
    camController.delegate=self;
    [self presentViewController:camController animated:YES completion:^{
        // completion code
    }];
}

- (IBAction)schoolAction:(UIButton *)sender {
    [self.view endEditing:YES];
    self.vItem.hidden = NO;
    self.vPledge.hidden = YES;
    calendar.hidden = YES;
    showSchool = YES;
    [self.tableView reloadData];
}

- (IBAction)cityAction:(UIButton *)sender {
    [self.view endEditing:YES];
    self.vItem.hidden = NO;
    self.vPledge.hidden = YES;
    calendar.hidden = YES;
    showSchool = NO;
    [self.tableView reloadData];
}

- (IBAction)lettersAction:(UIButton *)sender {
    [self.view endEditing:YES];
    calendar.hidden = YES;
    self.vPledge.hidden = NO;
    self.vItem.hidden = YES;
    self.textLetters.text = @"";
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 
#pragma mark YCameraViewControllerDelegate
-(void)didFinishPickingImage:(UIImage *)image{
    // Use image as per your need
    pickedImage = image;
}
-(void)yCameraControllerdidSkipped{
    // Called when user clicks on Skip button on YCameraViewController view
}
-(void)yCameraControllerDidCancel{
    // Called when user clicks on "X" button to close YCameraViewController
}
#pragma mark -
#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.pledgeTableView) {
        return [pledgeClasses count];
    }
    if (showSchool) {
        return [schoollist count];
    }
    return citylist.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (tableView == self.pledgeTableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"pledgeCell"];
        cell.textLabel.text = pledgeClasses[indexPath.row];
        cell.detailTextLabel.text = pledgeDetailClasses[indexPath.row];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"itemCell"];
        NSDictionary* data = nil;
        if (showSchool) {
            data = schoollist[indexPath.row];
        }else{
            data = citylist[indexPath.row];
        }
        cell.textLabel.text = data[@"name"];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.pledgeTableView) {
        
        if([self.textLetters.text isEqualToString:@""])
        {
            self.textLetters.text = pledgeDetailClasses[indexPath.row];
        } else {
            self.textLetters.text = [NSString stringWithFormat:@"%@ %@", self.textLetters.text, pledgeDetailClasses[indexPath.row]];
        }
        return;
    }
    if (showSchool) {
        pickedSchool = [schoollist[indexPath.row][@"id"] integerValue];
        self.textSchool.text = schoollist[indexPath.row][@"name"];
    }else{
        pickedCity = [citylist[indexPath.row][@"id"] integerValue];
        self.textCity.text = citylist[indexPath.row][@"name"];
    }
    self.vItem.hidden = YES;
}
#pragma mark -
#pragma mark - CKCalendarDelegate
- (BOOL)calendar:(CKCalendarView *)calendar willSelectDate:(NSDate *)date {
    // don't let people select dates in previous/next month
    return YES;
}
- (void)calendar:(CKCalendarView *)cal didSelectDate:(NSDate *)date {
    //NSLog(@"selected:%@",date);
    calendar.hidden = YES;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:kFACEBOOK_DATE_FORMAT];
    self.textDateFounded.text = [format stringFromDate:date];
}
- (BOOL)calendar:(CKCalendarView *)calendar willChangeToMonth:(NSDate *)date {
    // Of course we want to let users change months...
    return YES;
}

- (void)calendar:(CKCalendarView *)calendar didChangeToMonth:(NSDate *)date {
    //NSLog(@"Hurray, the user changed months!");
}

@end
