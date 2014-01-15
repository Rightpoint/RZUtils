//
// Created by Joshua Leibsly on 1/15/14.
// Copyright (c) 2014 Raizlabs. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface UIImage (RZResize)

// Resizes an image to a given size while optionally preserving the aspect ratio.
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize preserveAspectRatio:(BOOL)preserveAspect;

// Returns the resulting size of an image after a resize operation. If the aspect ratio is preserved, then the resulting
// size could be different than the provided newSize.
+ (CGSize)sizeForImage:(UIImage *)image scaledToSize:(CGSize)newSize preserveAspectRation:(BOOL)preserveAspect;
@end