//
//  RZSingleChildContainerViewController.h
//
//  Created by Nick Donaldson on 10/3/13.

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

typedef void (^RZSingleChildContainerViewControllerCompletionBlock)(void);

@interface RZSingleChildContainerViewController : UIViewController

// The current content child (if any)
@property (nonatomic, readonly) UIViewController *currentContentViewController;

// Defaults to a simple alpha-fade transitioner. Set to another object to implement a custom transition
@property (nonatomic, strong) id<UIViewControllerAnimatedTransitioning> contentVCAnimatedTransition;

// Perform this block when the view is loaded. If already loaded, happens immediately.
// Useful for pre-configuring child viewcontrollers just after allocation, when view is not loaded yet.
- (void)performBlockWhenViewLoaded:(void(^)())block;

// Supports only a single child VC in its content area
// Subclasses should not override - override animation methods to customize animation transitions
- (void)setContentViewController:(UIViewController *)viewController animated:(BOOL)animated __attribute__((deprecated("Use setContentViewController:animated:completion: instead.")));

// Supports only a single child VC in its content area
// Subclasses should not override - override animation methods to customize animation transitions
- (void)setContentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(RZSingleChildContainerViewControllerCompletionBlock)completion;

/* ---------- Override in Subclasses ------------
 *     Do not call these methods directly
 */

// Container view for the children. Defaults to self.view.
- (UIView *)childContentContainerView;

// --------------------------------------------

@end
