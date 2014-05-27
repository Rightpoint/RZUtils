//
//  UIColor+RZColorContrast.m
//  UniFirst
//
//  Created by Connor Smith on 5/26/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "UIColor+UFColorContrast.h"

NS_ENUM(NSInteger, UFColorContrastColorIndex)
{
    r = 0,
    g,
    b,
    a
};

@implementation UIColor (UFColorContrast)

+ (UIColor *)contrastForColor:(UIColor *)color
{
    const CGFloat *colorValues = CGColorGetComponents(color.CGColor);
    
    CGFloat rValue = colorValues[r];
    CGFloat gValue = colorValues[g];
    CGFloat bValue = colorValues[b];
    
    CGFloat yiq = ( (rValue * 299.0f) + (gValue * 587.0f) + (bValue * 114.0f) ) / 1000.0f;
    
    return ( yiq >= 128.0f ) ? [UIColor blackColor] : [UIColor whiteColor];
}

@end
