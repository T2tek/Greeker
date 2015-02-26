//
//  AdminChatViewController.m
//  Greeker
//
//  Created by Thohd on 6/18/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "AdminChatViewController.h"

@interface AdminChatViewController ()<UITextFieldDelegate>
{
    
}
@property (strong, nonatomic) IBOutlet UITextField *textMessage;
@property (strong, nonatomic) IBOutlet UIView *vContent;
@property (strong, nonatomic) IBOutlet UIView *vSend;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendBottomConstraint;

- (IBAction)backAction:(UIButton *)sender;
- (IBAction)sendAction:(UIButton *)sender;

@end

@implementation AdminChatViewController

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
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [UIView animateWithDuration:.3 animations:^{
        self.sendBottomConstraint.constant = 216;
    }];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [UIView animateWithDuration:.3 animations:^{
        self.sendBottomConstraint.constant = 0;
    }];
}
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [self.textMessage resignFirstResponder];
    return YES;
}
- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendAction:(UIButton *)sender {
}
@end
