//
//  HomeViewController.m
//  Greeker
//
//  Created by Thohd on 6/17/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "MemberListViewController.h"
#import "TasksViewController.h"
#import "ChapterCreatorViewController.h"
#import "ClassChatViewController.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>
@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray* tableData;
    NSMutableArray* tableInviteData;
    NSArray* iconArray;
    NSDictionary* user;
    NSMutableArray * events;
}
@property (strong, nonatomic) IBOutlet UILabel *emptyLabel;
@property (weak, nonatomic) IBOutlet UILabel *lbClubName;
@property (weak, nonatomic) IBOutlet UIButton *btnSetting;
@property (weak, nonatomic) IBOutlet UIButton *btnAddChapter;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Home";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tableData = @[@"Message Board",
                  @"Pledge Class Chat",
                  @"Calendar",
                  @"Task's",
                  @"Bio's",
                  @"Map"];
    iconArray = @[@"icon-mb",
                  @"icon-class",
                  @"icon-calendar",
                  @"icon-task",
                  @"icon-bio",
                  @"icon-map"];
    user = [[AppDelegate sharedDelegate] user];
    if ([user[@"org_id"] intValue]==0)
    {
        self.emptyLabel.hidden = NO;
        self.btnSetting.hidden = YES;
        self.btnAddChapter.hidden = NO;
        self.lbClubName.text = @"Home";
        [self getListInviteOfOrigination];
    } else
    {
        self.btnAddChapter.hidden = YES;
        self.lbClubName.text = [NSString stringWithFormat:@"%@", user[@"organization_name"]];
        if ([user[@"approved"] intValue] != 3) {
            // Not admin role, hide setting button.
            self.btnSetting.hidden = YES;
        }
    }

}

-(void) viewWillAppear:(BOOL)animated
{
    user = [AppDelegate sharedDelegate].user;
    
    
    [self getUserInfo];
    [self getEvents];
    
    NSLog(@"view appear");
    if ([user[@"org_id"] intValue]==0)
    {
        self.emptyLabel.hidden = NO;
        self.btnSetting.hidden = YES;
        self.btnAddChapter.hidden = NO;
        self.lbClubName.text = @"Home";
        
    } else
    {
        self.lbClubName.text = [NSString stringWithFormat:@"%@", user[@"organization_name"]];
        if ([user[@"approved"] intValue] != 3) {
            // Not admin role, hide setting button.
            self.btnSetting.hidden = YES;
        } else {
            self.btnSetting.hidden = NO;
        }
        self.emptyLabel.hidden = YES;
        self.btnAddChapter.hidden = YES;
    }
    
    [self.tableView reloadData];
}

-(void)getListInviteOfOrigination
{
    NSString* url = [kBASE_NEW_API stringByAppendingFormat:kINVITE_OF_MEMBER, [user[@"id"] intValue]];
    NSLog(@"url : %@",url);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        tableInviteData = [NSMutableArray arrayWithArray:JSON];
        if (tableInviteData.count > 0) {
            self.emptyLabel.hidden = YES;
            [self.tableView reloadData];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"error:%@",[error description]);
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }];
    [operation start];
}



-(void) getEvents
{

    if ([user[@"org_id"] intValue]>0) {
        NSString* url = [kBASE_NEW_API stringByAppendingFormat:kCOMMING_EVENT, [user[@"id"] intValue]];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSArray *myEvents = [NSArray arrayWithArray:JSON];
            
            NSArray *scheduledEvents = [[UIApplication sharedApplication] scheduledLocalNotifications];
            NSLog(@"scheduledEvents: %@", scheduledEvents);
            for (NSDictionary *event in myEvents) {
                
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                [formatter setTimeZone:[NSTimeZone localTimeZone]];
                NSString * eventDateString = [NSString stringWithFormat:@"%@ %@", event[@"due_date"], event[@"due_time"]];
                NSDate* eventDate = [formatter dateFromString:eventDateString];
                
                NSLog(@"Event: %@, Date: %@", event[@"title"], [formatter stringFromDate:eventDate]);
                
                // test local notification
                
                int  timeBefore = -60 * 60;
                
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.fireDate = [NSDate dateWithTimeInterval:timeBefore sinceDate:eventDate];
                localNotification.alertBody = [NSString stringWithFormat:@"Comming event in 1 hour: %@", event[@"title"]];
                localNotification.alertAction = @"OK";
                localNotification.timeZone = [NSTimeZone localTimeZone];
                localNotification.userInfo = [NSDictionary dictionaryWithObject:event[@"title"] forKey:@"Event Name"];
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

            }

        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
            NSLog(@"GET EVENT Error:%@",[error description]);
        }];
        [operation start];
    }
}


