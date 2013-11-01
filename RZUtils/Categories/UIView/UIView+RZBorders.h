//
//  UIView+RZBorders.h
//  Raizlabs
//
//  Created by Nick Donaldson on 10/30/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
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

// UIView subclass with configurable borders.
@interface RZBorderedHostView : UIView

@property (nonatomic, assign) RZViewBorderMask  rz_borderMask;
@property (nonatomic, assign) CGFloat           rz_borderWidth;
@property (nonatomic, strong) UIColor           *rz_borderColor;

@end

// Adds a clear-background instance of RZBorderedHostView as a subview of the target view.
// Good enough when the subview hierarchy is simple enough such that nothing will be added on top of the borders.
@interface UIView (RZBorders)

- (void)rz_addBordersWithMask:(RZViewBorderMask)mask width:(CGFloat)borderWidth color:(UIColor*)color;
- (void)rz_removeBorders;

@end
