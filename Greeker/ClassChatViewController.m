//
//  ClassChatViewController.m
//  Greeker
//
//  Created by Thohd on 6/18/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "ClassChatViewController.h"
#import "AppDelegate.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import "Utility.h"
#import "YCameraViewController.h"
@interface ClassChatViewController () <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,YCameraViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *vSend;
@property (strong, nonatomic) IBOutlet UITextField *textMessage;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendBottomConstraint;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tableDataSortDesc;
@property (weak, nonatomic) IBOutlet UIView *viewChat;
@property (weak, nonatomic) IBOutlet UILabel *lbNavigationTitle;

@property (weak, nonatomic) IBOutlet UIView *imageDetailView;

@property (weak, nonatomic) IBOutlet UIImageView *imageDetailFull;


- (IBAction)chosePhoto:(id)sender;
- (IBAction)backAction:(UIButton *)sender;
- (IBAction)sendAction:(UIButton *)sender;
@end

@implementation ClassChatViewController
{
    NSDictionary* user;
    NSTimer *timerRefreshTable;
    UIImage *pickedImage;
    NSString *lastUpdateTime;
    BOOL isEditLetter;
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
    if ([self.messageType isEqualToString:@"0"]) {
        self.lbNavigationTitle.text = @"Pledge Class Chat";
    } else
    {
        self.lbNavigationTitle.text = @"Message Board";
    }
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    user = [[AppDelegate sharedDelegate] user];
    if ([self.messageType isEqualToString:@"1"] && ![user[@"approved"] isEqualToString:@"3"]) {
        self.viewChat.hidden = YES;
    }
    [self getListChatUserOrganization];
    
    timerRefreshTable = [NSTimer scheduledTimerWithTimeInterval:2
                                                         target:self selector:@selector(getListChatUserOrganization)
                                                       userInfo:nil repeats:YES];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissImage)];
    [self.imageDetailView addGestureRecognizer:recognizer];
    isEditLetter = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
//    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChange:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    
    // Do any additional setup after loading the view.
}

-(void) keyboardWillChange: (NSNotification *) notification
{
//    let userInfo : Dictionary<NSObject, AnyObject> = notification.userInfo as Dictionary<NSObject, AnyObject>!
//    let keyBoardFrame: NSValue = userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue
//    let keyboardCGRect = keyBoardFrame.CGRectValue()
//    self.bottomButtonConstraints.constant = keyboardCGRect.size.height
    
    NSDictionary * userInfo = notification.userInfo;
    NSValue * keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [keyboardFrame CGRectValue];
    
    [UIView animateWithDuration:.3 animations:^{
        CGRect r = self.view.frame;
        r.origin.y = 0 - keyboardRect.size.height;
        self.view.frame = r;
        
    }];
    
}

-(void) dismissImage
{
    self.imageDetailView.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray *)tableDataSortDesc
{
    if (!_tableDataSortDesc) {
        self.tableDataSortDesc = [[NSMutableArray alloc] init];
    }
    return _tableDataSortDesc;
}


-(void)getListChatUserOrganization
{
    if ([user[@"org_id"] intValue] > 0) {
        
        NSString* url = [kBASE_NEW_API stringByAppendingFormat:kMESSAGE_LIST_CLUB];
        
        if (lastUpdateTime == NULL || [lastUpdateTime isEqual:@""]) {
            lastUpdateTime = @"";
        }
        
        NSString *plegeClass = @"";
        
        if( [self.messageType isEqualToString:@"0"])
        {
            plegeClass = user[@"pledge_class"];
        }
        
        NSDictionary *parameters  =  @{@"last_update_time":lastUpdateTime,
                          @"org_id" : user[@"org_id"],
                          @"user_id" : user[@"id"],
                          @"message_type":self.messageType,
                          @"pledge_class" : plegeClass
                          };
        AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:url]];
        NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                
        }];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSDictionary *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
             
             NSArray *data = [jsons objectForKey:@"message_list"];

             if (data.count > 0) {
                 if ([lastUpdateTime isEqual:@""]) {
                     [self.tableDataSortDesc removeAllObjects];
                     for (int i = (int)data.count - 1; i > -1  ; i--) {
                         [self.tableDataSortDesc addObject:data[i]];
                     }
                     [self.tableView reloadData];
                     [self tableViewGotoBottom];
                 } else {
                     if (data.count > 0) {
                         NSLog(@"Uploaddata Data Now");
                         for (int i = (int)data.count - 1; i > -1  ; i--) {
                             [self.tableDataSortDesc addObject:data[i]];
                             [self updateTableView];
                         }
                     }
                 }
             } else {
                // NSLog(@"there is no chat data...");
             }
             
             lastUpdateTime = [jsons objectForKey:@"last_update_time"];
         }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
         }];
        [operation start];
    }
}

