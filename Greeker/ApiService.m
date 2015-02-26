//
//  ApiService.m
//  Greeker
//
//  Created by Hoang Nguyen on 9/1/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "ApiService.h"
#import <AFNetworking/AFNetworking.h>
#import <QuartzCore/QuartzCore.h>

@implementation ApiService
- (void) getMemberListOfClub: (NSString *) orgId
{
    NSDictionary *parameters =@{
                                @"club_id" : orgId
                                };
    NSString * url = [kBASE_NEW_API stringByAppendingString:kMEMBER_LIST];
    NSLog(@"URL: %@", url);
    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:url]];
    
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSObject *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
         

             NSLog(@"response: %@",jsons);
             [self.delegate returnResult:jsons key:@"Member List"];
         
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




@end
