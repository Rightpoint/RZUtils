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

static const void * kRZNavigationControllerCompletionBlockHelperKey = &kRZNavigationControllerCompletionBlockHelperKey;

@interface RZUINavigationControllerCompletionBlockHelper : NSObject <UINavigationControllerDelegate>

@property (copy, nonatomic) RZNavigationControllerCompletionBlock completionBlock;
@property (copy, nonatomic) RZNavigationControllerPreparationBlock preparationBlock;
@property (strong, nonatomic) NSArray *poppedViewControllers;
@property (weak, nonatomic) id<UINavigationControllerDelegate> previousDelegate;

@end

@implementation RZUINavigationControllerCompletionBlockHelper

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    if ( self.preparationBlock != nil ) {
        RZNavigationControllerPreparationBlock preparation = self.preparationBlock;
        self.preparationBlock = nil;
        preparation(navigationController, viewController);
    }
    
    if ( [self.previousDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)] ) {
        [self.previousDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    // call previous delegate's callback implementation, if any
    if ( [self.previousDelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)] ) {
        [self.previousDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
    
    // reset the delegates to the way they were before calling the block-based method
    navigationController.delegate = self.previousDelegate;
    self.previousDelegate = nil;
    
    // call the completion block
    if ( self.completionBlock != nil ) {
        RZNavigationControllerCompletionBlock completion = self.completionBlock;
        self.completionBlock = nil;
        completion(navigationController, viewController, self.poppedViewControllers);
    }
    
    objc_setAssociatedObject(self, kRZNavigationControllerCompletionBlockHelperKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UINavigationController (RZBlocks)

#pragma mark - Private

- (RZUINavigationControllerCompletionBlockHelper *)rz_setupDelegateWithPreparation:(RZNavigationControllerPreparationBlock)preparation completion:(RZNavigationControllerCompletionBlock)completion
{
    RZUINavigationControllerCompletionBlockHelper *helper = [[RZUINavigationControllerCompletionBlockHelper alloc] init];
    if ( completion != nil || preparation != nil ) {
        helper.previousDelegate = self.delegate;
        self.delegate = helper;
        helper.preparationBlock = preparation;
        helper.completionBlock = completion;
    }
    
    objc_setAssociatedObject(self, kRZNavigationControllerCompletionBlockHelperKey, helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return helper;
}

#pragma mark - Public

- (void)rz_pushViewController:(UIViewController *)viewController
                     animated:(BOOL)animated
                  preparation:(RZNavigationControllerPreparationBlock)preparation
                   completion:(RZNavigationControllerCompletionBlock)completion
{
    [self rz_setupDelegateWithPreparation:preparation completion:completion];
    [self pushViewController:viewController animated:animated];
}

- (void)rz_popViewControllerAnimated:(BOOL)animated
                         preparation:(RZNavigationControllerPreparationBlock)preparation
                          completion:(RZNavigationControllerCompletionBlock)completion
{
    RZUINavigationControllerCompletionBlockHelper *helper = [self rz_setupDelegateWithPreparation:preparation completion:completion];
    UIViewController *poppedViewController = [self popViewControllerAnimated:animated];
    helper.poppedViewControllers = @[poppedViewController];
}

- (void)rz_popToViewController:(UIViewController *)viewController
                      animated:(BOOL)animated
                   preparation:(RZNavigationControllerPreparationBlock)preparation
                    completion:(RZNavigationControllerCompletionBlock)completion
{
    RZUINavigationControllerCompletionBlockHelper *helper = [self rz_setupDelegateWithPreparation:preparation completion:completion];
    NSArray *poppedViewControllers = [self popToViewController:viewController animated:animated];
    helper.poppedViewControllers = poppedViewControllers;
}

- (void)rz_popToRootViewControllerAnimated:(BOOL)animated
                               preparation:(RZNavigationControllerPreparationBlock)preparation
                                completion:(RZNavigationControllerCompletionBlock)completion
{
    RZUINavigationControllerCompletionBlockHelper *helper = [self rz_setupDelegateWithPreparation:preparation completion:completion];
    NSArray *poppedViewControllers = [self popToRootViewControllerAnimated:animated];
    helper.poppedViewControllers = poppedViewControllers;
}

- (void)rz_setViewControllers:(NSArray *)viewControllers
                     animated:(BOOL)animated
                  preparation:(RZNavigationControllerPreparationBlock)preparation
                   completion:(RZNavigationControllerCompletionBlock)completion
{
    [self rz_setupDelegateWithPreparation:preparation completion:completion];
    [self setViewControllers:viewControllers animated:animated];
}

@end
