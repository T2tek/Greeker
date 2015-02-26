//
//  MyProfileViewController.m
//  Greeker
//
//  Created by Thohd on 6/17/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "MyProfileViewController.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import <QuartzCore/QuartzCore.h>

@interface MyProfileViewController ()
{
    NSArray *pledgeClasses;
    NSArray *pledgeDetailClasses;
    NSDictionary * pledgeClassDic;
}

@property (strong, nonatomic) IBOutlet UIImageView *coverView;
@property (strong, nonatomic) IBOutlet UIImageView *avatarView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *roleLabel;
@property (strong, nonatomic) IBOutlet UILabel *pledgeLabel;
@property (strong, nonatomic) IBOutlet UILabel *hometownLabel;
@property (strong, nonatomic) IBOutlet UILabel *birthLabel;
@property (strong, nonatomic) IBOutlet UILabel *majorLabel;
@property (strong, nonatomic) IBOutlet UITextView *aboutTextView;
@property (weak, nonatomic) IBOutlet UIImageView *bannerView;

@end

@implementation MyProfileViewController

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
    NSArray *oldPledgeClasses = @[@"α",@"β",@"γ",@"δ",@"ε",@"ζ",@"η",@"θ",@"ι",@"κ",@"λ",@"μ",@"ν",@"ξ",@"ο",@"π",@"ρ",@"σ",@"τ",@"υ",@"φ",@"χ",@"ψ",@"ω"];
    pledgeClasses = [self uppercaseArray:oldPledgeClasses];
    pledgeDetailClasses = @[@"Alpha",@"Beta",@"Gamma",@"Delta",@"Epsilon",@"Zeta",@"Eta",@"Theta",@"Iota",@"Kappa",@"Lambda",@"Mu",@"Nu",@"Ksi",@"Omicron",@"Pi",@"Rho",@"Sigma",@"Tau",@"Upsilon",@"Phi",@"Chi",@"Psi",@"Omega"];

    pledgeClassDic = [NSDictionary dictionaryWithObjects:pledgeDetailClasses forKeys:pledgeClasses];
}

-(NSArray *) uppercaseArray:(NSArray *)oldArray
{
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    for (NSString *lowercaseString in oldArray) {
        [newArray addObject:[lowercaseString uppercaseString]];
    }
    return newArray;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSDictionary* user = [[AppDelegate sharedDelegate] user];
    if (![user[@"photo"] isKindOfClass:[NSNull class]]) {
        BOOL result = [[user[@"photo"] lowercaseString] hasPrefix:@"http"];
        if (result) {
            [self.avatarView setImageWithURL:[NSURL URLWithString:user[@"photo"]] placeholderImage:[UIImage imageNamed:@"placeholderavatar"]];
        } else
        {
            [self.avatarView setImageWithURL:[NSURL URLWithString:[kBASE_UPLOAD_URL stringByAppendingString:user[@"photo"]]] placeholderImage:[UIImage imageNamed:@"placeholderavatar"]];
        }
    }
    if (![user[@"banner"] isKindOfClass:[NSNull class]]) {
        BOOL result = [[user[@"banner"] lowercaseString] hasPrefix:@"http"];
        if (result) {
            [self.bannerView setImageWithURL:[NSURL URLWithString:user[@"banner"]] placeholderImage:[UIImage imageNamed:@"placeholdercover"]];
        } else
        {
            [self.bannerView setImageWithURL:[NSURL URLWithString:[kBASE_UPLOAD_URL stringByAppendingString:user[@"banner"]]] placeholderImage:[UIImage imageNamed:@"placeholdercover"]];
        }
    }
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",user[@"first_name"], user[@"last_name"]];
    if (![user[@"city_name"] isKindOfClass:[NSNull class]]) {
        self.hometownLabel.text = user[@"city_name"];
    } else
    {
        self.hometownLabel.text = @"N/A";
    }
    
    if (![user[@"major"] isKindOfClass:[NSNull class]]) {
        self.majorLabel.text = user[@"major"];
    }
    if (![user[@"position"] isKindOfClass:[NSNull class]]) {
        self.roleLabel.text = user[@"position"];
    }
    if (![user[@"pledge_class"] isKindOfClass:[NSNull class]]) {
        
        NSString *pledge = [user[@"pledge_class"] uppercaseString];
        /*
        NSMutableString * pledgeSpell = [NSMutableString stringWithString:@""];
        for (int i = 0; i < pledge.length; i ++) {
            NSString * str =
            
        }
         
        */
        if (pledgeClassDic[pledge] != nil) {
            self.pledgeLabel.text = pledgeClassDic[pledge];
        } else {
            self.pledgeLabel.text = user[@"pledge_class"];
        }
        
        
        //user[@"pledge_class"];
    }
    
    if (![user[@"about_me"] isKindOfClass:[NSNull class]]) {
        self.aboutTextView.text = user[@"about_me"];
    }
    
    NSString* birthday = user[@"birthday"];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* date = [formatter dateFromString:birthday];
    [formatter setDateFormat:@"dd MMM yyyy"];
    
    self.birthLabel.text = [formatter stringFromDate:date];
    self.avatarView.layer.cornerRadius = self.avatarView.frame.size.width/2;
    self.avatarView.layer.masksToBounds = YES;
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

@end
