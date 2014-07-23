//
//  UIView+RZAutoLayoutHelpers.h
//
//  Created by Nick Donaldson on 10/22/13.

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

/**
 *  Less-verbose implementations of common tasks when using autolayout.
 *  More complex tasks with specific constants should be implemented elsewhere.
 *
 *  @note Unless documented otherwise, each method which creates constraints also returns the constraint
 *        (or constraints) that were added.
 *
 *  @warning These methods make NO guarantee about existing constraints. If you've already added constraints,
 *           it's up to you to make sure that adding these won't break your layout.
 */
@interface UIView (RZAutoLayoutHelpers)

/** @name Constraint Getters */

- (NSLayoutConstraint*)rz_pinnedWidthConstraint;
- (NSLayoutConstraint*)rz_pinnedHeightConstraint;

- (NSLayoutConstraint*)rz_pinnedTopConstraint;
- (NSLayoutConstraint*)rz_pinnedLeftConstraint;
- (NSLayoutConstraint*)rz_pinnedRightConstraint;
- (NSLayoutConstraint*)rz_pinnedBottomConstraint;

- (NSLayoutConstraint*)rz_pinnedCenterXConstraint;
- (NSLayoutConstraint*)rz_pinnedCenterYConstraint;

/** @name Constraint Creation */

- (NSLayoutConstraint *)rz_pinWidthTo:(CGFloat)width;
- (NSLayoutConstraint *)rz_pinWidthToView:(UIView *)view;
- (NSLayoutConstraint *)rz_pinHeightTo:(CGFloat)height;
- (NSLayoutConstraint *)rz_pinHeightToView:(UIView *)view;
- (NSArray *)rz_pinSizeTo:(CGSize)size;

- (NSLayoutConstraint *)rz_pinTopSpaceToSuperviewWithPadding:(CGFloat)padding;
- (NSLayoutConstraint *)rz_pinLeftSpaceToSuperviewWithPadding:(CGFloat)padding;
- (NSLayoutConstraint *)rz_pinBottomSpaceToSuperviewWithPadding:(CGFloat)padding;
- (NSLayoutConstraint *)rz_pinRightSpaceToSuperviewWithPadding:(CGFloat)padding;
- (NSArray *)rz_fillContainerWithInsets:(UIEdgeInsets)insets;

- (NSArray *)rz_fillContainerHorizontallyWithPadding:(CGFloat)padding;
- (NSArray *)rz_fillContainerHorizontallyWithMinimumPadding:(CGFloat)padding;
- (NSArray *)rz_fillContainerVerticallyWithPadding:(CGFloat)padding;
- (NSArray *)rz_fillContainerVerticallyWithMinimumPadding:(CGFloat)padding;

- (NSLayoutConstraint *)rz_centerHorizontallyInContainer;
- (NSLayoutConstraint *)rz_centerHorizontallyInContainerWithOffset:(CGFloat)offset;
- (NSLayoutConstraint *)rz_centerVerticallyInContainer;
- (NSLayoutConstraint *)rz_centerVerticallyInContainerWithOffset:(CGFloat)offset;

// Batch alignment
/**
 *  Create a vertical or horizontal minimum space constraint between each adjacent pair of views in an array. This method is 
 *  deprecated in favor of rz_spaceSubViews:vertically:itemSpacing:relation:
 *
 *  @param subviews    The array of views to space. The order of the array should reflect their spatial order.
 *  @param vertically  YES if the spaces should exist between views' top and bottom edges, NO if between left and right edges.
 *  @param itemSpacing The minimum amount of space that should exist between adjacent views.
 *
 *  @return An array of the constraints that were added.
 */
- (NSArray *)rz_spaceSubviews:(NSArray *)subviews vertically:(BOOL)vertically minimumItemSpacing:(CGFloat)itemSpacing __attribute__((deprecated("Use rz_spaceSubViews:vertically:itemSpacing:relation: instead.")));

/**
 *  Create a vertical or horizontal space constraint between each adjacent pair of views in an array.
 *
 *  @param subviews    The array of views to space. The order of the array should reflect their spatial order.
 *  @param vertically  YES if the spaces should exist between views' top and bottom edges, NO if between left and right edges.
 *  @param itemSpacing The amount (or minimum/maximum) of space that should exist between adjacent views.
 *  @param relation    Either NSLayoutRelationEqual, NSLayoutRelationEqualLessThanOrEqual, NSLayoutRelationGreaterThanOrEqual.
 *
 *  @return An array of the constraints that were added.
 */
- (NSArray *)rz_spaceSubviews:(NSArray *)subviews vertically:(BOOL)vertically itemSpacing:(CGFloat)itemSpacing relation:(NSLayoutRelation)relation;

/**
 *  Distribute views vertically or horizontally along the same axis with equal spacing in the receiver.
 *
 *  @param subviews   Array of subviews to distribute. Must be subviews of the receiver.
 *  @param vertically YES to distribute vertically, NO for horizontally
 *
 *  @return An array of the constraints that were added.
 */
- (NSArray *)rz_distributeSubviews:(NSArray *)subviews vertically:(BOOL)vertically;

/**
 *  Align views within the receiver by a particular attribute.
 *
 *  @param subviews  An array of views to align. Must be subviews of the receiver.
 *  @param attribute Attribute by which to align.
 *
 *  @return An array of constraints that were added.
 */
- (NSArray *)rz_alignSubviews:(NSArray *)subviews byAttribute:(NSLayoutAttribute)attribute;

@end
