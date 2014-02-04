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
- (void)rz_alignSubviews:(NSArray *)subviews byAttribute:(NSLayoutAttribute)attribute;

@end
