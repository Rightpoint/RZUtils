//
//  UIImage+RZAverageColor.m
//  UniFirst
//
//  Created by Connor Smith on 5/27/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "UIImage+RZAverageColor.h"

NS_ENUM(NSInteger, RZColorContrastColorIndex)
{
    r = 0,
    g,
    b,
    a
};

@implementation UIImage (RZAverageColor)

- (UIColor *)averageColor
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    // Draw the image in one pixel so we get the average color.
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    CGFloat alpha = ((CGFloat)rgba[a]) / 255.0f;
    CGFloat multiplier = alpha / 255.0f;
    CGFloat avgRed = ((CGFloat)rgba[r]) * multiplier;
    CGFloat avgGreen = ((CGFloat)rgba[g]) * multiplier;
    CGFloat avgBlue = ((CGFloat)rgba[b]) * multiplier;
    
    return [UIColor colorWithRed:avgRed green:avgGreen blue:avgBlue alpha:alpha];
}

@end
