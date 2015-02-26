//
//  AddMemberViewController.m
//  Greeker
//
//  Created by HuuHoang on 9/10/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "AddMemberViewController.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import <QuartzCore/QuartzCore.h>

@interface AddMemberViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray* tableData;
@end

@implementation AddMemberViewController
{
    int selectedIndex;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSMutableArray *) tableData {
    if (_tableData == nil) {
        // get table data...
        _tableData = [[NSMutableArray alloc] init];
    }
    return _tableData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchBar.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
	// Do any additional setup after loading the view.
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
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
    NSString * url = [kBASE_NEW_API stringByAppendingString:kSEARCH_MEMBER];
    NSLog(@"URL: %@", url);
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:url]];
    
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self.tableData removeAllObjects];
         NSArray *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
         NSLog(@"response: %@",jsons);
         for (NSMutableDictionary *dictionary in jsons) {
             [self.tableData addObject:dictionary];
         }
         [self.tableView reloadData];
     }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
         
     }];
    
    [operation start];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* data = self.tableData[indexPath.row];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Search Member Cell"];
    UILabel* nameLabel = (UILabel*)[cell viewWithTag:1];
    UILabel* descLabel = (UILabel*)[cell viewWithTag:2];
    UIImageView* cellView = (UIImageView*)[cell viewWithTag:3];
    UIButton * btnInvite = (UIButton *) [cell viewWithTag:4];
    NSString *userPhotoURL;
    NSString *userInfo;
    NSString *fullName;
    if (![data[@"first_name"] isKindOfClass:[NSNull class]]) {
        fullName = data[@"first_name"] ;
    }
    if (![data[@"last_name"] isKindOfClass:[NSNull class]]) {
        fullName = [fullName stringByAppendingString:[NSString stringWithFormat:@" %@",data[@"last_name"]]] ;
    }
    if (![data[@"school_name"] isKindOfClass:[NSNull class]]) {
        userInfo = data[@"school_name"];
    }
    if (![data[@"city_name"] isKindOfClass:[NSNull class]]) {
        userInfo = [userInfo stringByAppendingString:[NSString stringWithFormat:@" (%@)",data[@"city_name"]]];
    }
    if (![data[@"org_id"] isKindOfClass:[NSNull class]] || ![data[@"id_of_invite"] isKindOfClass:[NSNull class]]) {
        btnInvite.hidden = YES;
    } else
    {
        btnInvite.hidden = NO;
    }
    //
    if (![data[@"photo"] isKindOfClass:[NSNull class]]) {
        userPhotoURL = data[@"photo"];
    } else {
        userPhotoURL = @"";
    }
    nameLabel.text = fullName;
    descLabel.text = userInfo;
    
    
    BOOL result = [[userPhotoURL lowercaseString] hasPrefix:@"http"];
    if (result) {
        [cellView setImageWithURL:[NSURL URLWithString:userPhotoURL] placeholderImage:[UIImage imageNamed:@"placeholderavatar.png"]];
    } else
    {
        [cellView setImageWithURL:[NSURL URLWithString:[kBASE_UPLOAD_URL stringByAppendingString:userPhotoURL]] placeholderImage:[UIImage imageNamed:@"placeholderavatar"]];
    }
    cellView.layer.cornerRadius = cellView.frame.size.width/2;
    cellView.layer.masksToBounds = YES;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

-(void)inviteMember:(id)sender
{
    NSMutableDictionary *data = self.tableData[selectedIndex];
    NSLog(@"What Data : %@",data);
    
    
    NSDictionary *user = [AppDelegate sharedDelegate].user;
    NSDictionary *parameters =@{
                                @"user_id" :data[@"id"],
                                @"org_id" :user[@"org_id"],
                                @"user_invite_id" :user[@"id"],
                                };
    NSString * url = [kBASE_NEW_API stringByAppendingString:kINVITE_MEMBER];
    NSLog(@"URL: %@", url);
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:url]];
    
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
    }];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         UITableViewCell* cell = (UITableViewCell*)[[[sender superview] superview] superview];
         UIButton *button = (UIButton *) [cell viewWithTag:4];
         button.hidden = YES;
         [self.tableData[selectedIndex] setValue:user[@"id"] forKey:@"id_of_invite"];
         UIAlertView *success = [[UIAlertView alloc] initWithTitle: nil message: [NSString stringWithFormat:@"%@ %@ send request invite club success",data[@"first_name"],data[@"last_name"]] delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
         [success show];
         
     }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
         
     }];
    [operation start];
    NSLog(@"Invite Member");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)requestJoinAction:(id)sender {
    UITableViewCell* cell = (UITableViewCell*)[[[sender superview] superview] superview];
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    selectedIndex = (int)indexPath.row;
    [self inviteMember:sender];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
