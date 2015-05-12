//
//  UIImage+RZTint.m
//
//  Created by Zev Eisenberg on 5/11/15.

#import "UIImage+RZTint.h"

// Copyright 2015 Raizlabs and other contributors
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

@implementation UIImage (RZTint)

- (UIImage *)rz_tintedImageWithColor:(UIColor *)color
{
    NSParameterAssert(color);

    // Save original properties
    UIEdgeInsets originalCapInsets = self.capInsets;
    UIImageResizingMode originalResizingMode = self.resizingMode;
    UIEdgeInsets originalAlignmentRectInsets = self.alignmentRectInsets;

    // Create image context
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    // Flip the context vertically
    CGContextTranslateCTM(ctx, 0.0f, self.size.height);
    CGContextScaleCTM(ctx, 1.0f, -1.0f);

    CGRect imageRect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);

    // Image tinting mostly inspired by http://stackoverflow.com/a/22528426/255489

    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    CGContextDrawImage(ctx, imageRect, self.CGImage);

    // kCGBlendModeSourceIn: resulting color = source color * destination alpha
    CGContextSetBlendMode(ctx, kCGBlendModeSourceIn);
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillRect(ctx, imageRect);

    // Get new image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // Restore original properties
    image = [image imageWithAlignmentRectInsets:originalAlignmentRectInsets];
    if ( !UIEdgeInsetsEqualToEdgeInsets(originalCapInsets, image.capInsets) || originalResizingMode != image.resizingMode ) {
        image = [image resizableImageWithCapInsets:originalCapInsets resizingMode:originalResizingMode];
    }
    
    return image;
}

@end
