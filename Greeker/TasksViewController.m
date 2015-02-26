//
//  TasksViewController.m
//  Greeker
//
//  Created by Thohd on 6/18/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "TasksViewController.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "TaskInfoViewController.h"
#import "TaskNewViewController.h"

@interface TasksViewController ()<UITableViewDataSource, UITableViewDelegate>
- (IBAction)backAction:(UIButton *)sender;


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *tableData;
@end

@implementation TasksViewController

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
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
}

-(void) viewWillAppear:(BOOL)animated
{
    NSDictionary* user = [[AppDelegate sharedDelegate] user];
    if ([user[@"org_id"] intValue]>0) {
        NSString* url = [kBASE_NEW_API stringByAppendingFormat:kTASK_LIST, [user[@"org_id"] intValue], [user[@"id"] intValue] ];
        NSLog(@"ur:%@",url);
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"json:%@",JSON);
            self.tableData = [NSArray arrayWithArray:JSON];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * data = self.tableData[indexPath.row];
    UITableViewCell *taskCell = [tableView dequeueReusableCellWithIdentifier:@"Task Cell"];
    UIImageView *taskImage = (UIImageView*)[taskCell viewWithTag:1];
    
    UILabel *taskNameLabel = (UILabel *) [taskCell viewWithTag:2];

    UILabel *taskSubTitle = (UILabel *) [taskCell viewWithTag:3];
    
    UILabel *createBy = (UILabel *) [taskCell viewWithTag:4];
    
    taskNameLabel.text = data[@"title"];
    
    if ([data[@"status"] intValue] == 0) {
        taskImage.image = [UIImage imageNamed:@"task_imgred.png"];
         taskSubTitle.text = @"(Pending)";
    }
    else if ([data[@"status"] intValue] == 1)
    {
        taskImage.image = [UIImage imageNamed:@"task_imgyellow.png"];
        NSArray * userOnIt = data[@"user_on_it"];
        NSString *txt = @"";
        int i = 0;
        for (NSDictionary *userOn in userOnIt) {
            if (i == 0) {
                txt = userOn[@"last_name"];
            } else {
                txt = [NSString stringWithFormat:@"%@, %@", txt, userOn[@"last_name"]];
            }
        }
        taskSubTitle.text = [NSString stringWithFormat:@"(%@ on it)", txt];
    } else {
        taskImage.image = [UIImage imageNamed:@"task_imgblue.png"];
        taskSubTitle.text = @"(Completed)";
    }
    
    createBy.text = [NSString stringWithFormat:@"Create by: %@ %@", data[@"first_name"], data[@"last_name"]];
    return taskCell;
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"TaskDetail"]) {
        TaskInfoViewController *destVC = segue.destinationViewController;
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        destVC.taskData = self.tableData[indexPath.row];
    }
}

- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
