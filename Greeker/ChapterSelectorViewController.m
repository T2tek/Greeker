//
//  ChapterSelectorViewController.m
//  Greeker
//
//  Created by Thohd on 4/15/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "ChapterSelectorViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "MemberListViewController.h"

@interface ChapterSelectorViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSInteger selectedIndex;
}
@property (strong, nonatomic) IBOutlet UIView *vPopup;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)backAction:(UIButton *)sender;
- (IBAction)brotherAction:(UIButton *)sender;
- (IBAction)pledgeAction:(UIButton *)sender;

@end

@implementation ChapterSelectorViewController

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
}
- (IBAction)chapterSelectAction:(UIButton *)sender {
    self.vPopup.hidden = NO;
}
- (IBAction)closePopup:(UIButton *)sender {
    self.vPopup.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)requestAction:(UIButton *)sender {
    self.vPopup.hidden = NO;
    UITableViewCell* cell = (UITableViewCell*)[[[sender superview] superview] superview];
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    selectedIndex = indexPath.row;
}
- (IBAction)memberAction:(UIButton *)sender {
    
    MemberListViewController * memberListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Club Member VC"];
    UIView *superV = (UIView *)sender;
    while (![superV isKindOfClass:[UITableViewCell class]]) {
        superV = (UIView *) superV.superview;
    }
    
    UITableViewCell* cell = (UITableViewCell*) superV;
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary* data = self.tableData[indexPath.row];
    
    memberListVC.clubId = data[@"id"];
    [self.navigationController pushViewController:memberListVC animated:YES];
}

- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)brotherAction:(UIButton *)sender {
    self.vPopup.hidden = YES;
    NSDictionary* data = [[AppDelegate sharedDelegate] user];
    NSDictionary* club = self.tableData[selectedIndex];
    NSString* url = [kBASE_URL stringByAppendingFormat:kREQUEST,[data[@"id"] intValue],[club[@"id"] intValue]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [[AppDelegate sharedDelegate] switchToTabView];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"error:%@",[error description]);
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }];
    [operation start];
}

- (IBAction)pledgeAction:(UIButton *)sender {
    self.vPopup.hidden = YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.tableData count];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"chapterCell"];
    UILabel* nameLabel = (UILabel*)[cell viewWithTag:1];
    UILabel* descLabel = (UILabel*)[cell viewWithTag:2];
    UIImageView* cellView = (UIImageView*)[cell viewWithTag:3];
    NSDictionary* data = self.tableData[indexPath.row];
    nameLabel.text = data[@"name"];
    descLabel.text = data[@"schoolname"];
    [cellView setImageWithURL:[NSURL URLWithString:[kBASE_UPLOAD_URL stringByAppendingString:data[@"logo"]]] placeholderImage:[UIImage imageNamed:@"placeholderlogo"]];
    return cell;
}

@end
