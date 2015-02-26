//
//  AboutMeViewController.m
//  Greeker
//
//  Created by Henry Nguyen on 12/12/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "AboutMeViewController.h"



@interface AboutMeViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation AboutMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.text = self.aboutString;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backHandle:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"About Me" object:nil
                                                      userInfo:[NSDictionary dictionaryWithObject:self.textView.text forKey:@"about_me"]];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)saveAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"About Me" object:nil
                                                      userInfo:[NSDictionary dictionaryWithObject:self.textView.text forKey:@"about_me"]];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
