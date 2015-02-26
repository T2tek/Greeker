//
//  TaskInfoViewController.h
//  Greeker
//
//  Created by Thohd on 6/18/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskInfoViewController : UIViewController
@property (nonatomic, strong) NSDictionary * taskData;
@property (nonatomic, strong) NSString * taskId;
@property (weak, nonatomic) IBOutlet UILabel *createBy;

@end
