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

/** @name Helpers */

/**
 *  Return the common ancestor shared by all the views passed in, if it exists.
 *
 *  @return The common ancestor.
 */
+ (UIView *)rz_commonAncestorForViews:(NSArray *)views;

/** @name Constraint Getters */

/**
 *  Return the receiver's pinned width constraint, if it exsists.
 *
 *  @return The constraint or nil.
 */
- (NSLayoutConstraint*)rz_pinnedWidthConstraint;

/**
 *  Return the receiver's pinned height constraint, if it exsists.
 *
 *  @return The constraint or nil.
 */
- (NSLayoutConstraint*)rz_pinnedHeightConstraint;

/**
 *  Return the receiver's pinned top constraint, if it exsists.
 *
 *  @return The constraint or nil.
 */
- (NSLayoutConstraint*)rz_pinnedTopConstraint;

/**
 *  Return the receiver's pinned left side constraint, if it exsists.
 *
 *  @return The constraint or nil.
 */
- (NSLayoutConstraint*)rz_pinnedLeftConstraint;

/**
 *  Return the receiver's pinned right side constraint, if it exsists.
 *
 *  @return The constraint or nil.
 */
- (NSLayoutConstraint*)rz_pinnedRightConstraint;

/**
 *  Return the receiver's pinned bottom constraint, if it exsists.
 *
 *  @return The constraint or nil.
 */
- (NSLayoutConstraint*)rz_pinnedBottomConstraint;

/**
 *  Return the receiver's pinned center X constraint, if it exsists.
 *
 *  @return The constraint or nil.
 */
- (NSLayoutConstraint*)rz_pinnedCenterXConstraint;

/**
 *  Return the receiver's pinned center Y constraint, if it exsists.
 *
 *  @return The constraint or nil.
 */
- (NSLayoutConstraint*)rz_pinnedCenterYConstraint;

/** @name Constraint Creation */

/**
 *  Pin the receiver's width to a constant.
 *
 *  @param width Deisred width.
 *
 *  @return The pinned width constraint that was added.
 */
- (NSLayoutConstraint *)rz_pinWidthTo:(CGFloat)width;

/**
 *  Pin the receiver's width to the width of another view.
 *
 *  @param view The view to pin width to.
 *
 *  @return The pinned width constraint that was added.
 */
- (NSLayoutConstraint *)rz_pinWidthToView:(UIView *)view;

/**
 *  Pin the receiver's width to the width of another view with a particular multiplier.
 *
 *  @param view The view to pin width to.
 *  @param multiplier The multiplier to use for the pinning. 1.0 = exact width, 0.5 = half the width, etc.
 *
 *  @note The constant on the returned constraint may also be edited.
 *
 *  @return The pinned width constraint that was added.
 */
- (NSLayoutConstraint *)rz_pinWidthToView:(UIView *)view multiplier:(CGFloat)multiplier;

/**
 *  Pin the receiver's width to a constant.
 *
 *  @param width Deisred height.
 *
 *  @return The pinned height constraint that was added.
 */
- (NSLayoutConstraint *)rz_pinHeightTo:(CGFloat)height;

/**
 *  Pin the receiver's height to the height of another view.
 *
 *  @param view The view to pin height to.
 *
 *  @return The pinned height constraint that was added.
 */
- (NSLayoutConstraint *)rz_pinHeightToView:(UIView *)view;

/**
 *  Pin the receiver's height to the height of another view with a particular multiplier.
 *
 *  @param view The view to pin height to.
 *  @param multiplier The multiplier to use for the pinning. 1.0 = exact height, 0.5 = half the height, etc.
 *
 *  @note The constant on the returned constraint may also be edited.
 *
 *  @return The pinned height constraint that was added.
 */
- (NSLayoutConstraint *)rz_pinHeightToView:(UIView *)view multiplier:(CGFloat)multiplier;

/**
 *  Pin the receiver's size to a particular value.
 *
 *  @param size The size to pin to.
 *
 *  @return The constraints that were added: [width, height].
 */
- (NSArray *)rz_pinSizeTo:(CGSize)size;

/**
 *  Pin the receiver's top space to its superview's top with a fixed amount of padding.
 *
 *  @param padding The amount of padding between the top of the receiver and the superview.
 *
 *  @warning The receiver must have a superview when this method is called.
 *
 *  @return The constraint that was added.
 */
- (NSLayoutConstraint *)rz_pinTopSpaceToSuperviewWithPadding:(CGFloat)padding;

/**
 *  Pin the receiver's left space to its superview's left side with a fixed amount of padding.
 *
 *  @param padding The amount of padding between the left side of the receiver and the superview.
 *
 *  @warning The receiver must have a superview when this method is called.
 *
 *  @return The constraint that was added.
 */
- (NSLayoutConstraint *)rz_pinLeftSpaceToSuperviewWithPadding:(CGFloat)padding;

/**
 *  Pin the receiver's bottom space to its superview's bottom with a fixed amount of padding.
 *
 *  @param padding The amount of padding between the bottom of the receiver and the superview.
 *
 *  @warning The receiver must have a superview when this method is called.
 *
 *  @return The constraint that was added.
 */
- (NSLayoutConstraint *)rz_pinBottomSpaceToSuperviewWithPadding:(CGFloat)padding;

/**
 *  Pin the receiver's right space to its superview's right side with a fixed amount of padding.
 *
 *  @param padding The amount of padding between the right side of the receiver and the superview.
 *
 *  @warning The receiver must have a superview when this method is called.
 *
 *  @return The constraint that was added.
 */
