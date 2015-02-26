//
//  ClubSettingsViewController.m
//  Greeker
//
//  Created by Thohd on 7/16/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "ClubSettingsViewController.h"
#import "MyTextField.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "YCameraViewController.h"
@interface ClubSettingsViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, YCameraViewControllerDelegate>
{
    BOOL isEditing;
    NSArray *letters;
    NSArray *letterDetails;
    UIImage *pickImagePhoto;
    BOOL isEditLetters;
    UITapGestureRecognizer *tap;
}
- (IBAction)backAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *clubImage;
@property (weak, nonatomic) IBOutlet UILabel *lbClubName;	
@property (weak, nonatomic) IBOutlet MyTextField *tfClubName;
@property (weak, nonatomic) IBOutlet UILabel *lbLetters;
@property (weak, nonatomic) IBOutlet UILabel *lbChapter;
@property (weak, nonatomic) IBOutlet MyTextField *tfChapter;
@property (weak, nonatomic) IBOutlet UIButton *btnNameEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnLettersEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnChapterEdit;

@property (weak, nonatomic) IBOutlet UIView *vLetters;
@property (weak, nonatomic) IBOutlet UITableView *letterTableView;
@property (weak, nonatomic) IBOutlet UITextView *txtIntroduction;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ClubSettingsViewController

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
    
    tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    isEditing = NO;
    isEditLetters = NO;
    self.scrollView.contentSize = CGSizeMake(320, 700);
    NSArray *oldPledgeClasses = @[@"α",@"β",@"γ",@"δ",@"ε",@"ζ",@"η",@"θ",@"ι",@"κ",@"λ",@"μ",@"ν",@"ξ",@"ο",@"π",@"ρ",@"σ",@"τ",@"υ",@"φ",@"χ",@"ψ",@"ω"];
    letters = [self uppercaseArray:oldPledgeClasses];
    letterDetails = @[@"Alpha",@"Beta",@"Gamma",@"Delta",@"Epsilon",@"Zeta",@"Eta",@"Theta",@"Iota",@"Kappa",@"Lambda",@"Mu",@"Nu",@"Ksi",@"Omicron",@"Pi",@"Rho",@"Sigma",@"Tau",@"Upsilon",@"Phi",@"Chi",@"Psi",@"Omega"];
    
    self.letterTableView.delegate = self;
    self.letterTableView.dataSource = self;
    self.tfClubName.delegate = self;
    self.tfChapter.delegate = self;
    self.txtIntroduction.delegate = self;
    
    
    
    NSDictionary* user = [[AppDelegate sharedDelegate] user];
    
    if ([user[@"org_id"] intValue]>0) {
        NSString* url = [kBASE_NEW_API stringByAppendingFormat:kCLUB_INFO, [user[@"org_id"] intValue]];
        NSLog(@"Club setting url:%@",url);
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"Club settings json:%@",JSON);
            NSArray * result = JSON;
            NSDictionary *orgData = result[0];
            if (![orgData[@"chapter"] isKindOfClass:[NSNull class]]) {
                self.lbChapter.text = orgData[@"chapter"];
            }
            
            if (orgData[@"name"] != nil) {
                self.lbClubName.text = orgData[@"name"];
            } else {
                self.lbClubName.text = @"";
            }
            
            if (orgData[@"letters"] != nil) {
                self.lbLetters.text = orgData[@"letters"];
            } else {
                self.lbLetters.text = @"";
            }
            
            if(![orgData[@"introduction"] isKindOfClass:[NSNull class]]) {
                self.txtIntroduction.text = orgData[@"introduction"];
                
            } else {
                self.txtIntroduction.text = @"";
            }
            
            if (![orgData[@"logo"] isKindOfClass:[NSNull class]]) {
                BOOL result = [[orgData[@"logo"] lowercaseString] hasPrefix:@"http"];
                if (result) {
                    [self.clubImage setImageWithURL:[NSURL URLWithString:orgData[@"logo"]] placeholderImage:[UIImage imageNamed:@"placeholderavatar"]];
                } else
                {
                    [self.clubImage setImageWithURL:[NSURL URLWithString:[kBASE_UPLOAD_URL stringByAppendingPathComponent: orgData[@"logo"]]] placeholderImage:[UIImage imageNamed:@"placeholderavatar"]];
                }
                self.clubImage.layer.cornerRadius = self.clubImage.frame.size.width/2;
                self.clubImage.layer.masksToBounds = YES;
            }
            //tableData = [NSArray arrayWithArray:JSON];
            //[self.tableView reloadData];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"error:%@",[error description]);
            [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }];
        [operation start];
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"Club Setting ViewDidApprear");
}

- (IBAction)editPhoto:(id)sender {
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
  
    self.clubImage.image = image;
    pickImagePhoto = image;
    
    [self saveData];
}

-(void)yCameraControllerdidSkipped{
    // Called when user clicks on Skip button on YCameraViewController view
}

-(void)yCameraControllerDidCancel{
    // Called when user clicks on "X" button to close YCameraViewController
}



