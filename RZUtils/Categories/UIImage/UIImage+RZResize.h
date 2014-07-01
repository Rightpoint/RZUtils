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


#import <Foundation/Foundation.h>

@interface UIImage (RZResize)

/**
 *  Resizes an image to a given size while optionally preserving the aspect ratio.
 *
 *  @param image          the UIImage to be resized.
 *  @param newSize        the CGSize to resize the image to.
 *  @param preserveAspect preserves the aspect ratio of the UIImage if set to YES.
 *
 *  @return a new instance of the input UIImage resized to newSize.
 */
+ (UIImage *)rz_imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize preserveAspectRatio:(BOOL)preserveAspect;

/**
 *  Returns the resulting size of an image after a resize operation. If the aspect ratio is preserved,
 *  then the resulting size could be different than the provided newSize.
 *
 *  @param image          the UIImage that the size is desired.
 *  @param newSize        the desired new size of the UIImage.
 *  @param preserveAspect preserves the aspect ratio of the UIImage if set to YES.
 *
 *  @return the size for the input UIImage image.
 */
+ (CGSize)rz_sizeForImage:(UIImage *)image scaledToSize:(CGSize)newSize preserveAspectRatio:(BOOL)preserveAspect;

@end
