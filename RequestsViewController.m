//
//  RequestsViewController.m
//  Greeker
//
//  Created by Thohd on 8/8/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "RequestsViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"


@interface RequestsViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray* tableData;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)backAction:(UIButton *)sender;
@end

@implementation RequestsViewController

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
    NSDictionary* user = [[AppDelegate sharedDelegate] user];
    if ([user[@"org_id"] intValue]>0) {
        NSString* url = [kBASE_NEW_API stringByAppendingFormat:kREQUEST_LIST, [user[@"org_id"] intValue] ];
        NSLog(@"ur:%@",url);
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"json:%@",JSON);
            tableData = [NSArray arrayWithArray:JSON];
            [self.tableView reloadData];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"error:%@",[error description]);
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
- (void) acceptAction:(UIButton*)button event:(UIEvent*) event{
    
//    UITouch* touch = [[event allTouches] anyObject];
//    CGPoint point = [touch locationInView:self.tableView];
//    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:point];
//    NSLog(@"accept:%d",indexPath.row);
//    NSDictionary* user = [[AppDelegate sharedDelegate] user];
//    NSDictionary* data = tableData[indexPath.row];
//    NSString* url = [kBASE_URL stringByAppendingFormat:kACCEPT_REQUEST, [user[@"org_id"] intValue],  [data[@"id"] intValue]];
//    NSLog(@"ur:%@",url);
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        NSLog(@"json:%@",JSON);
//        tableData = [NSArray arrayWithArray:JSON];
//        [self.tableView reloadData];
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        NSLog(@"error:%@",[error description]);
//        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
//    }];
//    [operation start];
    

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
    //NSLog(@"Indexpath:%d",indexPath.row);
    NSDictionary* user = [[AppDelegate sharedDelegate] user];
    NSDictionary* data = tableData[indexPath.row];
    NSString* url = [kBASE_NEW_API stringByAppendingFormat:kPROCESS_REQUEST, [user[@"org_id"] intValue], [data[@"user_id"] intValue], accept? 1 : 0 ];
    NSLog(@"ur:%@",url);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"json:%@",JSON);
        tableData = [NSArray arrayWithArray:JSON];
        [self.tableView reloadData];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error:%@",[error description]);
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
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [tableData count];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    UILabel* textLabel = (UILabel*)[cell viewWithTag:1];
    UIButton* btnAccept = (UIButton*)[cell viewWithTag:2];
    UIButton* btnReject = (UIButton*)[cell viewWithTag:3];
    [btnAccept addTarget:self action:@selector(acceptAction:event:) forControlEvents:UIControlEventTouchUpInside];
    [btnReject addTarget:self action:@selector(rejectAction:event:) forControlEvents:UIControlEventTouchUpInside];
    NSDictionary* data = tableData[indexPath.row];
    if ([data[@"request_type"] intValue] == 0) {
        textLabel.text = [NSString stringWithFormat:@"%@ %@ has request to joined",data[@"first_name"],data[@"last_name"]];
    } else if ([data[@"request_type"] intValue] == 1) {
        textLabel.text = [NSString stringWithFormat:@"%@ %@ has request to be member",data[@"first_name"],data[@"last_name"]];
    } else {
        textLabel.text = [NSString stringWithFormat:@"%@ %@ has request to be admin",data[@"first_name"],data[@"last_name"]];
    }
    
    return cell;
}
- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
