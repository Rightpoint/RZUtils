//
//  UIView+RZFrameUtils.m
//
//  Created by Nick Donaldson on 3/27/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "UIView+RZFrameUtils.h"


@implementation UIView (RZFrameUtils)

- (void)setFrameOriginX:(CGFloat)originX
{
    [self setFrameOriginX:originX lockRight:NO];
}

- (void)setFrameOriginX:(CGFloat)originX lockRight:(BOOL)lockRight
{
    CGFloat rightEdge = CGRectGetMaxX(self.frame);
    [self setFrameOrigin:CGPointMake(originX, self.frame.origin.y)];
    if (lockRight){
        [self setFrameWidth:rightEdge - originX];
    }
}

- (void)setFrameOriginY:(CGFloat)originY
{
    [self setFrameOriginY:originY lockBottom:NO];
}

- (void)setFrameOriginY:(CGFloat)originY lockBottom:(BOOL)lockBottom
{
    CGFloat bottomEdge = CGRectGetMaxY(self.frame);
    [self setFrameOrigin:CGPointMake(self.frame.origin.x, originY)];
    if (lockBottom)
    {
        [self setFrameHeight:bottomEdge - originY];
    }
}

- (void)setFrameOrigin:(CGPoint)point
{
    CGRect frame = self.frame;
    frame.origin = point;
    self.frame = frame;
}

- (void)setFrameWidth:(CGFloat)width
{
    [self setFrameWidth:width alignRight:NO];
}

- (void)setFrameWidth:(CGFloat)width alignRight:(BOOL)alignRight
{
    if (alignRight){
        CGFloat rightX = CGRectGetMaxX(self.frame);
        [self setFrameSize:CGSizeMake(width, self.frame.size.height)];
        [self setFrameOriginX:rightX-width];
    }
    else{
        [self setFrameSize:CGSizeMake(width, self.frame.size.height)];
    }
}

- (void)setFrameHeight:(CGFloat)height
{
    [self setFrameSize:CGSizeMake(self.frame.size.width, height)];
}

- (void)setFrameSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)nudgeFrameOriginX:(CGFloat)nx originY:(CGFloat)ny width:(CGFloat)nw height:(CGFloat)nh
{
    CGRect frame = self.frame;
    frame.origin.x += nx;
    frame.origin.y += ny;
    frame.size.width += nw;
    frame.size.height += nh;
    self.frame = frame;
}

- (void)moveFrameToTheRightOf:(CGRect)leftFrame withPadding:(int)padding
{
    self.frame = CGRectMake(leftFrame.origin.x + leftFrame.size.width + padding,
                      self.frame.origin.y,
                      self.frame.size.width,
                      self.frame.size.height);
}

@end
