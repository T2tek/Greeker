//
//  LookupChapterViewController.m
//  Greeker
//
//  Created by Thohd on 4/15/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "LookupChapterViewController.h"
#import "ChapterSelectorViewController.h"
#import "MyTextField.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface LookupChapterViewController () <UITextFieldDelegate>
{
    NSArray* clubs;
}
@property (strong, nonatomic) IBOutlet MyTextField *textOrg;
@property (strong, nonatomic) IBOutlet MyTextField *textSchool;
@property (strong, nonatomic) IBOutlet MyTextField *textCity;
@end

@implementation LookupChapterViewController

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
    self.textOrg.background = [UIImage imageNamed:@"textfieldbg"];
    self.textSchool.background = [UIImage imageNamed:@"textfieldbg"];
    self.textCity.background = [UIImage imageNamed:@"textfieldbg"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"searchChapterSegue"]) {
        ChapterSelectorViewController* viewController = segue.destinationViewController;
        viewController.tableData = clubs;
    }
}
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"searchChapterSegue"]) {
        NSString* textSearch = [self.textOrg.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
         NSString* textSchool = [self.textSchool.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSString* textCity = [self.textCity.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        
        
        if ([textSearch length]==0 && [textSchool length] == 0 && [textCity length] == 0) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter search key" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            return NO;
        }else{
            
            
            NSDictionary *parameters =@{@"textSearch" : textSearch,
                                        @"textSchool": textSchool,
                                        @"textCity" : textCity
                                        };
            
            NSString * url = [kBASE_NEW_API stringByAppendingString:kLOOKUP];
            NSLog(@"URL: %@", url);
            AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:url]];
            
            NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                
            }];
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 NSObject *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                 clubs = (NSArray *) jsons;
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 [self performSegueWithIdentifier:@"searchChapterSegue" sender:nil];
                 
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
             {
                 [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
             }];
            
            [operation start];
        }
        return NO;
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
