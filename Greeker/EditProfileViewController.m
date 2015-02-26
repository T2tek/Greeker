//
//  EditProfileViewController.m
//  Greeker
//
//  Created by Thohd on 6/18/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "EditProfileViewController.h"
#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
#import "CKCalendar/CKCalendarView.h"
#import "MyTextField.h"
#import "Utility.h"
#import "YCameraViewController.h"
#import "AboutMeViewController.h"
//#import "SevenSwitchExample-Swift.h"

@interface EditProfileViewController ()<UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CKCalendarDelegate,YCameraViewControllerDelegate>
{
    CKCalendarView* calendar;
    UIImage* pickedImage;
    NSArray* schoollist;
    NSArray* citylist;
    BOOL showSchool;
    NSInteger pickedSchool;
    NSInteger pickedCity;
    NSArray* pledgeClasses;
    NSArray* pledgeDetailClasses;
    BOOL isEditing;
    int showEmailToNonMember;
    NSString *userId;
    NSString *currentRequest;
    UIImage *pickImageBanner;
    UIImage *pickImagePhoto;
    int imageType;
    NSDictionary * pledgeClassDic;
}

- (IBAction)backAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *vScrollView;
@property (weak, nonatomic) IBOutlet UIView *vBody;
@property (strong, nonatomic) IBOutlet UILabel *lbFullName;
@property (strong, nonatomic) IBOutlet UILabel *lbPosition;
@property (strong, nonatomic) IBOutlet UIButton *btnEditPosition;

@property (strong, nonatomic) IBOutlet UILabel *lbClass;
@property (strong, nonatomic) IBOutlet UILabel *lbMajor;
@property (strong, nonatomic) IBOutlet UILabel *lbBirthday;
@property (strong, nonatomic) IBOutlet UILabel *lbPhone;
@property (strong, nonatomic) IBOutlet UILabel *lbEmail;
@property (weak, nonatomic) IBOutlet UIImageView *bannerView;

@property (strong, nonatomic) IBOutlet UIImageView *avatarView;
@property (strong, nonatomic) IBOutlet UIButton *classButtonEditDone;
@property (strong, nonatomic) IBOutlet UITextField *classTextfield;
@property (strong, nonatomic) IBOutlet UIView *vPledge;
@property (strong, nonatomic) IBOutlet UITableView *pledgeTableView;
@property (strong, nonatomic) IBOutlet MyTextField *phoneTextField;
@property (strong, nonatomic) IBOutlet MyTextField *majorTextField;
@property (strong, nonatomic) IBOutlet MyTextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *roleTextField;
@property (weak, nonatomic) IBOutlet UIView *vPopup;
@property (weak, nonatomic) IBOutlet MyTextField *tfHomeTown;
@property (weak, nonatomic) IBOutlet UILabel *lbHomeTown;

@property (weak, nonatomic) IBOutlet UIView *vHomeTownList;
@property (weak, nonatomic) IBOutlet UITableView *homeTownTableView;
@property (weak, nonatomic) IBOutlet UILabel *messagePopup;

// edit button

@property (strong, nonatomic) IBOutlet UIButton *btnMajorEdit;
@property (strong, nonatomic) IBOutlet UIButton *btnPhoneEdit;
@property (strong, nonatomic) IBOutlet UIButton *btnEmailEdit;
@property (strong, nonatomic) IBOutlet UIButton *btnRoleEdit;


@property (strong, nonatomic) IBOutlet UISwitch *showEmailSwitch;

@property (weak, nonatomic) IBOutlet UITextView *tvAboutMe;

// bottom button
@property (weak, nonatomic) IBOutlet UIButton *btnLeaveClub;
@property (weak, nonatomic) IBOutlet UIButton *btnReqMember;
@property (weak, nonatomic) IBOutlet UIButton *btnReqAdmin;

@property (weak, nonatomic) IBOutlet UIButton *btnEditClass;


@property (strong, nonatomic) NSMutableArray * buttonArr;
@property (strong, nonatomic) NSMutableArray * textfieldArr;
@property (strong, nonatomic) NSMutableArray * labelArr;

- (IBAction)logoutAction:(UIButton *)sender;

