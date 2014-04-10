//
// Created by Joshua Leibsly on 1/15/14.

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


#import "UIImage+RZResize.h"


@implementation UIImage (RZResize)

+ (UIImage *)rz_imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize preserveAspectRatio:(BOOL)preserveAspect
{
    // Get the resulting size of the image.
    CGSize size = [UIImage rz_sizeForImage:image scaledToSize:newSize preserveAspectRatio:preserveAspect];

    // Draw the image.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

+ (CGSize)rz_sizeForImage:(UIImage *)image scaledToSize:(CGSize)newSize preserveAspectRatio:(BOOL)preserveAspect
{
    CGSize size = newSize;

    // If we're preserving the aspect ratio, calculate the resulting size.
    if(preserveAspect)
    {
        CGFloat ratio = image.size.width / image.size.height;
        if(image.size.width > image.size.height)
        {
            size.height = ceilf(size.width / ratio);
        }
        else
        {
            size.width = ceilf(size.height * ratio);
        }
    }

    return size;
}

@end
