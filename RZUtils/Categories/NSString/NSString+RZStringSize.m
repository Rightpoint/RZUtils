//
//  NSString+RZStringSize.m
//  Care
//
//  Created by Nicholas Bonatsakis on 3/6/14.
//  Copyright (c) 2014 Care. All rights reserved.
//

#import "NSString+RZStringSize.h"

@implementation NSString (RZStringSize)

- (CGSize)rz_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size
{
    CGRect rect = [self boundingRectWithSize:size
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{
                                               NSFontAttributeName: font,
                                               }
                                     context:nil];
    
    return CGSizeMake(ceil(rect.size.width), ceil(rect.size.height));
}

- (CGSize)rz_sizeWithFont:(UIFont *)font
{
    return [self sizeWithAttributes:@{ NSFontAttributeName : font }];
}

@end