@end

@implementation EditProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)editHomeTown:(id)sender {
    if (isEditing) {
        [self doneEditing];
        return;
    }
    [self startEditing:self.btnHomeTown tf:self.tfHomeTown lb:self.lbHomeTown];
    
}

- (IBAction)editAboutMe:(id)sender {
}

- (IBAction)pledgeClassEditHandle:(id)sender {
    
    self.vPledge.hidden = NO;
    self.lbClass.text = @"";
    
}
- (IBAction)changeShowEmail:(id)sender {
    UISwitch *uiswitch = sender;
    if(uiswitch.on)
    {
       // self.showEmailSwitch.on = NO;
        showEmailToNonMember = 1;
    } else{
        showEmailToNonMember = 0;
    }
    [self saveData];
}

- (IBAction)editBirthday:(id)sender {
    calendar.hidden = NO;
}

- (IBAction)editRoleHandle:(id)sender {
    if (isEditing) {
        [self doneEditing];
        return;
    }
    [self startEditing:self.btnRoleEdit tf:self.roleTextField lb:self.lbPosition];
}

// button edit major tap
- (IBAction)editMajorHandle:(id)sender {
    if (isEditing) {
        [self doneEditing];
        return;
    }
    [self startEditing:self.btnMajorEdit tf:self.majorTextField lb:self.lbMajor];
}


- (IBAction)editPhoneHandle:(id)sender {
    if (isEditing) {
        [self doneEditing];
        return;
    }
    [self startEditing:self.btnPhoneEdit tf:self.phoneTextField lb:self.lbPhone];
}


- (IBAction)editEmailHandle:(id)sender {
    if (isEditing) {
        [self doneEditing];
        return;
    }
    [self startEditing:self.btnEmailEdit tf:self.emailTextField lb:self.lbEmail];
}

-(void) startEditing: (UIButton *) abtn tf: (UITextField *) atf lb: (UILabel *) alb
{
    for (int i = 0; i < self.textfieldArr.count; i++) {
        UILabel * lbi = (UILabel *)self.labelArr[i];
        UITextField *tfi = (UITextField * ) self.textfieldArr[i];
        lbi.text = tfi.text;
    }
    
    for (UITextField * tf in self.textfieldArr) {
        tf.hidden = YES;
    }
    
    for (UIButton *btn in self.buttonArr) {
        [btn setTitle:@"Edit" forState:UIControlStateNormal];
    }
    
    for (UILabel *lb in self.labelArr) {
        lb.hidden = NO;
    }
    
    [abtn setTitle:@"Done" forState:UIControlStateNormal];
    alb.hidden = YES;
    atf.hidden = NO;
    
    [self saveData];
    isEditing = YES;
}

-(void) doneEditing
{
    for (int i = 0; i < self.textfieldArr.count; i++) {
        UILabel * lbi = (UILabel *)self.labelArr[i];
        UITextField *tfi = (UITextField * ) self.textfieldArr[i];
        lbi.text = tfi.text;
    }
    
    for (UITextField * tf in self.textfieldArr) {
        tf.hidden = YES;
        [tf resignFirstResponder];
    }
    
    for (UIButton *btn in self.buttonArr) {
        [btn setTitle:@"Edit" forState:UIControlStateNormal];
    }
    
    for (UILabel *lb in self.labelArr) {
        lb.hidden = NO;
    }

    isEditing = NO;
    [self saveData];
    return;
}

- (IBAction)editBannerHandle:(id)sender {
    imageType = 1;
    [self chosePhoto];
}

- (IBAction)editPhotohandle:(id)sender {
    imageType = 0;
    [self chosePhoto];
}

-(void)chosePhoto
{
    YCameraViewController *camController = [[YCameraViewController alloc] initWithNibName:@"YCameraViewController" bundle:nil];
    camController.delegate=self;
    
    [self presentViewController:camController animated:YES completion:^{
        // completion code
    }];
}

-(void)didFinishPickingImage:(UIImage *)image{
    // Use image as per your need
    if (imageType) {
        self.bannerView.image = image;
        pickImageBanner = image;
    } else
    {
        self.avatarView.image = image;
        pickImagePhoto = image;
    }
    [self saveData];
}
-(void)yCameraControllerdidSkipped{
    // Called when user clicks on Skip button on YCameraViewController view
}

