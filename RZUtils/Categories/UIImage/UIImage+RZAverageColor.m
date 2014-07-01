//
// UIImage+RZAverageColor.m
//
// Created by Connor Smith on 5/27/14.
//
// Copyright 2014 Raizlabs and other contributors
// http://raizlabs.com/
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


#import "UIImage+RZAverageColor.h"

typedef NS_ENUM(NSInteger, RZColorContrastColorIndex)
{
    r = 0,
    g,
    b,
    a
};

@implementation UIImage (RZAverageColor)

- (UIColor *)rz_averageColor
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
