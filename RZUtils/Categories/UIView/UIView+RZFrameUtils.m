//
//  UIView+RZFrameUtils.m
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

#import "UIView+RZFrameUtils.h"


@implementation UIView (RZFrameUtils)

- (void)rz_setFrameOriginX:(CGFloat)originX
{
    [self rz_setFrameOriginX:originX lockRight:NO];
}

- (void)rz_setFrameOriginX:(CGFloat)originX lockRight:(BOOL)lockRight
{
    CGFloat rightEdge = CGRectGetMaxX(self.frame);
    [self rz_setFrameOrigin:CGPointMake(originX, self.frame.origin.y)];
    if (lockRight){
        [self rz_setFrameWidth:rightEdge - originX];
    }
}

- (void)rz_setFrameOriginY:(CGFloat)originY
{
    [self rz_setFrameOriginY:originY lockBottom:NO];
}

- (void)rz_setFrameOriginY:(CGFloat)originY lockBottom:(BOOL)lockBottom
{
    CGFloat bottomEdge = CGRectGetMaxY(self.frame);
    [self rz_setFrameOrigin:CGPointMake(self.frame.origin.x, originY)];
    if (lockBottom)
    {
        [self rz_setFrameHeight:bottomEdge - originY];
    }
}

- (void)rz_setFrameOrigin:(CGPoint)point
{
    CGRect frame = self.frame;
    frame.origin = point;
    self.frame = frame;
}

- (void)rz_setFrameWidth:(CGFloat)width
{
    [self rz_setFrameWidth:width alignRight:NO];
}

- (void)rz_setFrameWidth:(CGFloat)width alignRight:(BOOL)alignRight
{
    if (alignRight){
        CGFloat rightX = CGRectGetMaxX(self.frame);
        [self rz_setFrameSize:CGSizeMake(width, self.frame.size.height)];
        [self rz_setFrameOriginX:rightX-width];
    }
    else{
        [self rz_setFrameSize:CGSizeMake(width, self.frame.size.height)];
    }
}

- (void)rz_setFrameHeight:(CGFloat)height
{
    [self rz_setFrameSize:CGSizeMake(self.frame.size.width, height)];
}

- (void)rz_setFrameSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)rz_nudgeFrameOriginX:(CGFloat)nx originY:(CGFloat)ny width:(CGFloat)nw height:(CGFloat)nh
{
    CGRect frame = self.frame;
    frame.origin.x += nx;
    frame.origin.y += ny;
    frame.size.width += nw;
    frame.size.height += nh;
    self.frame = frame;
}

- (void)rz_moveFrameToTheRightOf:(CGRect)leftFrame withPadding:(int)padding
{
    self.frame = CGRectMake(leftFrame.origin.x + leftFrame.size.width + padding,
                      self.frame.origin.y,
                      self.frame.size.width,
                      self.frame.size.height);
}

@end
