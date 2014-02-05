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

// Return a particular constraint of this view if it exists
- (NSLayoutConstraint*)rz_pinnedWidthConstraint;
- (NSLayoutConstraint*)rz_pinnedHeightConstraint;

- (NSLayoutConstraint*)rz_pinnedTopConstraint;
- (NSLayoutConstraint*)rz_pinnedLeftConstraint;
- (NSLayoutConstraint*)rz_pinnedRightConstraint;
- (NSLayoutConstraint*)rz_pinnedBottomConstraint;

- (NSLayoutConstraint*)rz_pinnedCenterXConstraint;
- (NSLayoutConstraint*)rz_pinnedCenterYConstraint;

// Pinning dimensions
- (void)rz_pinWidthTo:(CGFloat)width;
- (void)rz_pinHeightTo:(CGFloat)height;
- (void)rz_pinSizeTo:(CGSize)size;

// Pinning sides
- (void)rz_pinTopSpaceToSuperviewWithPadding:(CGFloat)padding;
- (void)rz_pinLeftSpaceToSuperviewWithPadding:(CGFloat)padding;
- (void)rz_pinBottomSpaceToSuperviewWithPadding:(CGFloat)padding;
- (void)rz_pinRightSpaceToSuperviewWithPadding:(CGFloat)padding;
- (void)rz_fillContainerWithInsets:(UIEdgeInsets)insets;

- (void)rz_fillContainerHorizontallyWithPadding:(CGFloat)padding;
- (void)rz_fillContainerHorizontallyWithMinimumPadding:(CGFloat)padding;
- (void)rz_fillContainerVerticallyWithPadding:(CGFloat)padding;
- (void)rz_fillContainerVerticallyWithMinimumPadding:(CGFloat)padding;

// Centering
- (void)rz_centerHorizontallyInContainer;
- (void)rz_centerHorizontallyInContainerWithOffset:(CGFloat)offset;
- (void)rz_centerVerticallyInContainer;
- (void)rz_centerVerticallyInContainerWithOffset:(CGFloat)offset;

// Batch alignment
- (void)rz_spaceSubviews:(NSArray *)subviews vertically:(BOOL)vertically minimumItemSpacing:(CGFloat)itemSpacing;
- (void)rz_distributeSubviews:(NSArray *)subviews vertically:(BOOL)vertically;
- (void)rz_alignSubviews:(NSArray *)subviews byAttribute:(NSLayoutAttribute)attribute;

@end
