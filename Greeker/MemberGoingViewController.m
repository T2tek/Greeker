//
//  MemberGoingViewController.m
//  Greeker
//
//  Created by Hoang Nguyen on 30/09/2014.
//  Copyright (c) Năm 2014 Thohd. All rights reserved.
//

#import "MemberGoingViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <QuartzCore/QuartzCore.h>

@interface MemberGoingViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MemberGoingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self gotoEventDetail:self.eventId];
}

- (IBAction)backTouch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.memberGoing.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *data = self.memberGoing[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Member Going Cell"];
    UIImageView *image =  (UIImageView *)[cell viewWithTag:1];
    UILabel *label = (UILabel *)[cell viewWithTag:2];
    if (![data[@"photo"] isKindOfClass:[NSNull class]]) {
        
        BOOL result = [[data[@"photo"] lowercaseString] hasPrefix:@"http"];
        if (result) {
            [image setImageWithURL:[NSURL URLWithString:data[@"photo"]] placeholderImage:[UIImage imageNamed:@"placeholderavatar"]];
        } else
        {
            [image setImageWithURL:[NSURL URLWithString:[kBASE_UPLOAD_URL stringByAppendingString:data[@"photo"]]] placeholderImage:[UIImage imageNamed:@"placeholderavatar"]];
        }
        image.layer.cornerRadius = image.frame.size.width/2;
        image.layer.masksToBounds = YES;
    }
    label.text = [NSString stringWithFormat:@"%@ %@", data[@"first_name"], data[@"last_name"]];
    return cell;
}

-(void) gotoEventDetail: (NSString * ) eventId
{
    NSString* url = [kBASE_NEW_API stringByAppendingFormat:@"/eventinfo/%@", eventId];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"Event Detail:%@",JSON);
        NSDictionary * eventResponse = JSON;
        
        if ([eventResponse[@"status_code"] isKindOfClass:[NSNull class]] || eventResponse[@"status_code"] == nil) {
           
            self.memberGoing = eventResponse[@"going"];
            [self.tableView reloadData];
  
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Information!" message:@"Event is not existed or deleted" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }

        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"error:%@",[error description]);
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }];
    [operation start];
}

@end