-(void)yCameraControllerDidCancel{
    // Called when user clicks on "X" button to close YCameraViewController
}


-(void) textViewDidBeginEditing:(UITextView *)textView1
{
    MyTextField *textView = (MyTextField*) textView1;
    if (textView == self.phoneTextField || textView == self.emailTextField || textView == self.majorTextField) {
        [UIView animateWithDuration:.3 animations:^{
            CGRect r = self.view.frame;
            r.origin.y -= 80;
            self.view.frame = r;
            
        }];
    }
}

-(void) textViewDidEndEditing:(UITextView *)textView1
{
    MyTextField *textView = (MyTextField*) textView1;
    if (textView == self.phoneTextField || textView == self.emailTextField || textView == self.majorTextField) {
    [UIView animateWithDuration:.3 animations:^{
        CGRect r = self.view.frame;
        r.origin.y = 0;
        self.view.frame = r;
        
    }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self doneEditing];
    return NO;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.vScrollView.contentSize = self.vBody.frame.size;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAboutMe:) name:@"About Me" object:nil];
    
    NSArray *oldPledgeClasses = @[@"α",@"β",@"γ",@"δ",@"ε",@"ζ",@"η",@"θ",@"ι",@"κ",@"λ",@"μ",@"ν",@"ξ",@"ο",@"π",@"ρ",@"σ",@"τ",@"υ",@"φ",@"χ",@"ψ",@"ω"];
    pledgeClasses = [self uppercaseArray:oldPledgeClasses];
    pledgeDetailClasses = @[@"Alpha",@"Beta",@"Gamma",@"Delta",@"Epsilon",@"Zeta",@"Eta",@"Theta",@"Iota",@"Kappa",@"Lambda",@"Mu",@"Nu",@"Ksi",@"Omicron",@"Pi",@"Rho",@"Sigma",@"Tau",@"Upsilon",@"Phi",@"Chi",@"Psi",@"Omega"];
    
    pledgeClassDic = [NSDictionary dictionaryWithObjects:pledgeDetailClasses forKeys:pledgeClasses];
    
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
    
    self.lbFullName.text = [NSString stringWithFormat:@"%@ %@",user[@"first_name"], user[@"last_name"]];
   
    if (![user[@"major"] isKindOfClass:[NSNull class]]) {
        self.lbMajor.text = user[@"major"];
    }
    
    if (![user[@"position"] isKindOfClass:[NSNull class]]) {
        self.lbPosition.text = user[@"position"];
    }
    
    if (![user[@"pledge_class"] isKindOfClass:[NSNull class]]) {
        
        NSString *pledge = [user[@"pledge_class"] uppercaseString];

        if (pledgeClassDic[pledge] != nil) {
            self.lbClass.text = pledgeClassDic[pledge];
        } else {
            self.lbClass.text = user[@"pledge_class"];
        }

    }
    
    
    if (![user[@"email"] isKindOfClass:[NSNull class]]) {
        self.lbEmail.text = user[@"email"];
    }
    
    if (![user[@"about_me"] isKindOfClass:[NSNull class]]) {
        self.tvAboutMe.text = user[@"about_me"];
    } else
    {
        self.tvAboutMe.text = @"";
    }
    
    if (![user[@"city_name"] isKindOfClass:[NSNull class]]) {
        self.lbHomeTown.text = user[@"city_name"];
    } else {
        self.lbHomeTown.text = @"";
    }
    
    if (![user[@"phone"] isKindOfClass:[NSNull class]]) {
        self.lbPhone.text = user[@"phone"];
    } else {
        self.lbPhone.text = @"No information";
    }
    
    if (![user[@"show_email"] isKindOfClass:[NSNull class]]) {
        
        if ([user[@"show_email"] isEqualToString:@"1"]) {
            showEmailToNonMember = 1;
            [self.showEmailSwitch setOn:YES animated:YES];
        } else {
            showEmailToNonMember = 0;
            [self.showEmailSwitch setOn:NO animated:YES];
        }
    }
    
    if (![user[@"id"] isKindOfClass:[NSNull class]]) {
        userId = user[@"id"];
    }
    
    // check role and status approved
    if ([user[@"org_id"] intValue] == 0) {
        //self.btn
        self.btnLeaveClub.hidden = YES;
        self.btnReqAdmin.hidden = YES;
        self.btnReqMember.hidden = YES;
    } else if ([user[@"approved"] intValue] == 1)
    {
        // pleage role
        //self.btnLeaveClub.hidden = YES;
        self.btnReqAdmin.hidden = YES;
        //self.btnReqMember.hidden = YES;
        
    } else if ([user[@"approved"] intValue] == 2)
    {
        // member role.
        self.btnEditClass.hidden = YES;
        //self.btnReqAdmin.hidden = YES;
        self.btnReqMember.hidden = YES;
        
    } else if ([user[@"approved"] intValue] == 3)
    {
        // admin role
        self.btnReqAdmin.hidden = YES;
        self.btnReqMember.hidden = YES;
    }
    
    if ([user[@"approved"] isEqualToString:@"2"]) {
        
    }

    NSString* birthday = user[@"birthday"];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* date = [formatter dateFromString:birthday];
    [formatter setDateFormat:@"dd MMM yyyy"];
    self.lbBirthday.text = [formatter stringFromDate:date];
    self.avatarView.layer.cornerRadius = self.avatarView.frame.size.width/2;
    self.avatarView.layer.masksToBounds = YES;
    
    [self getCityList];
    [self getSchoolList];
    
    self.pledgeTableView.delegate = self;
    self.pledgeTableView.dataSource = self;
    
    self.vPledge.hidden = YES;
    
    
    calendar = [[CKCalendarView alloc] init];
    CGRect r = calendar.frame;
    r.origin.y = 51;
    calendar.frame = r;
    [self.view addSubview:calendar];
    calendar.delegate = self;
    calendar.hidden = YES;
    


    self.buttonArr = [[NSMutableArray alloc]init];
    [self.buttonArr addObject:self.btnEditPosition];
    [self.buttonArr addObject:self.btnEmailEdit];
     [self.buttonArr addObject:self.btnHomeTown];
     [self.buttonArr addObject:self.btnPhoneEdit];
     [self.buttonArr addObject:self.btnMajorEdit];
   
    self.textfieldArr = [[NSMutableArray alloc] init];
    [self.textfieldArr addObject:self.tfHomeTown];
    [self.textfieldArr addObject:self.roleTextField];
    [self.textfieldArr addObject:self.majorTextField];
    [self.textfieldArr addObject:self.phoneTextField];
    [self.textfieldArr addObject:self.emailTextField];
    
    self.labelArr = [[NSMutableArray alloc] init];
      [self.labelArr addObject:self.lbHomeTown];
     [self.labelArr addObject:self.lbPosition];
    [self.labelArr addObject:self.lbMajor];
     [self.labelArr addObject:self.lbPhone];
    [self.labelArr addObject:self.lbEmail];
    
    for (UITextField * tf in self.textfieldArr) {
        tf.hidden = YES;
        // set text field
        tf.background = [UIImage imageNamed:@"textfieldbg"];
        tf.delegate = self;
    }
    
    self.majorTextField.text = self.lbMajor.text;
    self.phoneTextField.text = self.lbPhone.text;
    self.emailTextField.text = self.lbEmail.text;
    self.roleTextField.text = self.lbPosition.text;
    self.tfHomeTown.text = self.lbHomeTown.text;
    
    isEditing = NO;
}

