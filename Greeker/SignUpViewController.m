//
//  SignUpViewController.m
//  Greeker
//
//  Created by Thohd on 4/14/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "SignUpViewController.h"
#import "CKCalendarView.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "Utility.h"

@interface SignUpViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate,CKCalendarDelegate>{
    NSArray* textFields;
    NSArray* pledgeClasses;
    NSArray* pledgeDetailClasses;
    CKCalendarView *calendar;
    NSArray* cityList;
    NSArray* schoolList;
    NSArray* orgList;
    NSInteger listMode;
    NSInteger pickedSchool;
    NSInteger pickedOrg;
    NSInteger pickedCity;
    UITextField *currentEdit;
    
}
@property (strong, nonatomic) IBOutlet UITextField *textName;
@property (strong, nonatomic) IBOutlet UITextField *textBirth;
@property (strong, nonatomic) IBOutlet UITextField *textPledge;
@property (strong, nonatomic) IBOutlet UITextField *textPosition;
@property (strong, nonatomic) IBOutlet UITextField *textSchool;
@property (strong, nonatomic) IBOutlet UITextField *textHometown;
@property (strong, nonatomic) IBOutlet UITextField *textEmail;
@property (strong, nonatomic) IBOutlet UITextField *textPhone;
@property (strong, nonatomic) IBOutlet UITextField *textMajor;
@property (strong, nonatomic) IBOutlet UITextField *textUsername;
@property (strong, nonatomic) IBOutlet UITextField *textPassword;
@property (strong, nonatomic) IBOutlet UIView *vContentView;
@property (strong, nonatomic) IBOutlet UIScrollView *vScrollView;
@property (strong, nonatomic) IBOutlet UIView *vPledge;
@property (strong, nonatomic) IBOutlet UIView *vList;
@property (strong, nonatomic) IBOutlet UITableView *pledgeTableView;
@property (strong, nonatomic) IBOutlet UITableView *listTableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
- (IBAction)signUpAction:(UIButton *)sender;
- (IBAction)backAction:(UIButton *)sender;
- (IBAction)birthAction:(UIButton *)sender;
- (IBAction)pledgeAction:(UIButton *)sender;
- (IBAction)hometownAction:(UIButton *)sender;
- (IBAction)orgAction:(UIButton *)sender;
- (IBAction)schoolAction:(UIButton *)sender;

@property (strong, nonatomic) NSString *pickedLetters;

@end

@implementation SignUpViewController



#pragma mark - 
#pragma mark - View lifecycle

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
    
    self.vScrollView.contentSize = self.vContentView.frame.size;
    UITapGestureRecognizer* gestureRecogizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.vContentView addGestureRecognizer:gestureRecogizer];
    textFields = @[self.textName, self.textBirth, self.textSchool, self.textPledge, self.textPosition, self.textHometown, self.textMajor, self.textPhone, self.textEmail,self.textUsername, self.textPassword];
    NSArray *oldPledgeClasses = @[@"α",@"β",@"γ",@"δ",@"ε",@"ζ",@"η",@"θ",@"ι",@"κ",@"λ",@"μ",@"ν",@"ξ",@"ο",@"π",@"ρ",@"σ",@"τ",@"υ",@"φ",@"χ",@"ψ",@"ω"];
    pledgeClasses = [self uppercaseArray:oldPledgeClasses];

    pledgeDetailClasses = @[@"Alpha",@"Beta",@"Gamma",@"Delta",@"Epsilon",@"Zeta",@"Eta",@"Theta",@"Iota",@"Kappa",@"Lambda",@"Mu",@"Nu",@"Ksi",@"Omicron",@"Pi",@"Rho",@"Sigma",@"Tau",@"Upsilon",@"Phi",@"Chi",@"Psi",@"Omega"];

    self.vPledge.hidden = YES;
    calendar = [[CKCalendarView alloc] init];
    CGRect r = calendar.frame;
    r.origin.y = 51;
    calendar.frame = r;
    [self.view addSubview:calendar];
    calendar.delegate = self;
    calendar.hidden = YES;
    
    self.textName.delegate = self;
    [self getCityList];
    //[self getOrgList];
    [self getSchoolList];
}

-(NSArray *) uppercaseArray:(NSArray *)oldArray
{
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    for (NSString *lowercaseString in oldArray) {
        [newArray addObject:[lowercaseString uppercaseString]];
    }
    return newArray;
}