-(void) getUserInfo
{
    NSString* url = [kBASE_NEW_API stringByAppendingFormat:kUSER_INFO, [user[@"id"] intValue]];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:JSON];
        
        if ([userInfo[@"org_id"] isKindOfClass:[NSNull class]]) {
            userInfo[@"org_id"] = @"0";
        }
        
        
        [AppDelegate sharedDelegate].user = userInfo;
        user = userInfo;

        if ([userInfo[@"org_id"] intValue]==0)
        {
            self.emptyLabel.hidden = NO;
            self.btnSetting.hidden = YES;
            self.btnAddChapter.hidden = NO;
            self.lbClubName.text = @"Home";
            
        } else
        {
            self.lbClubName.text = [NSString stringWithFormat:@"%@", userInfo[@"organization_name"]];
            if ([userInfo[@"approved"] intValue] != 3) {
                // Not admin role, hide setting button.
                self.btnSetting.hidden = YES;
            } else {
                self.btnSetting.hidden = NO;
            }
            self.emptyLabel.hidden = YES;
            self.btnAddChapter.hidden = YES;
        }
        
        [self.tableView reloadData];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"error:%@",[error description]);
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }];
    [operation start];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
#pragma mark - UITableViewDataSource, UITableViewDelegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 4) {
        if ([user[@"org_id"] intValue] == 0) {
            return;
        }
        MemberListViewController * memberListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Club Member VC"];
        
       // UIButton *memberButton = sender;
        
        memberListVC.clubId = user[@"org_id"];
        
        [self.navigationController pushViewController:memberListVC animated:YES];
    } else if ( indexPath.row == 3) {
        TasksViewController * taskListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"taskList"];
        [self.navigationController pushViewController:taskListVC animated:YES];
    } else if (indexPath.row == 0) {
        // chat board
        ClassChatViewController * classChatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Class Chat"];
        classChatVC.messageType = @"1";
        [self.navigationController pushViewController:classChatVC animated:YES];
        
    } else if (indexPath.row == 1)
    {
        // class chat
        ClassChatViewController * classChatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Class Chat"];
        classChatVC.messageType = @"0";
        [self.navigationController pushViewController:classChatVC animated:YES];
        
    } else if (indexPath.row == 2) {
        // calendar
        TasksViewController * destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Calendar"];
        [self.navigationController pushViewController:destVC animated:YES];
    } else {
        // map
        TasksViewController * destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Maps"];
        [self.navigationController pushViewController:destVC animated:YES];
    }
}
- (IBAction)createChapterTouch:(id)sender {
    
    ChapterCreatorViewController *chapterCreatorVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Chapter Creator"];
    [self.navigationController pushViewController:chapterCreatorVC animated:YES];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([user[@"org_id"] intValue]>0) {
        return [tableData count];
    }
    return tableInviteData.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = nil;
    if ([user[@"org_id"] intValue] > 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"homeCell"];
        cell.imageView.image = [UIImage imageNamed:iconArray[indexPath.row]];
        cell.textLabel.text = tableData[indexPath.row];
    } else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"InviteCell"];
        NSDictionary* data = tableInviteData[indexPath.row];
        UIImageView* cellView = (UIImageView*)[cell viewWithTag:10];
        UILabel* textLabel = (UILabel*)[cell viewWithTag:11];
        UIButton* btnAccept = (UIButton*)[cell viewWithTag:12];
        UIButton* btnReject = (UIButton*)[cell viewWithTag:13];
        NSString *userPhotoURL;
        if (![data[@"photo"] isKindOfClass:[NSNull class]]) {
            userPhotoURL = data[@"photo"];
        } else {
            userPhotoURL = @"";
        }
        [btnAccept addTarget:self action:@selector(acceptAction:event:) forControlEvents:UIControlEventTouchUpInside];
        [btnReject addTarget:self action:@selector(rejectAction:event:) forControlEvents:UIControlEventTouchUpInside];
        
        textLabel.text = [NSString stringWithFormat:@"%@ has invited to join",data[@"name"]];
        [cellView setImageWithURL:[NSURL URLWithString:userPhotoURL] placeholderImage:[UIImage imageNamed:@"placeholderavatar.png"]];
        cellView.layer.cornerRadius = 25;
        cellView.clipsToBounds = YES;
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (void) acceptAction:(UIButton*)button event:(UIEvent*) event{
    [self processRequest:YES event:event];
}
- (void) rejectAction:(UIButton*)button event:(UIEvent*) event{
    
    [self processRequest:NO event:event];
}

-(void) processRequest: (BOOL) accept event: (UIEvent *) event
{
    UITouch* touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self.tableView];
    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:point];
    NSDictionary* data = tableInviteData[indexPath.row];
    NSString* url = [kBASE_NEW_API stringByAppendingFormat:kPROCESS_INVITE, [user[@"id"] intValue], [data[@"organization_id"] intValue], accept? 1 : 0 ];
    NSLog(@"ur:%@",url);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (accept) {
            [tableInviteData removeAllObjects];
            [user setValue:data[@"organization_id"] forKey:@"org_id"];
            [user setValue:data[@"name"] forKey:@"organization_name"];
            [self.tableView reloadData];
        } else
        {
            [tableInviteData removeObjectAtIndex:indexPath.row];
            if (tableInviteData.count == 0) {
                self.emptyLabel.hidden = NO;
            }
            [self.tableView reloadData];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error:%@",[error description]);
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }];
    [operation start];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    // To "clear" the footer view
    return [UIView new];
}

@end
