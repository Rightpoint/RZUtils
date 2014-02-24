//
//  RZViewControllerTransitioningContext.m
//  Raizlabs
//
//  Created by Alex Rouse on 11/5/13.
//

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

#import "RZViewControllerTransitioningContext.h"

@interface RZViewControllerTransitioningContext ()

@property (nonatomic, strong) NSDictionary* viewControllerKeys;
@property (nonatomic, strong) UIView* contentContainerView;

@end

@implementation RZViewControllerTransitioningContext

- (instancetype)initWithFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC containerView:(UIView *)containerView
{
    self = [super init];
    if (self)
    {
        NSAssert(fromVC != nil, @"A from ViewController is Required");
        NSAssert(toVC != nil, @"A to ViewController is Required");
        NSAssert(containerView != nil, @"A Container view is requires for any transitions");
        self.viewControllerKeys = @{UITransitionContextFromViewControllerKey: fromVC,
                                    UITransitionContextToViewControllerKey: toVC};
        self.contentContainerView = containerView;
        self.animated = YES;
    }
    return self;
}

- (UIViewController *)viewControllerForKey:(NSString *)key
{
    return [self.viewControllerKeys objectForKey:key];
}

- (UIView *)containerView
{
    return self.contentContainerView;
}

- (void)completeTransition:(BOOL)didComplete
{
    UIViewController* newVC = [self viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* oldVC = [self viewControllerForKey:UITransitionContextFromViewControllerKey];
    [oldVC.view removeFromSuperview];
    [oldVC removeFromParentViewController];
    
    if (self.parentViewController != nil)
    {
        [newVC didMoveToParentViewController:self.parentViewController];
    }
    
    if (self.completionBlock)
    {
        self.completionBlock(didComplete, self);
    }
}

// Currently interactiveTransitions are not supported.
- (void)updateInteractiveTransition:(CGFloat)percentComplete {}
- (void)finishInteractiveTransition {}
- (void)cancelInteractiveTransition {}
- (BOOL)isInteractive
{
    return NO;
}

- (BOOL)isAnimated
{
    return self.animated;
}

// Currently Not implemented.  Will ALways return NO.
- (BOOL)transitionWasCancelled
{
    return NO;
}

// Currently Not implemented.  Will always return UIModalPresentationCustom.
- (UIModalPresentationStyle)presentationStyle
{
    return UIModalPresentationCustom;
}

// For now we will just set this to the bounds.  Doing this means that any animations have to happen with a transform.
- (CGRect)initialFrameForViewController:(UIViewController *)vc
{
    return self.contentContainerView.bounds;
}
- (CGRect)finalFrameForViewController:(UIViewController *)vc
{
    return self.contentContainerView.bounds;
}

@end
