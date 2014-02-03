//
//  UIViewController+RZKeyboardWatcher.h
//
//  Created by Joe Mahon on 1/29/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RZAnimationBlock)(CGRect keyboardFrame);

@interface UIViewController (RZKeyboardWatcher)

- (void)rz_watchKeyboardShowWithAnimations:(RZAnimationBlock)animations animated:(BOOL)animated;
- (void)rz_unwatchKeyboard;

@end
