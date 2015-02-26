//
//  ApiServiceDelegate.h
//  Greeker
//
//  Created by Hoang Nguyen on 9/1/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ApiServiceDelegate <NSObject>
-(void) returnResult: (NSObject *) result key: (NSString*) key;
@end
