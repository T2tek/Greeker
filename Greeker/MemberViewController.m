//
//  MemberViewController.m
//  Greeker
//
//  Created by Thohd on 6/26/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "MemberViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
#import <AddressBook/AddressBook.h>
#import "AppDelegate.h"
@interface MemberViewController ()

- (IBAction)backAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *labelRole;
@property (weak, nonatomic) IBOutlet UILabel *lbClass;
@property (weak, nonatomic) IBOutlet UILabel *lbBirthday;
@property (weak, nonatomic) IBOutlet UILabel *lbMajor;
@property (weak, nonatomic) IBOutlet UITextView *txtAbout;
@property (nonatomic, strong) NSDictionary *memberData;
@property (weak, nonatomic) IBOutlet UILabel *lbCity;
@property (weak, nonatomic) IBOutlet UITextView *lbEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnAddContact;
@property (weak, nonatomic) IBOutlet UILabel *lbTextEmail;
@property (weak, nonatomic) IBOutlet UIImageView *bannerView;

@end

@implementation MemberViewController
{
    NSDictionary* user;
}

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
    user = [[AppDelegate sharedDelegate] user];
    self.btnAddContact.hidden = NO;
    self.lbEmail.hidden = NO;
    self.lbTextEmail.hidden = NO;
    
    NSLog(@"User ORG : %@ , ORG : %@",user[@"org_id"] ,self.orgId );
    
    if (![user[@"org_id"] isEqualToString:self.orgId]) {
        // hide buton
        self.btnAddContact.hidden = YES;
    }
    
    // Do any additional setup after loading the view.
    [self getMemberProfile];
}

-(void) getMemberProfile
{
    NSDictionary *parameters =@{
                                @"user_id" : self.memberId
                                };
    NSString * url = [kBASE_NEW_API stringByAppendingString:kMEMBER_PROFILE];
    NSLog(@"URL: %@", url);
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:url]];
    
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSObject *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
         
         if ([jsons isKindOfClass:NSDictionary.class]) {
             NSLog(@"Khong co ket qua: %@", jsons);
         } else {
             
             NSLog(@"response: %@",jsons);
             NSArray * result = (NSArray *) jsons;
             self.memberData = (NSDictionary*)result[0];
             self.lbName.text = [NSString stringWithFormat:@"%@ %@", self.memberData[@"first_name"], self.memberData[@"last_name"]];
             
             if (![self.memberData[@"position"] isKindOfClass:[NSNull class]]) {
                 self.labelRole.text = [NSString stringWithFormat:@"%@", self.memberData[@"position"]];
             }
             if (![self.memberData[@"pledge_class"] isKindOfClass:[NSNull class]]) {
                 self.lbClass.text = [NSString stringWithFormat:@"%@", self.memberData[@"pledge_class"]];
             }
             if (![self.memberData[@"major"] isKindOfClass:[NSNull class]]) {
                 self.lbMajor.text = [NSString stringWithFormat:@"%@", self.memberData[@"major"]];
             }
             
             if (![self.memberData[@"email"] isKindOfClass:[NSNull class]]) {
                 self.lbEmail.text = [NSString stringWithFormat:@"%@",self.memberData[@"email"]];
                 self.lbEmail.dataDetectorTypes = UIDataDetectorTypeAll;
             }
             
             if (![self.memberData[@"city_name"] isKindOfClass:[NSNull class]]) {
                self.lbCity.text = [NSString stringWithFormat:@"%@", self.memberData[@"city_name"]];
             }
             if (![self.memberData[@"about_me"] isKindOfClass:[NSNull class]]) {
                 self.txtAbout.text = self.memberData[@"about_me"];
             } else
             {
                 self.txtAbout.text = @"";
             }
            
             NSString* birthday = self.memberData[@"birthday"];
             NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
             [formatter setDateFormat:@"yyyy-MM-dd"];
             NSDate* date = [formatter dateFromString:birthday];
             [formatter setDateFormat:@"dd MMM yyyy"];
             
             self.lbBirthday.text = [formatter stringFromDate:date];
             //photo
             if (![self.memberData[@"photo"] isKindOfClass:[NSNull class]]) {
                 BOOL result = [[self.memberData[@"photo"] lowercaseString] hasPrefix:@"http"];
                 if (result) {
                     [self.avatarImage setImageWithURL:[NSURL URLWithString:self.memberData[@"photo"]] placeholderImage:[UIImage imageNamed:@"placeholderavatar"]];
                 } else
                 {
                     [self.avatarImage setImageWithURL:[NSURL URLWithString:[kBASE_UPLOAD_URL stringByAppendingString:self.memberData[@"photo"]]] placeholderImage:[UIImage imageNamed:@"placeholderavatar"]];
                 }
             }
             self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.width/2;
             self.avatarImage.layer.masksToBounds = YES;
             //banner
             if (![self.memberData[@"banner"] isKindOfClass:[NSNull class]]) {
                 BOOL result = [[self.memberData[@"banner"] lowercaseString] hasPrefix:@"http"];
                 if (result) {
                     [self.bannerView setImageWithURL:[NSURL URLWithString:self.memberData[@"banner"]] placeholderImage:[UIImage imageNamed:@"placeholdercover"]];
                 } else
                 {
                     [self.bannerView setImageWithURL:[NSURL URLWithString:[kBASE_UPLOAD_URL stringByAppendingString:self.memberData[@"banner"]]] placeholderImage:[UIImage imageNamed:@"placeholdercover"]];
                 }
             }
             
             if ([self.memberData[@"show_email"] isEqualToString:@"0"] && ![user[@"org_id"] isEqualToString:self.orgId]) {
                 self.lbEmail.hidden = YES;
                 self.lbTextEmail.hidden = YES;
             }
             
         }
         
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [[[UIAlertView alloc] initWithTitle:@"Server problem" message:@"Please come back again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
         
     }];
    
    [operation start];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addContact:(id)sender {
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        //1
        NSLog(@"Denied");
        UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [cantAddContactAlert show];
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        //2
        NSLog(@"Authorized");
        [self addMemberToContact];
    } else { //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
        //3
        NSLog(@"Not determined");
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted){
                    //4
                    UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
                    [cantAddContactAlert show];
                    return;
                }
                //5
                [self addMemberToContact];
            });
        });
    }
}

