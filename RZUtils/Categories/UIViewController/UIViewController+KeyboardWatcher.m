//
//  UIViewController+KeyboardWatcher.m
//
//  Created by Joe Mahon on 1/29/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "UIViewController+KeyboardWatcher.h"
#import <objc/runtime.h>

static void *kRZKeyboardAnimationsDelegateKey = &kRZKeyboardAnimationsDelegateKey;

@interface KeyboardShownAnimationDelegate : NSObject

@property (copy, nonatomic) RZAnimationBlock animationBlock;
@property (weak, nonatomic) UIViewController *viewController;
@property (assign, nonatomic) BOOL animate;

- (id)initWithAnimationBlock:(RZAnimationBlock)animations andViewController:(UIViewController *)vc;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)startKeyboardObservers;
- (void)removeKeyboardObservers;

@end

@implementation KeyboardShownAnimationDelegate

- (id)initWithAnimationBlock:(RZAnimationBlock)animations andViewController:(UIViewController *)vc
{
    self = [super init];
    if (self){
        self.animationBlock = animations;
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
    
    if (self.animate)
    {
        UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
        double animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        __weak KeyboardShownAnimationDelegate *wSelf = self;
        [UIView animateWithDuration:animationDuration delay:0.0 options:(animationCurve << 16) animations:^{
            if (wSelf.animationBlock)
            {
                wSelf.animationBlock(keyboardFrame);
                [wSelf.viewController.view layoutIfNeeded];
            }
        } completion:nil];
    }
    else
    {
        if (self.animationBlock)
        {
            self.animationBlock(keyboardFrame);
            [self.viewController.view layoutIfNeeded];
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
    if (animations)
    {
        KeyboardShownAnimationDelegate *animationDelegate = [[KeyboardShownAnimationDelegate alloc] initWithAnimationBlock:animations andViewController:self];
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
    if (object && [object isKindOfClass:[KeyboardShownAnimationDelegate class]]) {
        KeyboardShownAnimationDelegate *delegate = object;
        [delegate removeKeyboardObservers];
    }
    
    // reset associated delegate to nil
    objc_setAssociatedObject(self, kRZKeyboardAnimationsDelegateKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