- (void) updateAboutMe:(NSNotification *) notification
{
    self.tvAboutMe.text = notification.userInfo[@"about_me"];
    [self saveData];
}




- (IBAction)closePledgeTable:(id)sender {
    self.vPledge.hidden = YES;
    [self saveData];
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


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    AboutMeViewController * dest = segue.destinationViewController;
    dest.aboutString = self.tvAboutMe.text;
    
}


// table view for pledge

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return pledgeClasses.count;
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pledgeCell"];
    cell.textLabel.text = pledgeClasses[indexPath.row];
    cell.detailTextLabel.text = pledgeDetailClasses[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.pledgeTableView) {
        
        if ([self.lbClass.text isEqualToString:@""]) {
            self.lbClass.text = pledgeClassDic[pledgeClasses[indexPath.row]];
        } else
        {
        self.lbClass.text = [NSString stringWithFormat:@"%@ %@", self.lbClass.text, pledgeDetailClasses[indexPath.row]];
        }
        return;
    }
    
}

// end of table view

// save data to server.
- (void) saveData
{
    NSData *imagePhotoToUpload = UIImageJPEGRepresentation(pickImagePhoto, 1.0);
    NSData *imageBannerToUpload = UIImageJPEGRepresentation(pickImageBanner, 1.0);
    
    NSString* role = [self.lbPosition.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString* letters = [self.lbClass.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
   
    NSString* email = [self.lbEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([email length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    // hometown
    NSString* homeTown = [self.lbHomeTown.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString* birthday = self.lbBirthday.text;

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM yyyy"];
    
    NSDate* date = [formatter dateFromString:birthday];
    
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *sqlDate = [formatter stringFromDate:date];
    
    if ([sqlDate isKindOfClass:[NSNull class]] || sqlDate == nil) {
        sqlDate = @"";
    }
    
    NSDictionary *parameters =@{@"user_id" : userId,
                                @"role": role,
                                @"class":letters,
                                @"major": self.lbMajor.text,
                                @"birthday": sqlDate,
                                @"phone" : self.lbPhone.text,
                                @"email" : email,
                                @"show_email" : [NSString stringWithFormat:@"%d", showEmailToNonMember],
                                @"home_town" : homeTown,
                                @"about_me" : self.tvAboutMe.text
                                };
    NSLog(@"parameters:%@",parameters);
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:[kBASE_NEW_API stringByAppendingString:kEDIT_PROFILE]]];
    
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        if (imagePhotoToUpload)
        {
            [formData appendPartWithFileData: imagePhotoToUpload name:@"photo[]" fileName:@"editphoto.jpg" mimeType:@"image/jpeg"];
        }
        if (imageBannerToUpload) {
            [formData appendPartWithFileData: imageBannerToUpload name:@"banner[]" fileName:@"editbanner.jpg" mimeType:@"image/jpeg"];
        }
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
         NSLog(@"response: %@",jsons);
         NSDictionary* user = [[AppDelegate sharedDelegate] user];
         [user setValue:sqlDate forKey:@"birthday"];
         [user setValue:email forKey:@"email"];
         [user setValue:self.lbPhone.text forKey:@"phone"];
         [user setValue:self.lbMajor.text forKey:@"major"];
         [user setValue:self.lbClass.text forKey:@"pledge_class"];
          [user setValue:self.lbPosition.text forKey:@"position"];
         [user setValue:self.lbHomeTown.text forKey:@"city_name"];
         [user setValue:self.tvAboutMe.text forKey:@"about_me"];
         
         [user setValue:role forKey:@"role"];
         [user setValue:[NSString stringWithFormat:@"%d", showEmailToNonMember] forKey:@"show_email"];
         if (imageBannerToUpload) {
             [user setValue:jsons[@"banner"] forKey:@"banner"];
         }
         if (imagePhotoToUpload) {
             [user setValue:jsons[@"photo"] forKey:@"photo"];
         }
         
     }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
         
     }];
    
    [operation start];
}





- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) getSchoolList
{
    NSString* url = [kBASE_URL stringByAppendingString:kSCHOOL_LIST];
    NSLog(@"ur:%@",url);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"json:%@",JSON);
        schoollist = [NSArray arrayWithArray:JSON];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"error:%@",[error description]);
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }];
    [operation start];
}

