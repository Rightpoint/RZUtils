//
//  UIView+RZBorders.h
//  Raizlabs
//
//  Created by Nick Donaldson on 10/30/13.
//  Copyright (c) 2013 Raizlabs. 
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RZViewBorderMask)
{
    RZViewBorderNone    = 0,
    RZViewBorderLeft    = (1 << 0),
    RZViewBorderBottom  = (1 << 1),
    RZViewBorderRight   = (1 << 2),
    RZViewBorderTop     = (1 << 3),
    RZViewBorderAll     = RZViewBorderLeft | RZViewBorderBottom | RZViewBorderRight | RZViewBorderTop
};

// Adds a generated border image view as the highest z-ordered subview of the target view (above all other views).
@interface UIView (RZBorders)

- (void)rz_addBordersWithMask:(RZViewBorderMask)mask width:(CGFloat)borderWidth color:(UIColor*)color;
- (void)rz_removeBorders;

@end
