//
//  UIViewController+RZKeyboardWatcher.h
//
//  Created by Joe Mahon on 1/29/14.

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

@import Foundation;

/**
 *  The animation block for the keyboard showing.  Called using a standard UIView animation matching the 
 *  keyboard's presentation curve and it's duration.
 *
 *  @param keyboardVisible If the keyboard is visible.  YES if it is being presented, NO otherwise
 *  @param keyboardFrame   The final frame of the keyboard.
 */
typedef void (^RZKeyboardAnimationBlock)(BOOL keyboardVisible, CGRect keyboardFrame);

/**
 *  The completion block for the RZKeyboardAnimationBlock.
 *
 *  @param finished        If the animation finished successfully.
 *  @param keyboardVisible If the keyboard is visible.
 */
typedef void (^RZKeyboardAnimationCompletionBlock)(BOOL finished, BOOL keyboardVisible);

@interface UIViewController (RZKeyboardWatcher)

/**
 *  Adds an observer of the keyboard.  Must make sure to unwatch the keyboard later and if using `self`,
 *  should use a weak reference.
 *
 *  @param animations The animation block to be executed when the keyboard state is changed.
 *  @param animated   If the animation block should be animated or not.
 */
- (void)rz_watchKeyboardShowWithAnimations:(RZKeyboardAnimationBlock)animations animated:(BOOL)animated;

/**
 *  Adds an observer of the keyboard.  Must make sure to unwatch the keyboard later and if using `self`,
 *  should use a weak reference.
 *
 *  @param animations The animation block to be executed when the keyboard state is changed.
 *  @param completion The completion block that gets called after the animation completes.
 *  @param animated   if the animation block should be animated or not.
 */
- (void)rz_watchKeyboardShowWithAnimations:(RZKeyboardAnimationBlock)animations completion:(RZKeyboardAnimationCompletionBlock)completion animated:(BOOL)animated;

/**
 *  Removes the observer of the keyboard.
 */
- (void)rz_unwatchKeyboard;

@end
