//
//  MemberListViewController.h
//  Greeker
//
//  Created by Thohd on 4/15/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberListViewController : UIViewController

@property (nonatomic, strong) NSString * clubId;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