- (void) getCityList
{
    NSString* url = [kBASE_URL stringByAppendingString:kCITY_LIST];
    NSLog(@"ur:%@",url);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"json:%@",JSON);
        citylist = [NSArray arrayWithArray:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"error:%@",[error description]);
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }];
    [operation start];
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
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM yyyy"];
    
    self.lbBirthday.text = [formatter stringFromDate:date];
    [self saveData];
}
- (BOOL)calendar:(CKCalendarView *)calendar willChangeToMonth:(NSDate *)date {
    // Of course we want to let users change months...
    return YES;
}

- (void)calendar:(CKCalendarView *)calendar didChangeToMonth:(NSDate *)date {
    //NSLog(@"Hurray, the user changed months!");
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)yesDialogClick:(id)sender {
    
    if ([currentRequest isEqualToString:@"RequestLeave"]) {
        
        NSDictionary* user = [[AppDelegate sharedDelegate] user];
        
        NSDictionary *parameters =@{@"user_id" : user[@"id"],
                                    @"org_id": user[@"org_id"]
                                    };
        NSLog(@"parameters:%@",parameters);
        AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:[kBASE_NEW_API stringByAppendingString:kLEAVE_CLUB]]];
        
        NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
            
        }];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSDictionary *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
             NSLog(@"response 1: %@",jsons);
             if (jsons[@"error_message"]) {
                 NSLog(@"error_message : %@",jsons[@"error_message"]);
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:jsons[@"error_message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                 [alert show];
             } else
             {
                 UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Leave Organization Success!" message:@"You've just leave the Club." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                 alert.delegate = self;
                 [alert show];
                 
                 [user setValue:@"0" forKey:@"org_id"];
                 [user setValue:@"No Club" forKeyPath:@"organization_name"];
                 
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if([operation.response statusCode] == 403)
             {
                 //NSLog(@"Upload Failed");
                 return;
             }
             //NSLog(@"error: %@", [operation error]);
         }];
        
        [operation start];
    } else if ([currentRequest isEqualToString:@"RequestAdmin"]) {
        NSDictionary* user = [[AppDelegate sharedDelegate] user];
        
        
        NSDictionary *parameters =@{@"user_id" : user[@"id"],
                                    @"org_id": user[@"org_id"],
                                    @"request_type" : @"2"
                                    };
        NSURL * url = [NSURL URLWithString:[kBASE_NEW_API stringByAppendingString:kREQUEST_SEND]];

        AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:url];
        
        NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
            
        }];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Request Success!" message:@"You have been send a request to admin team." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [alert show];
             
         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if([operation.response statusCode] == 403)
             {
                 NSLog(@"Upload Failed");
                 return;
             }
             NSLog(@"error: %@", [operation error]);
             
         }];
        
        [operation start];
    } else {
        NSDictionary* user = [[AppDelegate sharedDelegate] user];
        
        NSDictionary *parameters =@{@"user_id" : user[@"id"],
                                    @"org_id": user[@"org_id"],
                                    @"request_type" : @"1"
                                    };
        NSURL * url = [NSURL URLWithString:[kBASE_NEW_API stringByAppendingString:kREQUEST_SEND]];
        AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:url];
        
        NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
            
        }];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Request Success!" message:@"You have been send a request to admin team." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [alert show];
             
         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if([operation.response statusCode] == 403)
             {
                 NSLog(@"Upload Failed");
                 return;
             }
             NSLog(@"error: %@", [operation error]);
             
         }];
        
        [operation start];
    }
    self.vPopup.hidden = YES;
}

- (IBAction)dialogNoAction:(id)sender {
    self.vPopup.hidden = YES;
    currentRequest = @"";
}

- (IBAction)dialogCloseAction:(id)sender {
    self.vPopup.hidden = YES;
    currentRequest = @"";
}

- (IBAction)requestMembership:(id)sender {
    self.vPopup.hidden = NO;
    self.messagePopup.text = @"Request to be Member?";
    currentRequest = @"RequestMember";
    
}

- (IBAction)requestAdminAction:(id)sender {
    
    self.vPopup.hidden = NO;
    self.messagePopup.text = @"Request to be Admin?";
    currentRequest = @"RequestAdmin";
}

- (IBAction)leaveClubAction:(id)sender {
    
    self.vPopup.hidden = NO;
    self.messagePopup.text = @"Sure to leave?";
    currentRequest = @"RequestLeave";
    
    
}

- (IBAction)logoutAction:(UIButton *)sender {
    [[AppDelegate sharedDelegate] setUser:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
