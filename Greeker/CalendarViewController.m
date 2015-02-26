//
//  CalendarViewController.m
//  Greeker
//
//  Created by Thohd on 6/18/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "CalendarViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "EventDetailViewController.h"

@interface CalendarViewController ()<UITableViewDataSource, UITableViewDelegate>
{

    NSArray *months;
    NSDateComponents *dateComponents;
    NSMutableDictionary *eventDictionary;
    NSInteger currentMonth;
}


@property (weak, nonatomic) IBOutlet UIView *monthCalenderView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *tableData;

@property (weak, nonatomic) IBOutlet UILabel *monthYearLabel;

- (IBAction)backAction:(UIButton *)sender;
@end

@implementation CalendarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSArray*) tableData
{
    if (_tableData == nil) {
        _tableData = [[NSMutableArray alloc] init];
    }
    return _tableData;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    dateComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    
    currentMonth = dateComponents.month;
    months = [NSArray arrayWithObjects:@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December", nil];
    eventDictionary = [[NSMutableDictionary alloc] init];
   // [eventDictionary setObject:@"d" forKey:@"12"];
    
 
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getEvents];
    [self drawCalendar];
}

-(void) drawCalendar
{
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    
    comps.year = dateComponents.year;
    comps.month = dateComponents.month;
    comps.day = 1;
    
    
    self.monthYearLabel.text = [NSString stringWithFormat:@"%@, %ld", months[dateComponents.month - 1], (long)dateComponents.year];
    NSDate *firstDayOfMonth = [gregorian dateFromComponents:comps];
    
    NSInteger dayofweek = [self getDateOfFirstDay: firstDayOfMonth];
    NSDate *fromDate = [NSDate dateWithTimeInterval:(dayofweek - 1) * 24 * 3600 * (-1) sinceDate:firstDayOfMonth];
    
    for (UIView *view in [self.monthCalenderView subviews]) {
        [view removeFromSuperview];
    }
    
    
    
    for(int i = 1; i < 7; i++){
        for (int j = 1; j<= 7; j++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((j - 1) * 43.5 + 7, (i - 1) * 37.5 + 10, 30, 30)];
            label.textAlignment = NSTextAlignmentCenter;

            
            
            NSDateComponents *compT = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit) fromDate:fromDate];
            
           // NSLog(@"Date comps %@", compT);
            label.text = [NSString stringWithFormat:@"%ld", (long)compT.day];
            fromDate = [NSDate dateWithTimeInterval:24 * 3600 sinceDate:fromDate];
            
            if (eventDictionary[label.text] != nil && compT.month == dateComponents.month) {
                UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake((j - 1) * 43.5 + 6, (i - 1) * 37.5 + 9, 32, 32)];
                imageV.image = [UIImage imageNamed:@"imgActiveDay.png"];
                [self.monthCalenderView addSubview:imageV];
            }
            
            if (compT.day == dateComponents.day && dateComponents.month == currentMonth) {
                UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake((j - 1) * 43.5 + 6, (i - 1) * 37.5 + 9, 31, 31)];
                imageV.image = [UIImage imageNamed:@"imgCurrentDay.png"];
                [self.monthCalenderView addSubview:imageV];
            }
            
            
            if (compT.month != dateComponents.month) {
                label.textColor = [UIColor darkGrayColor];
            } else {
                label.textColor = [UIColor whiteColor];
            }
            
            label.font = [UIFont systemFontOfSize:17];
            [self.monthCalenderView addSubview:label];
        }
    }
    
}

-(NSInteger) getDateOfFirstDay: (NSDate *) arbitraryDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:arbitraryDate];
    [comps setDay:1];
    NSDate *firstDayOfMonth = [gregorian dateFromComponents:comps];
    NSDateComponents *currDateComp = [gregorian components: (NSWeekdayCalendarUnit) fromDate:firstDayOfMonth];
    return currDateComp.weekday;
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

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary * data = self.tableData[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Calendar Event Cell"];
    UILabel *dateLabel = (UILabel *) [cell viewWithTag:1];
    UILabel *eventTitleLabel = (UILabel*) [cell viewWithTag:2];
    NSString *dueDate = data[@"due_date"];
    
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-mm-dd"];
    
    NSDate* eventDate = [formatter dateFromString:dueDate];
    
    [formatter setDateFormat:@"dd"];
    
    NSString *dayEvent = [formatter stringFromDate:eventDate];

    dateLabel.text = dayEvent;
    eventTitleLabel.text = data[@"title"];
    return cell;
}


- (IBAction)nextMonth:(id)sender {\
    
    if (dateComponents.month == 12) {
        dateComponents.month = 1;
        dateComponents.year += 1;
    } else {
        dateComponents.month += 1;
    }
    [self drawCalendar];
    [self getEvents];
}


- (IBAction)prevMonth:(id)sender {
    
    if (dateComponents.month == 1) {
        dateComponents.month = 12;
        dateComponents.year -= 1;
    } else {
        dateComponents.month -= 1;
    }
    [self drawCalendar];
    [self getEvents];
    
}


-(void) getEvents
{
    NSDictionary* user = [[AppDelegate sharedDelegate] user];
    if ([user[@"org_id"] intValue]>0) {
        NSString* url = [kBASE_NEW_API stringByAppendingFormat:kEVENT_LIST, [user[@"org_id"] intValue], (int) dateComponents.month, (int) dateComponents.year ];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.tableData = [NSArray arrayWithArray:JSON];
            [eventDictionary removeAllObjects];
            for (NSDictionary *event in self.tableData) {
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-mm-dd"];
                NSDate* eventDate = [formatter dateFromString:event[@"due_date"]];
                [formatter setDateFormat:@"d"];
                NSString *dayEvent = [formatter stringFromDate:eventDate];
                [eventDictionary setObject:@"anything" forKey:dayEvent];
                
            }
            [self drawCalendar];
            [self.tableView reloadData];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"error:%@",[error description]);
            [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }];
        [operation start];
    }
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Show Event Detail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *eventData = self.tableData[indexPath.row];
        EventDetailViewController *destCV = segue.destinationViewController;
        destCV.eventData = eventData;
    } else {
        NSLog(@"Segue identifier: %@", segue.identifier);
    }
    
}


- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
