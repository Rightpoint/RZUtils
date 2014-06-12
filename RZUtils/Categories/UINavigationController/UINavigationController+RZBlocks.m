//
//  UINavigationController+RZBlocks.m
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

#import "UINavigationController+RZBlocks.h"

#import <objc/runtime.h>

static const void * kRZNavigationControllerCompletionBlockKey       = &kRZNavigationControllerCompletionBlockKey;
static const void * kRZNavigationControllerPoppedViewControllersKey = &kRZNavigationControllerPoppedViewControllersKey;
static const void * kRZNavigationControllerPreviousDelegateKey      = &kRZNavigationControllerPreviousDelegateKey;

@implementation UINavigationController (RZBlocks)

#pragma mark - Public

- (void)rz_pushViewController:(UIViewController *)viewController
                     animated:(BOOL)animated
                   completion:(RZNavigationControllerCompletionBlock)completion
{
    [self setupDelegateWithCompletion:completion];
    [self pushViewController:viewController animated:animated];
}

- (void)rz_popViewControllerAnimated:(BOOL)animated
                          completion:(RZNavigationControllerCompletionBlock)completion
{
    [self setupDelegateWithCompletion:completion];
    UIViewController *poppedViewController = [self popViewControllerAnimated:animated];
    objc_setAssociatedObject(self, kRZNavigationControllerPoppedViewControllersKey, poppedViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)rz_popToViewController:(UIViewController *)viewController
                      animated:(BOOL)animated
                    completion:(RZNavigationControllerCompletionBlock)completion
{
    [self setupDelegateWithCompletion:completion];
    NSArray *poppedViewControllers = [self popToViewController:viewController animated:animated];
    objc_setAssociatedObject(self, kRZNavigationControllerPoppedViewControllersKey, poppedViewControllers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)rz_popToRootViewControllerAnimated:(BOOL)animated
                                completion:(RZNavigationControllerCompletionBlock)completion
{
    [self setupDelegateWithCompletion:completion];
    NSArray *poppedViewControllers = [self popToRootViewControllerAnimated:animated];
    objc_setAssociatedObject(self, kRZNavigationControllerPoppedViewControllersKey, poppedViewControllers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)rz_setViewControllers:(NSArray *)viewControllers
                     animated:(BOOL)animated
                   completion:(RZNavigationControllerCompletionBlock)completion
{
    [self setupDelegateWithCompletion:completion];
    [self setViewControllers:viewControllers animated:animated];
}

#pragma mark - Private

- (void)setupDelegateWithCompletion:(RZNavigationControllerCompletionBlock)completion
{
    if (completion != nil)
    {
        if (self.delegate != nil)
        {
            objc_setAssociatedObject(self, kRZNavigationControllerPreviousDelegateKey, self.delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        self.delegate = self;
        objc_setAssociatedObject(self, kRZNavigationControllerCompletionBlockKey, completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    // retrieve stored associated objects
    RZNavigationControllerCompletionBlock completion = objc_getAssociatedObject(self, kRZNavigationControllerCompletionBlockKey);
    id poppedObject = objc_getAssociatedObject(self, kRZNavigationControllerPoppedViewControllersKey);
    id previousDelegate = objc_getAssociatedObject(self, kRZNavigationControllerPreviousDelegateKey);
    
    // set all associated objects for this category to nil
    objc_setAssociatedObject(self, kRZNavigationControllerCompletionBlockKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, kRZNavigationControllerPoppedViewControllersKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, kRZNavigationControllerPreviousDelegateKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    // reset previous delegate, if any
    if (previousDelegate != nil)
    {
        self.delegate = previousDelegate;
    }
    
    // call the completion block
    if (completion != nil)
    {
        NSArray *poppedViewControllers = nil;
        if ([poppedObject isKindOfClass:[NSArray class]])
        {
            poppedViewControllers = poppedObject;
        }
        else if ([poppedObject isKindOfClass:[UIViewController class]])
        {
            poppedViewControllers = @[poppedObject];
        }
        completion(self, poppedViewControllers, viewController);
    }
}

@end
