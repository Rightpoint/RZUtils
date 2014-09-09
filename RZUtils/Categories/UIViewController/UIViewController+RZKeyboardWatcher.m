//
//  UIViewController+RZKeyboardWatcher.m
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

#import "UIViewController+RZKeyboardWatcher.h"
@import ObjectiveC.runtime;

static void *kRZKeyboardAnimationsDelegateKey = &kRZKeyboardAnimationsDelegateKey;

@interface RZKeyboardAnimationDelegate : NSObject

@property (copy, nonatomic) RZKeyboardAnimationBlock animationBlock;
@property (copy, nonatomic) RZKeyboardAnimationCompletionBlock completionBlock;
@property (weak, nonatomic) UIViewController *viewController;
@property (assign, nonatomic) BOOL animate;

- (instancetype)initWithAnimationBlock:(RZKeyboardAnimationBlock)animations completion:(RZKeyboardAnimationCompletionBlock)completion andViewController:(UIViewController *)vc;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)startKeyboardObservers;
- (void)removeKeyboardObservers;

@end

@implementation RZKeyboardAnimationDelegate

- (instancetype)initWithAnimationBlock:(RZKeyboardAnimationBlock)animations completion:(RZKeyboardAnimationCompletionBlock)completion andViewController:(UIViewController *)vc
{
    self = [super init];
    if ( self != nil ) {
        self.animationBlock = animations;
        self.completionBlock = completion;
        self.viewController = vc;
    }
    return self;
}

- (void)startKeyboardObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self updateFromNotification:notification];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self updateFromNotification:notification];
}

- (void)updateFromNotification:(NSNotification *)notification
{
    // Use the animation curve provided by the keyboard notification
    NSDictionary *userInfo = notification.userInfo;
    
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    BOOL keyboardVisible = [notification.name isEqualToString:UIKeyboardWillShowNotification];
    if ( self.animate ) {
        UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
        double animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        __weak RZKeyboardAnimationDelegate *wSelf = self;
        [UIView animateWithDuration:animationDuration
                              delay:0.0
                            options:( animationCurve << 16 )
                         animations:^{
                             if ( wSelf.animationBlock != nil ) {
                                 wSelf.animationBlock(keyboardVisible, keyboardFrame);
                                 [wSelf.viewController.view layoutIfNeeded];
                             }
                         }
                         completion:^(BOOL finished) {
                             if ( self.completionBlock != nil ) {
                                 self.completionBlock(finished, keyboardVisible);
                             }
                         }];
    }
    else {
        if ( self.animationBlock != nil ) {
            self.animationBlock(keyboardVisible, keyboardFrame);
            [self.viewController.view layoutIfNeeded];
            if ( self.completionBlock != nil ) {
                self.completionBlock(YES,keyboardVisible);
            }
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


@implementation UIViewController (KeyboardWatcher)

- (void)rz_watchKeyboardShowWithAnimations:(RZKeyboardAnimationBlock)animations animated:(BOOL)animated
{
    [self rz_watchKeyboardShowWithAnimations:animations completion:nil animated:animated];
}

- (void)rz_watchKeyboardShowWithAnimations:(RZKeyboardAnimationBlock)animations completion:(RZKeyboardAnimationCompletionBlock)completion animated:(BOOL)animated
{
    if ( animations ) {
        RZKeyboardAnimationDelegate *animationDelegate = [[RZKeyboardAnimationDelegate alloc] initWithAnimationBlock:animations completion:completion andViewController:self];
        animationDelegate.animate = animated;
        [animationDelegate startKeyboardObservers];
        // save animations block
        objc_setAssociatedObject(self, kRZKeyboardAnimationsDelegateKey, animationDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)rz_unwatchKeyboard
{
    // if we have a delegate, make sure it's not watching for keyboard notifications
    id object = objc_getAssociatedObject(self, kRZKeyboardAnimationsDelegateKey);
    if ( object && [object isKindOfClass:[RZKeyboardAnimationDelegate class]] ) {
        RZKeyboardAnimationDelegate *delegate = object;
        [delegate removeKeyboardObservers];
    }
    
    // reset associated delegate to nil
    objc_setAssociatedObject(self, kRZKeyboardAnimationsDelegateKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
