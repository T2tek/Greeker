//
//  MemberListViewController.m
//  Greeker
//
//  Created by Thohd on 4/15/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "MemberListViewController.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
#import "MemberViewController.h"
#import <MessageUI/MessageUI.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface MemberListViewController () <UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSArray *tableData;
@end

@implementation MemberListViewController

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
    NSLog(@"viewDidLoad: clubid: %@", self.clubId);
 //   self.clubId = @"1";
    [self getMemberList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *) tableData {
    if (!_tableData) {
        _tableData = [[NSArray alloc] init];
    }
    return _tableData;
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) getMemberList
{

    NSDictionary *parameters =@{
                                @"club_id" : self.clubId
                                };
    NSString * url = [kBASE_NEW_API stringByAppendingString:kMEMBER_LIST];
    NSLog(@"URL: %@", url);
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:url]];
    
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         NSObject *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
         
         if ([jsons isKindOfClass:NSDictionary.class]) {
             NSLog(@"Khong co ket qua: %@", jsons);
         } else {
         
             NSLog(@"response: %@",jsons);
             self.tableData = (NSArray*)jsons;
             [self.tableView reloadData];
         }
         
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
         
     }];
    
    [operation start];
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

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MemberViewController * memberViewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileVC"];
    
    NSDictionary *data = self.tableData[indexPath.row];
    memberViewVC.memberId = data[@"id"];
    memberViewVC.orgId = self.clubId;
    [self.navigationController pushViewController:memberViewVC animated:YES];
    
}

-(void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableData.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"memberCell"];
    
    UIImageView * avatar = (UIImageView*)[cell viewWithTag:1];
    UILabel* memberName = (UILabel*)[cell viewWithTag:2];
    UILabel* role = (UILabel*)[cell viewWithTag:3];
    UILabel* city = (UILabel*)[cell viewWithTag:4];
    UIButton * emailButton = (UIButton*)[cell viewWithTag:5];
    
    NSDictionary* data = self.tableData[indexPath.row];
    // first_name, lastname, position, city_name, show_email.
    
    NSDictionary *user = [AppDelegate sharedDelegate].user;
    if (![user[@"org_id"] isEqualToString:self.clubId] && [data[@"show_email"] isEqualToString:@"0"]) {
        emailButton.hidden = YES;
    }
    emailButton.tag = indexPath.row;
    [emailButton addTarget:self action:@selector(sendEmail:) forControlEvents:UIControlEventTouchUpInside];
    NSString * firstName = data[@"first_name"];
    NSString * lastName = data[@"last_name"];
    memberName.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    if (![data[@"city_name"] isKindOfClass:[NSNull class]]) {
        city.text = data[@"city_name"];
    } else {
        city.text = @" - ";
    }
    if (![data[@"position"] isKindOfClass:[NSNull class]]) {
       role.text = data[@"position"];
    } else {
        role.text = @" - ";
    }
    if (![data[@"photo"] isKindOfClass:[NSNull class]]) {
        
        BOOL result = [[data[@"photo"] lowercaseString] hasPrefix:@"http"];
        if (result) {
            [avatar setImageWithURL:[NSURL URLWithString:data[@"photo"]] placeholderImage:[UIImage imageNamed:@"placeholderavatar"]];
        } else
        {
            [avatar setImageWithURL:[NSURL URLWithString:[kBASE_UPLOAD_URL stringByAppendingString:data[@"photo"]]] placeholderImage:[UIImage imageNamed:@"placeholderavatar"]];
        }
        avatar.layer.cornerRadius = avatar.frame.size.width/2;
        avatar.layer.masksToBounds = YES;
    }
    return cell;
}

-(void)sendEmail:(id)sender
{
    NSDictionary* data = self.tableData[[sender tag]];
    if (![data[@"email"] isKindOfClass:[NSNull class]]) {
        if([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
            mailCont.mailComposeDelegate = self;
            [mailCont setToRecipients:[NSArray arrayWithObject:data[@"email"]]];
            [self presentViewController:mailCont animated:YES completion:nil];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