-(void)addMemberToContact
{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, nil);
    ABRecordRef member = ABPersonCreate();
    if ([self.memberData[@"first_name"] isKindOfClass:[NSNull class]] || [self.memberData[@"last_name"] isKindOfClass:[NSNull class]] || [self.memberData[@"phone"] isKindOfClass:[NSNull class]] ) {
        UIAlertView *contactAddedErorAlert = [[UIAlertView alloc]initWithTitle:@"Information member is missing" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [contactAddedErorAlert show];
        return;
    }
    ABRecordSetValue(member, kABPersonFirstNameProperty, (__bridge CFStringRef)self.memberData[@"first_name"], nil);
    ABRecordSetValue(member, kABPersonLastNameProperty, (__bridge CFStringRef)self.memberData[@"last_name"], nil);
    ABMutableMultiValueRef phoneNumbers = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(phoneNumbers, (__bridge CFStringRef)self.memberData[@"phone"], kABPersonPhoneMainLabel, NULL);
    ABRecordSetValue(member, kABPersonPhoneProperty, phoneNumbers, nil);
    CFRelease(phoneNumbers);
    
    
    if (![self.memberData[@"email"] isKindOfClass:[NSNull class]]) {
        ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(multiEmail, (__bridge CFStringRef)self.memberData[@"email"], kABPersonPhoneMainLabel, NULL);
        ABRecordSetValue(member, kABPersonEmailProperty, multiEmail, nil);
        CFRelease(multiEmail);
    }
    
    if (![self.memberData[@"photo"] isKindOfClass:[NSNull class]]) {
        NSData *imageData = UIImageJPEGRepresentation(self.avatarImage.image, 0.7f);
        ABPersonSetImageData(member, (__bridge CFDataRef)imageData, nil);
        ABAddressBookAddRecord(addressBookRef, member, nil);
    }
    NSArray *allContacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    if (allContacts.count > 0) {
        for (id record in allContacts){
            ABRecordRef thisContact = (__bridge ABRecordRef)record;
            ABMultiValueRef phoneContacts = (ABMultiValueRef)ABRecordCopyValue(thisContact, kABPersonPhoneProperty);
            CFRelease(phoneContacts);
            NSString* phoneNumberCurrent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneContacts, 0);
            if ([phoneNumberCurrent isEqualToString:self.memberData[@"phone"]]) {
                UIAlertView *contactExistsAlert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@ %@ haved in contacts", self.memberData[@"first_name"], self.memberData[@"last_name"]] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [contactExistsAlert show];
                return;

            }
        }
    }
    if (ABAddressBookSave(addressBookRef, nil)) {
        UIAlertView *contactAddedAlert = [[UIAlertView alloc]initWithTitle:@"Contact Added" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [contactAddedAlert show];
    } else
    {
        UIAlertView *contactAddedErorAlert = [[UIAlertView alloc]initWithTitle:@"Error Saving member to Address Book" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [contactAddedErorAlert show];
    }
    CFRelease(addressBookRef);
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

- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
