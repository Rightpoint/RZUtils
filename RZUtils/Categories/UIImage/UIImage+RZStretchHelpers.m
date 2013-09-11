//
//  UIImage+RZStretchHelpers.m
//
//  Created by Stephen Barnes on 4/9/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//


#import "UIImage+RZStretchHelpers.h"

@implementation UIImage (RZStretchHelpers)

- (UIImage*)makeStretchable
{
    CGFloat xCap = floorf(self.size.width/2.0f);
    CGFloat yCap = floorf(self.size.height/2.0f);
    return [self resizableImageWithCapInsets:UIEdgeInsetsMake(yCap, xCap, yCap, xCap)];
}

- (UIImage*)makeStretchableWithCapInsets:(UIEdgeInsets)insets
{
    return [self resizableImageWithCapInsets:insets];
}

@end
