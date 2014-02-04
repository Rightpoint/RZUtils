//
//  UIView+RZFrameUtils.h
//
//  Created by Nick Donaldson on 3/27/13.
//  Copyright (c) 2013 Raizlabs. 
//

#import <UIKit/UIKit.h>

// For easy setting of frame values

@interface UIView (RZFrameUtils)

- (void)setFrameOriginX:(CGFloat)originX;
- (void)setFrameOriginX:(CGFloat)originX lockRight:(BOOL)lockRight;
- (void)setFrameOriginY:(CGFloat)originY;
- (void)setFrameOriginY:(CGFloat)originY lockBottom:(BOOL)lockBottom;
- (void)setFrameOrigin:(CGPoint)point;

- (void)setFrameWidth:(CGFloat)width;
- (void)setFrameWidth:(CGFloat)width alignRight:(BOOL)alignRight;
- (void)setFrameHeight:(CGFloat)height;
- (void)setFrameSize:(CGSize)size;

// "nudge" by an amount - add that amount to each frame property
- (void)nudgeFrameOriginX:(CGFloat)nx originY:(CGFloat)ny width:(CGFloat)nw height:(CGFloat)nh;
- (void)moveFrameToTheRightOf:(CGRect)leftFrame withPadding:(int)padding;

@end
