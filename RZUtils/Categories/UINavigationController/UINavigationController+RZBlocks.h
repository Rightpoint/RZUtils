//
//  UINavigationController+RZBlocks.h
//
//  Created by Andrew McKnight on 5/28/14.
//
//  Copyright (c) 2014 Raizlabs and other contributors.
//  http://raizlabs.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <UIKit/UIKit.h>

/**
 *  A block containing logic to be performed after the navigation controller has
 *  finished its push/pop (executed after @c navigationController:didShowViewController:animated:).
 *
 *  @param navigationController    The navigation controller pushing/popping.
 *  @param presentedViewController The top view controller after the push/pop.
 *  @param poppedViewControllers   Any view controllers that were popped.
 */
typedef void(^RZNavigationControllerCompletionBlock)(UINavigationController *navigationController,
                                                     UIViewController *presentedViewController,
                                                     NSArray *poppedViewControllers);

/**
 *  A block containing logic to be performed before the navigation controller
 *  has begun a push/pop (executed before @c navigationController:willShowViewController:animated:).
 *
 *  @param navigationController     The navigation controller that will push/pop.
 *  @param presentingViewController The view controller that will be on top of
 *                                  the nav stack after the push/pop.
 */
typedef void(^RZNavigationControllerPreparationBlock)(UINavigationController *navigationController,
                                                      UIViewController *presentingViewController);
/**
 *  Category that provides a block based interface for performing operations
 *  after push/pop to/from a navigation controller. The callbacks in 
 *  UINavigationControllerDelegate are still called, with the total order of 
 *  operations being:
 *
 *      @code 
 *      1. preparation block
 *      2. navigationController:willShowViewController:animated:
 *      3. navigationController:didShowViewController:animated:
 *      4. completion block
 */

@interface UINavigationController (RZBlocks) <UINavigationControllerDelegate>

/**
 *  Push a view controller onto the nav stack with preparation and completion
 *  blocks.
 *
 *  @param viewController The view controller to push onto the nav stack.
 *  @param animated       Whether or not the transition should be animated.
 *  @param preparation    Block to be called before viewController is shown (executes before callback to @c navigationController:willShowViewController:animated:).
 *  @param completion     Block to be called after viewController has been shown (executes after callback to @c navigationController:didShowViewController:animated:).
 */
- (void)rz_pushViewController:(UIViewController *)viewController
                     animated:(BOOL)animated
                  preparation:(RZNavigationControllerPreparationBlock)preparation
                   completion:(RZNavigationControllerCompletionBlock)completion;

/**
 *  Pop the topmost view controller from the nav stack with preparation and
 *  completion blocks.
 *
 *  @param animated       Whether or not the transition should be animated.
 *  @param preparation    Block to be called before viewController is shown (executes before callback to @c navigationController:willShowViewController:animated:).
 *  @param completion     Block to be called after viewController has been shown (executes after callback to @c navigationController:didShowViewController:animated:).
 */
- (void)rz_popViewControllerAnimated:(BOOL)animated
                         preparation:(RZNavigationControllerPreparationBlock)preparation
                          completion:(RZNavigationControllerCompletionBlock)completion;

/**
 *  Pops view controllers from the nav stack to reveal a desired view controller
 *  with preparation and completion blocks.
 *
 *  @param viewController The view controller reveal.
 *  @param animated       Whether or not the transition should be animated.
 *  @param preparation    Block to be called before viewController is shown (executes before callback to @c navigationController:willShowViewController:animated:).
 *  @param completion     Block to be called after viewController has been shown (executes after callback to @c navigationController:didShowViewController:animated:).
 */
- (void)rz_popToViewController:(UIViewController *)viewController
                      animated:(BOOL)animated
                   preparation:(RZNavigationControllerPreparationBlock)preparation
                    completion:(RZNavigationControllerCompletionBlock)completion;

/**
 *  Pop all but the root view controller from the nav stack with preparation and
 *  completion blocks.
 *
 *  @param animated       Whether or not the transition should be animated.
 *  @param preparation    Block to be called before viewController is shown (executes before callback to @c navigationController:willShowViewController:animated:).
 *  @param completion     Block to be called after viewController has been shown (executes after callback to @c navigationController:didShowViewController:animated:).
 */
- (void)rz_popToRootViewControllerAnimated:(BOOL)animated
                               preparation:(RZNavigationControllerPreparationBlock)preparation
                                completion:(RZNavigationControllerCompletionBlock)completion;

/**
 *  Push a collection of view controllers onto the nav stack with preparation 
 *  and completion blocks.
 *
 *  @param viewControllers The view controller to push onto the nav stack.
 *  @param animated        Whether or not the transition should be animated.
 *  @param preparation     Block to be called before viewController is shown (executes before callback to @c navigationController:willShowViewController:animated:).
 *  @param completion      Block to be called after viewController has been shown (executes after callback to @c navigationController:didShowViewController:animated:).
 */
- (void)rz_setViewControllers:(NSArray *)viewControllers
                     animated:(BOOL)animated
                  preparation:(RZNavigationControllerPreparationBlock)preparation
                   completion:(RZNavigationControllerCompletionBlock)completion NS_AVAILABLE_IOS(3_0);


@end
