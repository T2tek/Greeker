//
//  SearchViewController.m
//  Greeker
//
//  Created by Thohd on 6/17/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "SearchViewController.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
#import "MemberListViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface SearchViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    int selectedIndex;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *vPopup;
@property (nonatomic) NSString *selectClubId;

@property (weak, nonatomic) IBOutlet UIButton *btnRequestJoin;
@property (weak, nonatomic) IBOutlet UIButton *btnShowGroup;

@end

@implementation SearchViewController

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
    self.searchBar.delegate = self;
    UITapGestureRecognizer *reg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tabHandle)];
    [self.view addGestureRecognizer:reg];
}

-(void) tabHandle
{
    [self.searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *) tableData {
    if (_tableData == nil) {
        // get table data...
        _tableData = [[NSArray alloc] init];
    }
    return _tableData;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchText = searchBar.text;
    NSLog(@"Search string: %@", searchText);
    [self.searchBar resignFirstResponder];
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if ([searchText length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter search key!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    NSDictionary *parameters =@{
                                @"search_text" : searchText
                            };
    NSString * url = [kBASE_NEW_API stringByAppendingString:kSEARCH_CLUB];
    NSLog(@"URL: %@", url);
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:url]];
    
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
         NSLog(@"response: %@",jsons);
         self.tableData = jsons;
         [self.tableView reloadData];

     }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if([operation.response statusCode] == 403)
         {
             NSLog(@"Upload Failed");
             return;
         }
         NSLog(@"error: %@", [operation error]);
         
     }];
    
    [operation start];
    
}




- (IBAction)closeButtonAction:(id)sender {
    self.vPopup.hidden = YES;
}

- (IBAction)confirmRequestAction:(id)sender {
    self.vPopup.hidden = YES;
    
    NSDictionary* user = [[AppDelegate sharedDelegate] user];
    
    NSDictionary *data = self.tableData[selectedIndex];
    
    NSDictionary *parameters =@{@"user_id" : user[@"id"],
                                @"org_id": data[@"id"],
                                @"request_type" : @"0"
                                };
    NSLog(@"parameters:%@",parameters);
    NSURL * url = [NSURL URLWithString:[kBASE_NEW_API stringByAppendingString:kREQUEST_SEND]];
    NSLog(@"parameters:%@, url: %@",parameters, url);
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:url];
    
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
         
     }];
    
    [operation start];
    
}

- (IBAction)requestJoinAction:(id)sender {
    
    UIView * superView = [sender superview];
    while (![superView isKindOfClass:[UITableViewCell class]]) {
        superView = [superView superview];
    }
    
    
    UITableViewCell* cell = (UITableViewCell*) superView;
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    selectedIndex = (int)indexPath.row;
    NSLog(@"selected index %ld", (long)indexPath.row);
    self.vPopup.hidden = NO;
    
}


- (IBAction)viewClubMemberHandle:(id)sender {
    
    MemberListViewController * memberListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Club Member VC"];
    
    UIView * parView = (UIView *)sender;
    while (![parView isKindOfClass:[UITableViewCell class]]) {
        parView = parView.superview;
    }
    
    
    UITableViewCell* cell = (UITableViewCell*) parView;
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary* data = self.tableData[indexPath.row];
    
    memberListVC.clubId = data[@"id"];
    
    [self.navigationController pushViewController:memberListVC animated:YES];
    
}

// called when keyboard search button pressed

#pragma mark - 
#pragma mark - UITableViewDelegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
#pragma mark - UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableData.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Search Club Cell"];

    UILabel* nameLabel = (UILabel*)[cell viewWithTag:1];
    UILabel* descLabel = (UILabel*)[cell viewWithTag:2];
    UIImageView* cellView = (UIImageView*)[cell viewWithTag:3];
    UIButton * joinRequestBtn = (UIButton *) [cell viewWithTag:4];
    
    NSDictionary* user = [[AppDelegate sharedDelegate] user];
    
    NSDictionary* data = self.tableData[indexPath.row];

    if (![user[@"org_id"] isEqualToString:@"0"]) {
        joinRequestBtn.hidden = YES;
    } else {
        joinRequestBtn.hidden = NO;
    }
    
    
    if (![data[@"school_name"] isKindOfClass:[NSNull class]]) {
        descLabel.text = data[@"school_name"];
    } else
    {
        descLabel.text = @"";
    }
    nameLabel.text = data[@"name"];
    [cellView setImageWithURL:[NSURL URLWithString:[kBASE_UPLOAD_URL stringByAppendingString:data[@"logo"]]] placeholderImage:[UIImage imageNamed:@"placeholderlogo"]];
    return cell;
}

@end
