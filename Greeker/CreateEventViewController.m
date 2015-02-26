//
//  CreateEventViewController.m
//  Greeker
//
//  Created by Hoang Nguyen on 29/09/2014.
//  Copyright (c) Năm 2014 Thohd. All rights reserved.
//

#import "CreateEventViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "CKCalendarView.h"
#import "YCameraViewController.h"
#import "Utility.h"

@interface CreateEventViewController () <UITextFieldDelegate, UITextViewDelegate, CKCalendarDelegate, YCameraViewControllerDelegate>
{
    CKCalendarView *calendar;
    UIImage *pickedImage;
    UITapGestureRecognizer * tap;
}

@property (weak, nonatomic) IBOutlet UITextField *tfTitle;
@property (weak, nonatomic) IBOutlet UITextField *tfDate;
@property (weak, nonatomic) IBOutlet UITextField *tfTime;
@property (weak, nonatomic) IBOutlet UITextField *tfLocation;
@property (weak, nonatomic) IBOutlet UITextView *tfDetail;
@property (weak, nonatomic) IBOutlet UIView *timePickerView;

@property (strong, nonatomic) UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UIView *timePickerContainer;

@end

@implementation CreateEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // start create calendar
    calendar = [[CKCalendarView alloc]init];
    CGRect r = calendar.frame;
    r.origin.y = 51;
    calendar.frame = r;
    [self.view addSubview:calendar];
    calendar.delegate = self;
    calendar.hidden = YES;
    //end create calendar
    self.tfTitle.delegate = self;
    self.tfDate.delegate = self;
    self.tfTime.delegate = self;
    self.tfLocation.delegate = self;
    self.tfDetail.delegate = self;
    tap = [[UITapGestureRecognizer alloc]
           initWithTarget:self
           action:@selector(dismissKeyboard)];
    
    self.timePicker = [[UIDatePicker alloc]init];
    self.timePicker.frame = CGRectMake(0,0, self.timePickerView.frame.size.width, 100.0f);
    self.timePicker.datePickerMode = UIDatePickerModeTime;
    [self.timePickerContainer addSubview:self.timePicker];
    [self.timePickerView.layer setCornerRadius:20.0f];
    
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
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)backTouch:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)calendarTouch:(id)sender {
    calendar.hidden = NO;
}

- (IBAction)timePickerTouch:(id)sender {
    self.timePickerView.hidden = NO;
    NSDateFormatter *formater = [[NSDateFormatter alloc]init];
    [formater setDateFormat:@"HH:mm"];
    self.tfTime.text = [formater stringFromDate:self.timePicker.date];
}

- (IBAction)saveTimePicker:(id)sender {
    self.timePickerView.hidden = YES;
    NSDateFormatter *formater = [[NSDateFormatter alloc]init];
    [formater setDateFormat:@"HH:mm"];
    self.tfTime.text = [formater stringFromDate:self.timePicker.date];
}


- (IBAction)uploadImageTouch:(id)sender {
    YCameraViewController *camController = [[YCameraViewController alloc] initWithNibName:@"YCameraViewController" bundle:nil];
    camController.delegate=self;
    [self presentViewController:camController animated:YES completion:^{
        // completion code
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.tfLocation) {
        
        [self.view addGestureRecognizer:tap];
        [UIView animateWithDuration:.3 animations:^{
            CGRect r = self.view.frame;
            r.origin.y -= 40;
            self.view.frame = r;
            
        }];
    }
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:.3 animations:^{
        CGRect r = self.view.frame;
        r.origin.y = 0;
        self.view.frame = r;
        
    }];
}

-(void) textViewDidBeginEditing:(UITextView *)textView
{

    [self.view addGestureRecognizer:tap];
    [UIView animateWithDuration:.3 animations:^{
        CGRect r = self.view.frame;
        r.origin.y -= 120;
        self.view.frame = r;
    
    }];
    
}

-(void) textViewDidEndEditing:(UITextView *)textView
{
    [textView removeGestureRecognizer:tap];
    [UIView animateWithDuration:.3 animations:^{
        CGRect r = self.view.frame;
        r.origin.y = 0;
        self.view.frame = r;
        
    }];
}

-(void)dismissKeyboard {
    [self.tfDetail resignFirstResponder];
}

- (IBAction)saveTouch:(id)sender {
    
    NSString* title = [self.tfTitle.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([title length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter title" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    NSString* date = [self.tfDate.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([date length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter valid event date" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    NSString* time = [self.tfTime.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([time length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter event time" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    NSString* location = [self.tfLocation.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([location length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter event locations" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    NSString* details = [self.tfDetail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([details length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter event details" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    NSData *imageToUpload = UIImageJPEGRepresentation(pickedImage, 1.0);//(uploadedImgView.image);
    NSDictionary *user = [AppDelegate sharedDelegate].user;
    NSDictionary *parameters =@{@"title":title,
                                @"due_time":time,
                                @"location":location,
                                @"due_date":[Utility convertDate:date formatFrom:kFACEBOOK_DATE_FORMAT toFormat:kSERVER_DATE_FORMAT],
                                @"detail" : details,
                                @"user_id": user[@"id"],
                                @"org_id": user[@"org_id"]
                                };

    NSURL *url = [NSURL URLWithString:[kBASE_NEW_API stringByAppendingString:@"/create_event"]];

    
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL: url];
    
    
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        if (imageToUpload)
        {
            [formData appendPartWithFileData: imageToUpload name:@"image[]" fileName:@"event_image.jpg" mimeType:@"image/jpeg"];
        }
    }];
    
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSObject *resp = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
         [MBProgressHUD hideAllHUDsForView: self.view animated:YES];
         NSDictionary *jsons = (NSDictionary *) resp;
         if (jsons[@"error_status"] != nil) {
             [[[UIAlertView alloc] initWithTitle:@"Create event error" message:jsons[@"error_status"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
         } else {
             [self.navigationController popViewControllerAnimated:YES];
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
         NSLog(@"Error %@", error);
         [MBProgressHUD hideAllHUDsForView: self.view animated:YES];

     }];
     
    [operation start];
}

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
    self.tfDate.text = [format stringFromDate:date];
}
- (BOOL)calendar:(CKCalendarView *)calendar willChangeToMonth:(NSDate *)date {
    // Of course we want to let users change months...
    return YES;
}

- (void)calendar:(CKCalendarView *)calendar didChangeToMonth:(NSDate *)date {
    //NSLog(@"Hurray, the user changed months!");
}

@end
