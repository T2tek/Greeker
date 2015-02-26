//
//  ChatLabel.m
//  Greeker
//
//  Created by Hoang Nguyen on 30/09/2014.
//  Copyright (c) Năm 2014 Thohd. All rights reserved.
//

#import "ChatLabel.h"

@implementation ChatLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)drawTextInRect:(CGRect)rect {
    [self.layer setCornerRadius:5.0f];
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0, 5, 0, 5))];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    return CGRectInset([self.attributedText boundingRectWithSize:CGSizeMake(999, 999)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                         context:nil], -5, 0);
}

@end
