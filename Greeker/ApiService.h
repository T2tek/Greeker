//
//  ApiService.h
//  Greeker
//
//  Created by Hoang Nguyen on 9/1/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiServiceDelegate.h"
@interface ApiService : NSObject
- (void) getMemberListOfClub: (NSString *) orgId;
@property (weak, nonatomic) id<ApiServiceDelegate> delegate;
@end