-(void) updateTableView
{
    NSArray *insertIndexPaths = [NSArray arrayWithObjects:
                                 [NSIndexPath indexPathForRow:self.tableDataSortDesc.count-1 inSection:0],
                                 nil];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    [self tableViewGotoBottom];
}

-(void)tableViewGotoBottom
{
    int lastRowNumber = (int)[self.tableView numberOfRowsInSection:0] - 1;
    if (lastRowNumber < 0) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableDataSortDesc.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    UIImageView *photoUser;
    UIImageView *image;
    NSDictionary *data = self.tableDataSortDesc[indexPath.row];
    NSString *userId;
    NSString *userName;
    NSString *imageURL;
    NSString *userPhotoURL;
    NSString *messageText;
    NSString *createTime;
    
    if (![data[@"user_id"] isKindOfClass:[NSNull class]]) {
        userId = data[@"user_id"];
     }
    
    if (![data[@"last_name"] isKindOfClass:[NSNull class]]) {
        userName   = data[@"last_name"];
    } else {
        userName = @"";
    }
    
    if ([userName isEqualToString:@""] && (![data[@"first_name"] isKindOfClass:[NSNull class]])) {
        userName   = data[@"first_name"];
    }
    
    
    
    if (![data[@"image"] isKindOfClass:[NSNull class]]) {
        imageURL = data[@"image"];
    } else {
        imageURL = @"";
    }
    
    if (![data[@"user_photo"] isKindOfClass:[NSNull class]]) {
        userPhotoURL = data[@"user_photo"];
    } else {
        userPhotoURL = @"";
    }
    
    if (![data[@"message"] isKindOfClass:[NSNull class]]) {
        messageText = data[@"message"];
    }
    
    if (![data[@"create_time"] isKindOfClass:[NSNull class]]) {
        createTime = [Utility convertDate:data[@"create_time"] formatFrom:kSERVER_DATE_FORMAT toFormat:kUS_DATETIME_FORMAT];
    }
    
    if (![imageURL isEqualToString:@""])
    {
        if ([userId isEqualToString:user[@"id"]]) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"Left Image Cell"];
   
            image = (UIImageView *)[cell viewWithTag:8];
            photoUser = (UIImageView *)[cell viewWithTag:7];
        } else
        {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"Right Image Cell"];
            image = (UIImageView *)[cell viewWithTag:6];
            photoUser = (UIImageView *)[cell viewWithTag:5];
        }

        image.image = [UIImage imageNamed:@"placeholdercover.png"];
        
        NSURL *url = [NSURL URLWithString:[kBASE_UPLOAD_URL stringByAppendingString:imageURL]] ;
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            UIImage *cacheImage = [UIImage imageWithData:responseObject];
            float oldWidth = cacheImage.size.width;
            float scaleFactor = 150 / oldWidth;
            float newWidth = oldWidth * scaleFactor;
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, 100), NO, 0.0);
            [cacheImage drawInRect:CGRectMake(0, 0, newWidth, 100)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            image.image = newImage;
            [image setFrame:CGRectMake(image.frame.origin.x, image.frame.origin.y, newWidth, 100)];
            image.contentMode = UIViewContentModeScaleAspectFit;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Image error: %@", error);
        }];
        [requestOperation start];
    } else {
    
        if ([userId isEqualToString:user[@"id"]]) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"Left Text Cell"];
            photoUser = (UIImageView *)[cell viewWithTag:10];
        } else {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"Right Text Cell"];
            photoUser = (UIImageView *)[cell viewWithTag:4];
        }

        UILabel *userMessage = (UILabel *)[cell viewWithTag:1];
        userMessage.text = messageText;


    }
    
    if (userPhotoURL.length > 0) {
        
        BOOL result = [[userPhotoURL lowercaseString] hasPrefix:@"http"];
        if (result) {
            [photoUser setImageWithURL:[NSURL URLWithString:userPhotoURL] placeholderImage:[UIImage imageNamed:@"placeholderavatar"]];
        } else
        {
            [photoUser setImageWithURL:[NSURL URLWithString:[kBASE_UPLOAD_URL stringByAppendingString:userPhotoURL]] placeholderImage:[UIImage imageNamed:@"placeholderavatar"]];
        }
        photoUser.layer.cornerRadius = photoUser.frame.size.width/2;
        photoUser.layer.masksToBounds = YES;
    }
    
    UILabel *lbUserName = (UILabel *)[cell viewWithTag:2];
    UILabel *lbUserTime = (UILabel *)[cell viewWithTag:3];
    
    lbUserName.text = userName;
    lbUserTime.text = createTime;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *data = self.tableDataSortDesc[indexPath.row];
    id cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    if (![data[@"image"] isKindOfClass:[NSNull class]] && data[@"image"] && ![data[@"image"] isEqualToString:@""])
    {
        return 150;
    }
    UILabel *userMessage = (UILabel *)[cell viewWithTag:1];
    CGSize labelSize = [userMessage.text sizeWithFont:userMessage.font
                                constrainedToSize:userMessage.frame.size
                                    lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat labelHeight = labelSize.height;
    return labelHeight + 65;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.textMessage resignFirstResponder];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.textMessage resignFirstResponder];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    // UITAbleViewCell *cell =
    
    NSDictionary *data = self.tableDataSortDesc[indexPath.row];
   // id cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    if (![data[@"image"] isKindOfClass:[NSNull class]] && data[@"image"] && ![data[@"image"] isEqualToString:@""])
    {
        self.imageDetailView.hidden = NO;
        [self.imageDetailFull setImageWithURL:[NSURL URLWithString:[kBASE_UPLOAD_URL stringByAppendingString:data[@"image"]]]];
    }
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *data = self.tableDataSortDesc[indexPath.row];
    NSString *sender = data[@"user_id"];
    
    if ([ sender isEqualToString:user[@"id"]]) {
        return YES;
    }
    return NO;
}


