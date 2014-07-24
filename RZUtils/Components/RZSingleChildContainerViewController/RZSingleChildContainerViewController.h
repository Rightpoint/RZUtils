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

/**
 *  The current child content view controller, if any.
 */
@property (nonatomic, readonly) UIViewController *currentContentViewController;

/**
 *  The transition that is used when changing the content view controller. Defaults to a simple alpha crossfade animation.
 */
@property (strong, nonatomic) id <UIViewControllerAnimatedTransitioning> contentVCAnimatedTransition;

/**
 *  Whether the child view controller is currently transitioning to another view controller.
 */
@property (nonatomic, readonly) BOOL isTransitioning;

/**
 *  Transitions to the passed view controller
 *
 *  @param viewController The view controller you want to transition to.
 *  @param animated       Whether or not to animate the transition. If you want to customize the animation, set a custom transition for the @c contentVCAnimatedTransition property.
 *
 *  @deprecated Use @p setContentViewController:animated:completion: instead.
 */
- (void)setContentViewController:(UIViewController *)viewController animated:(BOOL)animated __attribute__((deprecated("Use setContentViewController:animated:completion: instead.")));

// Supports only a single child VC in its content area
// Subclasses should not override - override animation methods to customize animation transitions

/**
 *  Transitions to the passed view controller.
 *
 *  @param viewController The view controller you want to transition to.
 *  @param animated       Whether or not to animate the transition. If you want to customize the animation, set a custom transition for the @c contentVCAnimatedTransition property.
 *  @param completion     A completion block. Run when the transition is done. If @c animated is @NO, it is run as soon as the new child view controller’s view has loaded.
 *
 *  @see @c contentVCAnimatedTransition
 *  @warning If you call this method while a transition is in progress (i.e. while @c isTransitioning is @c YES), an exception is raised.
 */
- (void)setContentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(RZSingleChildContainerViewControllerCompletionBlock)completion;

/**
 *  Returns the view of the child content
 *
 *  @return The view that should be used as the container view for the child view controller.
 *  @note Override this in a subclass if you want to return a view other than the child view controller’s view.
 */
- (UIView *)childContentContainerView;

@end