-(NSArray *) uppercaseArray:(NSArray *)oldArray
{
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    for (NSString *lowercaseString in oldArray) {
        [newArray addObject:[lowercaseString uppercaseString]];
    }
    return newArray;
}


// table view for pledge

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return letters.count;
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"letterCell"];
    cell.textLabel.text = letters[indexPath.row];
    cell.detailTextLabel.text = letterDetails[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.letterTableView) {
        
        if ([self.lbLetters.text isEqualToString:@""]) {
            self.lbLetters.text = letterDetails[indexPath.row];
        } else {
        self.lbLetters.text = [NSString stringWithFormat:@"%@ %@", self.lbLetters.text,letterDetails[indexPath.row]];
        }
        NSLog(@"select letter...");
        //[self saveData];
        return;
    }
    
}

- (IBAction)closeTouch:(id)sender {
    self.vLetters.hidden = YES;
    isEditLetters = NO;
    [self saveData];
}


// end of table view

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) saveData
{

    NSData *clubPhotoToUpload = UIImageJPEGRepresentation(pickImagePhoto, 1.0);
    
    NSString* clubName = [self.lbClubName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([clubName length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter a valid name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    NSString* textletters = [self.lbLetters.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([textletters length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter a valid letters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    
    NSString* chapter = [self.lbChapter.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([chapter length]==0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter chapter" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    NSDictionary *user = [AppDelegate sharedDelegate].user;
  
    NSDictionary *parameters =@{@"org_id" : user[@"org_id"],
                                @"name": clubName,
                                @"letters":textletters,
                                @"chapter": chapter,
                                @"introduction" : self.txtIntroduction.text
                                };
    
   // NSLog(@"parameters:%@", parameters);
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:[kBASE_NEW_API stringByAppendingString:kUPDATE_CLUB]]];
    
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        if (clubPhotoToUpload)
        {
            [formData appendPartWithFileData: clubPhotoToUpload name:@"photo[]" fileName:@"clubPhoto.jpg" mimeType:@"image/jpeg"];
        }
        
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
         NSLog(@"response: %@",jsons);
         NSDictionary* user = [[AppDelegate sharedDelegate] user];
         [user setValue:clubName forKey:@"organization_name"];
         
     }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
        [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
         
     }];
    
    [operation start];
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

-(void) textViewDidBeginEditing:(UITextView *)textView
{
    
    [self.view addGestureRecognizer:tap];
    [UIView animateWithDuration:.3 animations:^{
        CGRect r = self.view.frame;
        r.origin.y -= 80;
        self.view.frame = r;
        
    }];
   
}

-(void) textViewDidEndEditing:(UITextView *)textView
{
    [self.view removeGestureRecognizer:tap];
    [UIView animateWithDuration:.3 animations:^{
        CGRect r = self.view.frame;
        r.origin.y = 0;
        self.view.frame = r;
        
    }];
}

- (IBAction)btnChapterEditTouch:(id)sender {
    if (isEditing) {
        self.lbChapter.text = self.tfChapter.text;
        self.tfChapter.hidden = YES;
        self.lbChapter.hidden = NO;
        [self.btnChapterEdit setTitle:@"Edit" forState:UIControlStateNormal];
        isEditing = NO;
        [self saveData];
        return;
    }
    
    self.tfChapter.hidden = NO;
    self.lbChapter.hidden = YES;
    self.tfChapter.text = self.lbChapter.text;
    [self.btnChapterEdit setTitle:@"Done" forState:UIControlStateNormal];
    
    isEditing = YES;
}

- (IBAction)btnNameEditTouch:(id)sender {
    
    if (isEditing) {
        self.lbClubName.text = self.tfClubName.text;
        self.tfClubName.hidden = YES;
        self.lbClubName.hidden = NO;
        [self.btnNameEdit setTitle:@"Edit" forState:UIControlStateNormal];
        isEditing = NO;
        [self saveData];
        return;
    }
    
    self.tfClubName.hidden = NO;
    self.lbClubName.hidden = YES;
    self.tfClubName.text = self.lbClubName.text;
    [self.btnNameEdit setTitle:@"Done" forState:UIControlStateNormal];
    
    isEditing = YES;
    
}

- (IBAction)btnLetterEditTouch:(id)sender {
    self.vLetters.hidden = NO;
    self.lbLetters.text = @"";
    isEditLetters = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField == self.tfChapter) {
        self.lbChapter.text = self.tfChapter.text;
        self.tfChapter.hidden = YES;
        self.lbChapter.hidden = NO;
        [self.btnChapterEdit setTitle:@"Edit" forState:UIControlStateNormal];
    } else if (textField == self.tfClubName) {
        self.lbClubName.text = self.tfClubName.text;
        self.tfClubName.hidden = YES;
        self.lbClubName.hidden = NO;
        [self.btnNameEdit setTitle:@"Edit" forState:UIControlStateNormal];
    }
    
    [self saveData];
    isEditing = NO;
    return YES;
}

-(void)dismissKeyboard {
    if (!isEditLetters) {
        [self.txtIntroduction resignFirstResponder];
        [self saveData];
    }
   
}

- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