-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *data = self.tableDataSortDesc[indexPath.row];

    
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
            NSLog(@"Delete cell At %ld and id : %@", (long)indexPath.row, data);
            [self.tableDataSortDesc removeObjectAtIndex:indexPath.row];
            [self.tableView reloadData];
            [self deleteMessage:data[@"id"]];
            break;
        default:
            break;
    }
}

-(void)saveMessage
{
    NSString *userId = user[@"id"];
    NSString *orgId = user[@"org_id"];
    NSString *message = [self.textMessage.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSData *imageToUpload;
    if (![pickedImage isKindOfClass:[NSNull class]]) {
        imageToUpload = UIImageJPEGRepresentation(pickedImage, 1.0);
    }
    
    NSString * pledgeClass = @"";
    if ([self.messageType isEqualToString:@"0"]) {
        pledgeClass = user[@"pledge_class"];
    }
    
    NSDictionary *parameters = @{@"user_id" : userId,
                                @"org_id" : orgId,
                                @"message_type": self.messageType,
                                @"message_text": message,
                                 @"pledge_class" : pledgeClass
                                };
    
   
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:[kBASE_NEW_API stringByAppendingString:kSAVE_MESSAGE_API]]];
    
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        if (imageToUpload)
        {
            [formData appendPartWithFileData: imageToUpload name:@"image[]" fileName:@"chatImg.jpg" mimeType:@"image/jpeg"];
        }
    }];
    pickedImage = nil;
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [MBProgressHUD hideAllHUDsForView:self.view animated:true];
         NSDictionary *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
         [self.tableDataSortDesc addObject:(NSArray *)jsons];
         [self updateTableView];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
          [MBProgressHUD hideAllHUDsForView:self.view animated:true];
         if([operation.response statusCode] == 403)
         {
             NSLog(@"Upload Fail");
             return;
         }
         NSLog(@"error: %@", [operation error]);
     }];
    [operation start];
}


-(void)deleteMessage: (NSString*) messageId
{


    
    NSDictionary *parameters = @{
                                 @"message_id" : messageId
                                };
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:[kBASE_NEW_API stringByAppendingString:kDELETE_MESSAGE_API]]];
    
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
      //
    }];

    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"REsponse %@", responseObject);
         [MBProgressHUD hideAllHUDsForView:self.view animated:true];
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"dlete error");
         [MBProgressHUD hideAllHUDsForView:self.view animated:true];
     }];
    [operation start];
}


- (IBAction)chosePhoto:(id)sender {
    YCameraViewController *camController = [[YCameraViewController alloc] initWithNibName:@"YCameraViewController" bundle:nil];
    camController.delegate=self;
    
    [self presentViewController:camController animated:YES completion:^{
        // completion code
    }];
}


- (IBAction)backAction:(UIButton *)sender {
    [timerRefreshTable invalidate];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendAction:(UIButton *)sender {
    if ([self.textMessage.text length] == 0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter message" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    [self saveMessage];
    [self.textMessage resignFirstResponder];
    self.textMessage.text = @"";
}

-(void)didFinishPickingImage:(UIImage *)image{
    // Use image as per your need
    pickedImage = image;
    [self saveMessage];
}
-(void)yCameraControllerdidSkipped{
    // Called when user clicks on Skip button on YCameraViewController view
}

-(void)yCameraControllerDidCancel{
    // Called when user clicks on "X" button to close YCameraViewController
}


- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [UIView animateWithDuration:.3 animations:^{
        CGRect r = self.view.frame;
        r.origin.y = 0;
        self.view.frame = r;
        
    }];
}
/*

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
 */
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [self.textMessage resignFirstResponder];
    return YES;
}

@end
