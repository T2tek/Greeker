//
//  ActivityViewController.m
//  Greeker
//
//  Created by Thohd on 6/17/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "ActivityViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "ClubSettingsViewController.h"
#import "EventDetailViewController.h"
#import "TaskInfoViewController.h"


@interface ActivityViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray * tableData;
@end

@implementation ActivityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSArray *) tableData
{
    if (!_tableData) {
        _tableData = [[NSArray alloc]init];
    }
    return _tableData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSDictionary* user = [[AppDelegate sharedDelegate] user];
    if ([user[@"org_id"] intValue]>0) {
        NSString* url = [kBASE_NEW_API stringByAppendingFormat:kACTIVITY, [user[@"org_id"] intValue] ];
        //NSLog(@"Activity url:%@",url);
        if (self.tableData.count == 0) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
        
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"Activity response json:%@",JSON);
            self.tableData = [NSArray arrayWithArray:JSON];
            [self.tableView reloadData];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"Activity error:%@",[error description]);
            [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }];
        [operation start];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellData = self.tableData[indexPath.row];
    
    if ([cellData[@"type"] intValue] == 0) {
       // go to Club settings
    NSDictionary* user = [[AppDelegate sharedDelegate] user];
        if ([user[@"approved"] intValue] == 3) {
            ClubSettingsViewController * clSettings =
            [self.storyboard instantiateViewControllerWithIdentifier:@"Club Settings VC"];
            
            [self.navigationController pushViewController:clSettings animated:YES];
        } else {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        
        
    } else if ([cellData[@"type"] intValue] == 1) {
       // task - go to task info page
       [self gotoTaskDetail:cellData[@"target_id"]];
        
    } else {
        // go to event detail page
        [self gotoEventDetail:cellData[@"target_id"]];
        // task - go to task info page
       
    }
}


-(void) gotoTaskDetail: (NSString * ) taskId
{
    NSString* url = [kBASE_NEW_API stringByAppendingFormat:@"/taskinfo/%@", taskId];
    NSLog(@"ur:%@",url);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"Task Detail:%@",JSON);
        
        NSDictionary * taskInfo = JSON;
        
        if ([taskInfo[@"status_code"] isKindOfClass:[NSNull class]] || taskInfo[@"status_code"] == nil) {
            TaskInfoViewController *taskInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Task Info VC"];
            
            taskInfoVC.taskData = taskInfo;
            
            [self.navigationController pushViewController:taskInfoVC animated:YES];
            
            
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Information!" message:@"Task is not existed or deleted" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
        
        /*
         TaskInfoViewController *taskInfo = [self.storyboard instantiateViewControllerWithIdentifier:@"Task Info VC"];
         
         taskInfo.taskId = cellData[@"target_id"];
         
         [self.navigationController pushViewController:taskInfo animated:YES];
         */

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error:%@",[error description]);
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }];
    [operation start];
}

-(void) gotoEventDetail: (NSString * ) eventId
{
    NSString* url = [kBASE_NEW_API stringByAppendingFormat:@"/eventinfo/%@", eventId];
    NSLog(@"url:%@",url);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"Event Detail:%@",JSON);
        NSDictionary * eventResponse = JSON;
        
        if ([eventResponse[@"status_code"] isKindOfClass:[NSNull class]] || eventResponse[@"status_code"] == nil) {
            EventDetailViewController *eventDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"Event Detail VC"];
            
            eventDetail.eventData = eventResponse;
            
            [self.navigationController pushViewController:eventDetail animated:YES];
            
           
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Information!" message:@"Event is not existed or deleted" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
        
        /*
         EventDetailViewController *eventDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"Event Detail VC"];
         
         eventDetail.eventId = cellData[@"target_id"];
         
         [self.navigationController pushViewController:eventDetail animated:YES];
         */
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error:%@",[error description]);
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }];
    [operation start];
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Activity Cell"];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    UILabel *title = (UILabel *)[cell viewWithTag:2];
    UILabel *subtitle = (UILabel*) [cell viewWithTag:3];
    UILabel *activityTime = (UILabel*) [cell viewWithTag:4];
    
    NSDictionary *cellData = self.tableData[indexPath.row];
    
    if ([cellData[@"type"] intValue] == 0) {
        imageView.image = [UIImage imageNamed:@"group_icon50x50.png"];
    } else if ([cellData[@"type"] intValue] == 1) {
        imageView.image = [UIImage imageNamed:@"icon-task.png"];
    } else {
         imageView.image = [UIImage imageNamed:@"icon-calendar.png"];
    }
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
    [dateFormater setDateFormat:@"yyyy-mm-dd HH:mm:ss"];
    NSDate* date = [dateFormater dateFromString:cellData[@"update_time"]];

    [dateFormater setDateFormat:@"dd MMM yyyy hh:mm a"];
    activityTime.text = [dateFormater stringFromDate:date];
    
    title.text = cellData[@"title"];
    subtitle.text = cellData[@"subtitle"];
    
    return cell;
}

@end
