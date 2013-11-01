//
//  UIView+RZAutoLayoutHelpers.h
//
//  Created by Nick Donaldson on 10/22/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

// Less-verbose implementations of common tasks when using autolayout.
//
// More complex tasks with specific constants should be implemented elsewhere.
//
// These methods make NO guarantee about existing constraints. If you've already added constraints,
// it's up to you to make sure that adding these won't break your layout.

@interface UIView (RZAutoLayoutHelpers)

- (void)rz_pinWidthTo:(CGFloat)width;
- (void)rz_pinHeightTo:(CGFloat)height;
- (void)rz_pinSizeTo:(CGSize)size;

- (void)rz_centerHorizontallyInContainer;
- (void)rz_centerHorizontallyInContainerWithOffset:(CGFloat)offset;
- (void)rz_centerVerticallyInContainer;
- (void)rz_centerVerticallyInContainerWithOffset:(CGFloat)offset;

- (void)rz_fillContainerWithInsets:(UIEdgeInsets)insets;

- (void)rz_fillContainerHorizontallyWithMinPadding:(CGFloat)padding;
- (void)rz_fillContainerVerticallyWithMinPadding:(CGFloat)padding;

- (void)rz_insetFromContainerTopBy:(CGFloat)padding;
- (void)rz_insetFromContainerLeftBy:(CGFloat)padding;
- (void)rz_insetFromContainerBottomBy:(CGFloat)padding;
- (void)rz_insetFromContainerRightBy:(CGFloat)padding;

- (void)rz_spaceSubviews:(NSArray *)subviews vertically:(BOOL)vertically minimumItemSpacing:(CGFloat)itemSpacing;
- (void)rz_alignSubviews:(NSArray *)subviews byAttribute:(NSLayoutAttribute)attribute;

@end
