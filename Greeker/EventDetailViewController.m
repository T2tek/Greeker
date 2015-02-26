//
//  EventDetailViewController.m
//  Greeker
//
//  Created by Thohd on 6/25/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "EventDetailViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "MemberGoingViewController.h"
#import "Utility.h"
#import "ShowLocationViewController.h"

@interface EventDetailViewController ()
{
    BOOL alreadyGoing;
    NSMutableArray *memberGoingArr;
}
- (IBAction)backAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIImageView *eventImage;
@property (weak, nonatomic) IBOutlet UILabel *eventTitle;
@property (weak, nonatomic) IBOutlet UILabel *eventDueTime;

@property (weak, nonatomic) IBOutlet UILabel *eventLocation;
@property (weak, nonatomic) IBOutlet UITextView *eventDetail;
@property (weak, nonatomic) IBOutlet UIButton *whoGoingBtn;
@property (weak, nonatomic) IBOutlet UILabel *whoGoingLabel;
@property (weak, nonatomic) IBOutlet UIButton *goingBtn;

@property (weak, nonatomic) IBOutlet UILabel *goingLabel;
@end

@implementation EventDetailViewController

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
    alreadyGoing = NO;
    self.goingLabel.text = @"Going";
    
    self.eventTitle.text = self.eventData[@"title"];
    self.eventLocation.text = self.eventData[@"location"];
    
    self.eventDetail.text = self.eventData[@"detail"];
    
    if (![self.eventData[@"due_time"] isKindOfClass:[NSNull class]]) {
        self.eventDueTime.text = [Utility convertDate:self.eventData[@"due_time"] formatFrom:kSERVER_TIME_FORMAT toFormat:kUS_TIME_FORMAT];
        
    }

    if (![self.eventData[@"image"] isKindOfClass:[NSNull class]]) {
        [self.eventImage setImageWithURL:[NSURL URLWithString:[kBASE_UPLOAD_URL stringByAppendingString:self.eventData[@"image"]]] placeholderImage:[UIImage imageNamed:@"placeholderavatar.png"]];
    } else {
        self.eventImage.image = [UIImage imageNamed:@"placeholderavatar.png"];
    }
    
    memberGoingArr = [NSMutableArray arrayWithArray:self.eventData[@"going"]];
    
    NSDictionary *user = [AppDelegate sharedDelegate].user;
    for (NSDictionary *memberGoing in self.eventData[@"going"]) {
        if ([memberGoing[@"user_id"] isEqualToString:user[@"id"]]) {
            self.goingLabel.text = @"Not Going";
            alreadyGoing = YES;
            break;
        }
    }
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goingTouch:(id)sender {
    
    NSDictionary *user = [AppDelegate sharedDelegate].user;
    NSString* url = [kBASE_NEW_API stringByAppendingFormat:kGOING_EVENT, [self.eventData[@"id"] intValue], [user[@"id"] intValue]];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        if (alreadyGoing) {
            // not go
            alreadyGoing = NO;
            self.goingLabel.text = @"Going";
            // remove khoi going
            NSMutableArray * tempArr = [[NSMutableArray alloc] init];
            for (NSDictionary *memberGoing in self.eventData[@"going"]) {
                
                if ([memberGoing[@"user_id"] isEqualToString:user[@"id"]]) {
                   
                } else {
                    [tempArr addObject:memberGoing];
                }
            }
            memberGoingArr = tempArr;
        } else {
            
            alreadyGoing = YES;
            self.goingLabel.text = @"Not Going";
            // insert vao going
            [memberGoingArr addObject:user];
        }
       // [[[UIAlertView alloc] initWithTitle:@"Great!" message:@"You have been register to this event!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"error:%@",[error description]);
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }];
    [operation start];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    

    if ([segue.identifier isEqualToString:@"showEventLocation"]) {
        ShowLocationViewController *destVC = segue.destinationViewController;
        destVC.locationAddress = self.eventLocation.text;
        destVC.locationTitle = self.eventTitle.text;
    } else {
        MemberGoingViewController *destVC = segue.destinationViewController;
        destVC.memberGoing = memberGoingArr;
        destVC.eventId = self.eventData[@"id"];
    }
}


- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