- (void) handleTap:(UITapGestureRecognizer*)gestureRecognizer{
    [self.vContentView endEditing:YES];
    self.vPledge.hidden = YES;
    self.vList.hidden = YES;
}

- (IBAction)signUpAction:(UIButton *)sender {
    for (UITextField* textField in textFields) {
        NSString* text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([text length]==0) {
            [[[UIAlertView alloc] initWithTitle:@"Missing content" message:@"Please enter all field" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            return;
        }
    }
    
    NSString* username = [self.textUsername.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* name = [self.textName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray* nameparts = [name componentsSeparatedByString:@" "];
    NSString* firstname = name;
    NSString* lastname = @"";
    if ([nameparts count]>1) {
        firstname = nameparts[0];
        lastname = [[name substringFromIndex:[firstname length]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    NSString* password = [self.textPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* birthday = [self.textBirth.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* email = [self.textEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* position = [self.textPosition.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* major = [self.textMajor.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [userDefault objectForKey:@"device_token"];
    if (deviceToken == nil)
    {
        deviceToken = @"No Token";
    }
    
    NSDictionary *parameters =@{@"username" : username,
                                @"password" : password,
                                @"firstname": firstname,
                                @"lastname": lastname,
                                @"birthday": [Utility convertDate:birthday formatFrom:kFACEBOOK_DATE_FORMAT toFormat:kSERVER_DATE_FORMAT],
                                @"email": email,
                                @"photo": @"",
                                @"gender": @"1",
                                @"facebook" : @"",
                                @"school" : [NSString stringWithFormat:@"%@", self.textSchool.text],
                                @"hometown" : [NSString stringWithFormat:@"%@", self.textHometown.text],
                                @"position" : position,
                                @"major" : major,
                                @"pledge" : self.textPledge.text,
                                @"phone" : self.textPhone.text,
                                @"device_token" : deviceToken
                                
                                };
    NSLog(@"parameters:%@",parameters);
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:[kBASE_NEW_API stringByAppendingString:kSIGNUP_API]]];
    
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"signup response: %@",responseObject	);

         NSDictionary *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
         
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         
         NSLog(@"signup response: %@",jsons);
        
         UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:jsons[@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
         alert.delegate = self;
         [alert show];
         
     }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         if([operation.response statusCode] == 403)
         {
             NSLog(@"Upload Failed");
             return;
         }
         NSLog(@"error: %@", [operation error]);
     }];
    
    [operation start];

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (currentEdit != nil) {
        [currentEdit resignFirstResponder];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backAction:(UIButton *)sender {
    if (currentEdit != nil) {
        [currentEdit resignFirstResponder];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)birthAction:(UIButton *)sender {
    if (currentEdit != nil) {
        [currentEdit resignFirstResponder];
    }
    calendar.hidden = NO;
}

- (IBAction)pledgeAction:(UIButton *)sender {
    if (currentEdit != nil) {
        [currentEdit resignFirstResponder];
    }
    
    self.vPledge.hidden = NO;
    self.vList.hidden = YES;
    self.textPledge.text = @"";
    self.pickedLetters = @"";
}

- (IBAction)hometownAction:(UIButton *)sender {
    if (currentEdit != nil) {
        [currentEdit resignFirstResponder];
    }
    listMode = 2;
    self.vList.hidden = NO;
    self.vPledge.hidden = YES;
    [self.listTableView reloadData];
}

- (IBAction)orgAction:(UIButton *)sender {
    if (currentEdit != nil) {
        [currentEdit resignFirstResponder];
    }
    listMode = 1;
    self.vPledge.hidden = YES;
    self.vList.hidden = NO;
    [self.listTableView reloadData];
}

- (IBAction)schoolAction:(UIButton *)sender {
    if (currentEdit != nil) {
        [currentEdit resignFirstResponder];
    }
    listMode = 0;
    self.vPledge.hidden = YES;
    self.vList.hidden = NO;
    [self.listTableView reloadData];
}
#pragma mark - UITextFieldDelegate
- (void) textFieldDidBeginEditing:(UITextField *)textField{
    
    currentEdit = textField;
    self.vPledge.hidden = YES;
    self.vList.hidden = YES;
    calendar.hidden = YES;
    if (textField.tag==6) {
        self.topConstraint.constant = -20;
    }else if (textField.tag==7){
        self.topConstraint.constant = -(20+54);
    }else if (textField.tag==8){
        self.topConstraint.constant = -(20+54*2);
    }else if (textField.tag==9){
        self.topConstraint.constant = -(20+54*3);
    }else if (textField.tag==10){
        self.topConstraint.constant = -(20+54*4);
    }else if (textField.tag==11){
        self.topConstraint.constant = -(20+54*6);
    }else if (textField.tag==12){
        self.topConstraint.constant = -(20+54*7.3);
    }
}
- (void) textFieldDidEndEditing:(UITextField *)textField{
    self.topConstraint.constant = 0;
}
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 
#pragma mark - CKCalendarDelegate
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView==self.pledgeTableView) {
        return [pledgeClasses count];
    }else{
        switch (listMode) {
            case 0:
                return [schoolList count];
            case 1:
                return [orgList count];
            case 2:
                return [cityList count];
        }
    }
    return 0;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = nil;
    if (tableView==self.pledgeTableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"pledgeCell"];
        cell.textLabel.text = pledgeClasses[indexPath.row];
        cell.detailTextLabel.text = pledgeDetailClasses[indexPath.row];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"itemCell"];

        NSString* data = @"";
        switch (listMode) {
            case 0:
                data = schoolList[indexPath.row][@"name"];
                break;
            case 1:
                data = orgList[indexPath.row][@"name"];
                break;
            case 2:
                data = cityList[indexPath.row][@"name"];
                break;
        }
        cell.textLabel.text = data;
    }

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.pledgeTableView) {
        //self.vPledge.hidden = YES;
        if ([self.textPledge.text isEqualToString:@""]) {
            self.textPledge.text = pledgeDetailClasses[indexPath.row];
        } else {
            self.textPledge.text =  [NSString stringWithFormat:@"%@ %@",self.textPledge.text, pledgeDetailClasses[indexPath.row]];
        }
        self.pickedLetters = [NSString stringWithFormat:@"%@%@",self.pickedLetters, pledgeClasses[indexPath.row]];
        
    }else{
        self.vList.hidden = YES;
        
        switch (listMode) {
            case 0:
                pickedSchool = [schoolList[indexPath.row][@"id"] integerValue];
                self.textSchool.text = schoolList[indexPath.row][@"name"];
                
                break;
            case 1:
                pickedOrg =  [orgList[indexPath.row][@"id"] integerValue];
                break;
            case 2:
                pickedCity =  [cityList[indexPath.row][@"id"] integerValue];
                self.textHometown.text = cityList[indexPath.row][@"name"];
                break;
        }

    }
}
#pragma mark -
#pragma mark - CKCalendarDelegate
- (BOOL)calendar:(CKCalendarView *)calendar willSelectDate:(NSDate *)date {
    // don't let people select dates in previous/next month
    return YES;
}
- (void)calendar:(CKCalendarView *)cal didSelectDate:(NSDate *)date {
    //NSLog(@"selected:%@",date);
    calendar.hidden = YES;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:kFACEBOOK_DATE_FORMAT];
    self.textBirth.text = [format stringFromDate:date];
}
- (BOOL)calendar:(CKCalendarView *)calendar willChangeToMonth:(NSDate *)date {
    // Of course we want to let users change months...
    return YES;
}

- (void)calendar:(CKCalendarView *)calendar didChangeToMonth:(NSDate *)date {
    //NSLog(@"Hurray, the user changed months!");
}

#pragma mark -
#pragma mark - api
- (void) getSchoolList
{
    NSString* url = [kBASE_URL stringByAppendingString:kSCHOOL_LIST];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        schoolList = [NSArray arrayWithArray:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"error:%@",[error description]);
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }];
    [operation start];
    
}
- (void) getCityList
{
    NSString* url = [kBASE_URL stringByAppendingString:kCITY_LIST];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        cityList = [NSArray arrayWithArray:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"error:%@",[error description]);
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }];
    [operation start];
}
- (void) getOrgList
{
    NSString* url = [kBASE_URL stringByAppendingString:kORG_LIST];
    NSLog(@"ur:%@",url);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"json:%@",JSON);
        orgList = [NSArray arrayWithArray:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"error:%@",[error description]);
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }];
    [operation start];
}

@end
