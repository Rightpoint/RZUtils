//
//  UIView+RZFrameUtils.h
//
//  Created by Nick Donaldson on 3/27/13.

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

#import <UIKit/UIKit.h>

// For easy setting of frame values

@interface UIView (RZFrameUtils)

- (void)rz_setFrameOriginX:(CGFloat)originX;
- (void)rz_setFrameOriginX:(CGFloat)originX lockRight:(BOOL)lockRight;
- (void)rz_setFrameOriginY:(CGFloat)originY;
- (void)rz_setFrameOriginY:(CGFloat)originY lockBottom:(BOOL)lockBottom;
- (void)rz_setFrameOrigin:(CGPoint)point;

- (void)rz_setFrameWidth:(CGFloat)width;
- (void)rz_setFrameWidth:(CGFloat)width alignRight:(BOOL)alignRight;
- (void)rz_setFrameHeight:(CGFloat)height;
- (void)rz_setFrameSize:(CGSize)size;

// "nudge" by an amount - add that amount to each frame property
- (void)rz_nudgeFrameOriginX:(CGFloat)nx originY:(CGFloat)ny width:(CGFloat)nw height:(CGFloat)nh;
- (void)rz_moveFrameToTheRightOf:(CGRect)leftFrame withPadding:(int)padding;

@end
