//
//  TaskNewViewController.m
//  Greeker
//
//  Created by Thohd on 6/18/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "TaskNewViewController.h"
#import "CKCalendar/CKCalendarView.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
#import <MBProgressHUD/MBProgressHUD.h>



@interface TaskNewViewController ()<CKCalendarDelegate, UITextFieldDelegate, UIAlertViewDelegate>
{
    CKCalendarView* calendar;
    UITextField * currentEdit;
}

@property (weak, nonatomic) IBOutlet UITextField *taskTitle;

@property (weak, nonatomic) IBOutlet UITextField *taskDate;
@property (weak, nonatomic) IBOutlet UITextField *taskTime;
@property (weak, nonatomic) IBOutlet UITextField *taskLocation;
@property (weak, nonatomic) IBOutlet UITextField *taskDetail;

@property (weak, nonatomic) IBOutlet UIView *pickerPopup;
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (strong, nonatomic) UIDatePicker *timePicker;

- (IBAction)backAction:(UIButton *)sender;
@end

@implementation TaskNewViewController

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
    // Do any additional setup after loading the view.
    calendar = [[CKCalendarView alloc] init];

    CGRect r = calendar.frame;
    r.origin.y = 51;
    calendar.frame = r;
    [self.view addSubview:calendar];
    calendar.delegate = self;
    calendar.hidden = YES;
    
    self.taskTitle.delegate = self;
    self.taskDate.delegate = self;
    self.taskTime.delegate = self;
    self.taskLocation.delegate = self;
    self.taskDetail.delegate = self;
    
    self.timePicker = [[UIDatePicker alloc]  init];
    self.timePicker.frame = CGRectMake(0,0, self.pickerPopup.frame.size.width, 100.0f);
    self.timePicker.datePickerMode = UIDatePickerModeTime;
    self.timePicker.tag = 101;
    [self.pickerPopup  addSubview:self.timePicker];
    [self.pickerPopup.layer setCornerRadius:20.0F];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
     [textField resignFirstResponder];
    return YES;
}

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
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
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    
    self.taskDate.text =  [formatter stringFromDate:date];
   // self.lbBirthday.text = [formatter stringFromDate:date];
   // [self saveData];
}
- (BOOL)calendar:(CKCalendarView *)calendar willChangeToMonth:(NSDate *)date {
    // Of course we want to let users change months...
    return YES;
}

- (void)calendar:(CKCalendarView *)calendar didChangeToMonth:(NSDate *)date {
    //NSLog(@"Hurray, the user changed months!");
}


- (IBAction)saveBtnTouch:(id)sender {
    
    NSString* taskTitle = [self.taskTitle.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([taskTitle length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter a valid title" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    NSString* taskDate = [self.taskDate.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([taskDate length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter a valid date" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    
    NSString* taskTime = [self.taskTime.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([taskTime length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter valid time" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }

    NSString* taskLocation = [self.taskLocation.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([taskLocation length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter valid location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    NSString* taskDetail = [self.taskDetail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([taskDetail length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter valid location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    
    NSDate* date = [formatter dateFromString:taskDate];
    
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *sqlDate = [formatter stringFromDate:date];
    
    NSDictionary *user = [AppDelegate sharedDelegate].user;
    NSDictionary *parameters =@{@"org_id" : user[@"org_id"],
                                @"create_by" : user[@"id"],
                                @"task_title": taskTitle,
                                @"task_date":sqlDate,
                                @"task_time": taskTime,
                                @"task_location": taskLocation,
                                @"task_detail" : taskDetail
                                };
    NSLog(@"parameters:%@",parameters);
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:[kBASE_NEW_API stringByAppendingString:kCREATE_TASK]]];
    
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Task has been created!" message: @"You have been created a Task!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         [alert show];
         
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
         
     }];
    
    [operation start];
    
}

- (IBAction)dataPickTouch:(id)sender {

    if (currentEdit != nil) {
        [currentEdit resignFirstResponder];
    }
    
    calendar.hidden = NO;
    
}

- (IBAction)timePickTouch:(id)sender {
    self.popupView.hidden = NO;
    
    if (currentEdit != nil) {
        [currentEdit resignFirstResponder];
    }
    
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"HH:mm"];
    self.taskTime.text = [formater stringFromDate:self.timePicker.date];
   
}

- (IBAction)saveTimePicker:(id)sender {
    self.popupView.hidden = YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField{
    currentEdit = textField;
    if (textField.tag > 5) {
        [UIView animateWithDuration:.3 animations:^{
            CGRect r = self.view.frame;
            r.origin.y -= 110;
            self.view.frame = r;
            
        }];
    }
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag > 5) {
        [UIView animateWithDuration:.3 animations:^{
            CGRect r = self.view.frame;
            r.origin.y = 0;
            self.view.frame = r;
            
        }];
    }
   
    
}


- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
