//
// Created by Joshua Leibsly on 1/15/14.
// Copyright (c) 2014 Raizlabs. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface UIImage (RZResize)

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize preserveAspectRatio:(BOOL)preserveAspect;
+ (CGSize)sizeForImage:(UIImage *)image scaledToSize:(CGSize)newSize preserveAspectRation:(BOOL)preserveAspect;
@end