- (NSLayoutConstraint *)rz_pinRightSpaceToSuperviewWithPadding:(CGFloat)padding;

/**
 *  Pin all sides of the receiver to its superview's sides with fixed insets.
 *
 *  @param insets Insets between receiver's sides and superview.
 *
 *  @warning The receiver must have a superview when this method is called.
 *
 *  @return The constraints that were added: [top, left, bottom, right]
 */
- (NSArray *)rz_fillContainerWithInsets:(UIEdgeInsets)insets;

/**
 *  Make the receiver fill its superview horizontally with a fixed amount of padding.
 *  Equivalent to pinning left and right sides to superview.
 *
 *  @param padding The horizontal padding between the receiver and it superview.
 *
 *  @warning The receiver must have a superview when this method is called.
 *
 *  @return The constraints that were added: [left, right]
 */
- (NSArray *)rz_fillContainerHorizontallyWithPadding:(CGFloat)padding;

/**
 *  Make the receiver fill its superview horizontally with a minimum amount of padding.
 *  Equivalent to pinning left and right sides to superview with relation >=.
 *
 *  @param padding The minimum padding between the receiver and it superview.
 *
 *  @warning The receiver must have a superview when this method is called.
 *
 *  @return The constraints that were added: [left, right]
 */
- (NSArray *)rz_fillContainerHorizontallyWithMinimumPadding:(CGFloat)padding;

/**
 *  Make the receiver fill its superview vertically with a fixed amount of padding.
 *  Equivalent to pinning top and bottom to superview.
 *
 *  @param padding The vertical padding between the receiver and it superview.
 *
 *  @warning The receiver must have a superview when this method is called.
 *
 *  @return The constraints that were added: [top, bottom]
 */
- (NSArray *)rz_fillContainerVerticallyWithPadding:(CGFloat)padding;

/**
 *  Make the receiver fill its superview vertically with a fixed amount of padding.
 *  Equivalent to pinning top and bottom to superview with relation >=.
 *
 *  @param padding The vertical padding between the receiver and it superview.
 *
 *  @warning The receiver must have a superview when this method is called.
 *
 *  @return The constraints that were added: [top, bottom]
 */
- (NSArray *)rz_fillContainerVerticallyWithMinimumPadding:(CGFloat)padding;

/**
 *  Center the receiver horizontally in its superview.
 *
 *  @warning The receiver must have a superview when this method is called.
 *
 *  @return The constraint that was added.
 */
- (NSLayoutConstraint *)rz_centerHorizontallyInContainer;

/**
 *  Center the receiver horizontally in its superview with an offset.
 *
 *  @param offset The horizontal offset for the center pinning. Negative = left.
 *
 *  @warning The receiver must have a superview when this method is called.
 *
 *  @return The constraint that was added.
 */
- (NSLayoutConstraint *)rz_centerHorizontallyInContainerWithOffset:(CGFloat)offset;

/**
 *  Center the receiver vertically in its superview.
 *
 *  @warning The receiver must have a superview when this method is called.
 *
 *  @return The constraint that was added.
 */
- (NSLayoutConstraint *)rz_centerVerticallyInContainer;

/**
 *  Center the receiver vertically in its superview with an offset.
 *
 *  @param offset The vertical offset for the center pinning. Negative = up.
 *
 *  @warning The receiver must have a superview when this method is called.
 *
 *  @return The constraint that was added.
 */
- (NSLayoutConstraint *)rz_centerVerticallyInContainerWithOffset:(CGFloat)offset;


/** @name Batch Alignment */

/**
 *  Create a vertical or horizontal minimum space constraint between each adjacent pair of views in an array. 
 *
 *  @warning This method is deprecated in favor of @c rz_spaceSubViews:vertically:itemSpacing:relation:
 *
 *  @param subviews    The array of views to space. The order of the array should reflect their spatial order.
 *  @param vertically  @c YES if the spaces should exist between views' top and bottom edges, @c NO if between left and right edges.
 *  @param itemSpacing The minimum amount of space that should exist between adjacent views.
 *
 *  @return An array of the constraints that were added.
 */
- (NSArray *)rz_spaceSubviews:(NSArray *)subviews vertically:(BOOL)vertically minimumItemSpacing:(CGFloat)itemSpacing __attribute__((deprecated("Use rz_spaceSubViews:vertically:itemSpacing:relation: instead.")));

/**
 *  Create a vertical or horizontal space constraint between each adjacent pair of views in an array.
 *
 *  @param subviews    The array of views to space. The order of the array should reflect their spatial order.
 *  @param vertically  @c YES if the spaces should exist between views' top and bottom edges, @c NO if between left and right edges.
 *  @param itemSpacing The amount (or minimum/maximum) of space that should exist between adjacent views.
 *  @param relation    Either @c NSLayoutRelationEqual, @c NSLayoutRelationEqualLessThanOrEqual, @c NSLayoutRelationGreaterThanOrEqual.
 *
 *  @return An array of the constraints that were added.
 */
- (NSArray *)rz_spaceSubviews:(NSArray *)subviews vertically:(BOOL)vertically itemSpacing:(CGFloat)itemSpacing relation:(NSLayoutRelation)relation;

/**
 *  Distribute views vertically or horizontally along the same axis with equal spacing in the receiver.
 *
 *  @param subviews   Array of subviews to distribute. Must be subviews of the receiver.
 *  @param vertically @c YES to distribute vertically, @c NO for horizontally
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
