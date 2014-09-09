//
//  UIViewController+RZKeyboardWatcher.h
//
//  Created by Joe Mahon on 1/29/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

@import Foundation;

typedef void (^RZKeyboardAnimationBlock)(BOOL keyboardVisible, CGRect keyboardFrame);
typedef void (^RZKeyboardAnimationCompletionBlock)(BOOL finished, BOOL keyboardVisible);

@interface UIViewController (RZKeyboardWatcher)

- (void)rz_watchKeyboardShowWithAnimations:(RZKeyboardAnimationBlock)animations animated:(BOOL)animated;
- (void)rz_watchKeyboardShowWithAnimations:(RZKeyboardAnimationBlock)animations completion:(RZKeyboardAnimationCompletionBlock)completion animated:(BOOL)animated;
- (void)rz_unwatchKeyboard;

@end
