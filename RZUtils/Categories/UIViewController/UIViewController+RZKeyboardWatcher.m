//
//  UIViewController+RZKeyboardWatcher.m
//
//  Created by Joe Mahon on 1/29/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "UIViewController+RZKeyboardWatcher.h"
#import <objc/runtime.h>

static void *kRZKeyboardAnimationsDelegateKey = &kRZKeyboardAnimationsDelegateKey;

@interface RZKeyboardAnimationDelegate : NSObject

@property (copy, nonatomic) RZAnimationBlock animationBlock;
@property (copy, nonatomic) RZAnimationCompletionBlock completionBlock;
@property (weak, nonatomic) UIViewController *viewController;
@property (assign, nonatomic) BOOL animate;

- (instancetype)initWithAnimationBlock:(RZAnimationBlock)animations completion:(RZAnimationCompletionBlock)completion andViewController:(UIViewController *)vc;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)startKeyboardObservers;
- (void)removeKeyboardObservers;

@end

@implementation RZKeyboardAnimationDelegate

- (instancetype)initWithAnimationBlock:(RZAnimationBlock)animations completion:(RZAnimationCompletionBlock)completion andViewController:(UIViewController *)vc
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
                             if ( wSelf.animationBlock ) {
                                 wSelf.animationBlock(keyboardVisible, keyboardFrame);
                                 [wSelf.viewController.view layoutIfNeeded];
                             }
                         }
                         completion:self.completionBlock];
    }
    else {
        if ( self.animationBlock ) {
            self.animationBlock(keyboardVisible, keyboardFrame);
            [self.viewController.view layoutIfNeeded];
            if ( self.completionBlock ) {
                self.completionBlock(YES);
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

- (void)rz_watchKeyboardShowWithAnimations:(RZAnimationBlock)animations animated:(BOOL)animated
{
    [self rz_watchKeyboardShowWithAnimations:animations completion:nil animated:animated];
}

- (void)rz_watchKeyboardShowWithAnimations:(RZAnimationBlock)animations completion:(RZAnimationCompletionBlock)completion animated:(BOOL)animated
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
