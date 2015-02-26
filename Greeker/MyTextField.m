//
//  MyTextField.m
//  Greeker
//
//  Created by Thohd on 4/14/14.
//  Copyright (c) 2014 Thohd. All rights reserved.
//

#import "MyTextField.h"

@implementation MyTextField

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    bounds.size.height += 6;
    bounds.origin.y -= 3;
    return CGRectInset( bounds , 10 , 10 );
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    bounds.size.height += 6;
    bounds.origin.y -= 3;
    return CGRectInset( bounds , 10 , 10 );
}


@end
