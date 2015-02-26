
//
//  TaskInfoViewController.m
//  Greeker
//
//  Created by Thohd on 6/18/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "TaskInfoViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "Utility.h"
#import "ShowLocationViewController.h"

@interface TaskInfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *taskName;
@property (weak, nonatomic) IBOutlet UILabel *taskLocation;

@property (weak, nonatomic) IBOutlet UITextView *taskDetal;
- (IBAction)backAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *dueTime;
@property (weak, nonatomic) IBOutlet UILabel *completeTime;
@property (weak, nonatomic) IBOutlet UILabel *lblTaskDetail;
@property (weak, nonatomic) IBOutlet UIButton *onItButton;
@property (weak, nonatomic) IBOutlet UIButton *completeButton;
@property (weak, nonatomic) IBOutlet UILabel *onitLabel;
@property (weak, nonatomic) IBOutlet UILabel *completeLabel;

@end

@implementation TaskInfoViewController

@synthesize taskId = _taskId;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)onItTouch:(id)sender {
    
    
    NSDictionary* user = [[AppDelegate sharedDelegate] user];

    NSString* url = [kBASE_NEW_API stringByAppendingFormat:kASSIGN_TASK, [self.taskData[@"id"] intValue], [user[@"id"] intValue]];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.onItButton.hidden = YES;
        self.onitLabel.hidden = YES;
        [[[UIAlertView alloc] initWithTitle:@"Great!" message:@"You have been put on this task!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error:%@",[error description]);
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }];
    [operation start];
    
}

- (IBAction)completeTouch:(id)sender {
 

    NSString* url = [kBASE_NEW_API stringByAppendingFormat:kCOMPLETE_TASK, [self.taskData[@"id"] intValue] ];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
       // NSLog(@"task complete:%@",JSON);
        self.completeButton.hidden = YES;
        self.onItButton.hidden = YES;
        self.onitLabel.hidden = YES;
        self.completeLabel.hidden = YES;
        NSDate* date = [NSDate date];
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        
        self.completeTime.text = [formatter stringFromDate:date];
        
        [[[UIAlertView alloc] initWithTitle:@"Great!" message:@"Great! Task completed!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
      
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error:%@",[error description]);
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }];
    [operation start];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.taskName.text = self.taskData[@"title"];
    self.taskLocation.text = self.taskData[@"location"];
    self.lblTaskDetail.text = self.taskData[@"detail"];
    
    self.dueTime.text = [Utility convertDate:self.taskData[@"due_time"] formatFrom:kSERVER_TIME_FORMAT toFormat:kUS_TIME_FORMAT];
    if ([self.taskData[@"status"] intValue] == 2) {
        self.completeTime.text = [Utility convertDate:self.taskData[@"complete_time"] formatFrom:kSERVER_TIME_FORMAT toFormat:kUS_TIME_FORMAT];
        self.completeButton.hidden = YES;
        self.onItButton.hidden = YES;
        self.onitLabel.hidden = YES;
        self.completeLabel.hidden = YES;
    } else {
        self.completeTime.text = @"Not completed yet!";
    }
    
    self.createBy.text = [NSString stringWithFormat:@"%@ %@", self.taskData[@"first_name"], self.taskData[@"last_name"]];
    
    NSDictionary *user = [AppDelegate sharedDelegate].user;
    if ([self.taskData[@"status"] intValue] == 1) {
        for (NSDictionary *dic in self.taskData[@"user_on_it"]) {
            if ([user[@"id"] isEqualToString:dic[@"user_id"]]) {
                self.onitLabel.hidden = YES;
                self.onItButton.hidden = YES;
            }
        }
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showTaskLocation"]) {
        ShowLocationViewController *destVC = segue.destinationViewController;
        destVC.locationAddress = self.taskLocation.text;
        destVC.locationTitle = self.taskName.text;
    }
}

-(NSString*) taskId
{
    return _taskId;
}

-(void) setTaskId:(NSString *)taskId
{
    [self getTaskInfo:taskId];
    _taskId = taskId;
}

-(void) getTaskInfo: (NSString *) taskId
{
    
}

- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];

}
@end
