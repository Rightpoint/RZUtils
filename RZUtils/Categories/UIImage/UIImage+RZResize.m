//
// Created by Joshua Leibsly on 1/15/14.
// Copyright (c) 2014 Raizlabs. All rights reserved.
//


#import "UIImage+RZResize.h"


@implementation UIImage (RZResize)

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize preserveAspectRatio:(BOOL)preserveAspect
{
    CGSize size = [UIImage sizeForImage:image scaledToSize:newSize preserveAspectRation:preserveAspect];

    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (CGSize)sizeForImage:(UIImage *)image scaledToSize:(CGSize)newSize preserveAspectRation:(BOOL)preserveAspect
{
    CGSize size = newSize;
    if(preserveAspect)
    {
        CGFloat ratio = image.size.width / image.size.height;
        if(image.size.width > image.size.height)
        {
            size.height = size.width / ratio;
        }
        else
        {
            size.width = size.height * ratio;
        }
    }

    return size;
}

@end