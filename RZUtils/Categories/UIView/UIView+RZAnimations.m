//
//  UIView+RZAnimations.m
//  Raizlabs
//
//  Created by Alex Rouse on 11/25/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "UIView+RZAnimations.h"

@implementation UIView (RZAnimations)


+ (void)animateWithDuration:(NSTimeInterval)duration
                      delay:(NSTimeInterval)delay
                    options:(UIViewAnimationOptions)options
                 animations:(void (^)(void))animations
                 completion:(void (^)(BOOL finished))completion
              shouldAnimate:(BOOL)shouldAnimate
{
    if (shouldAnimate)
    {
        [UIView animateWithDuration:duration delay:delay options:options animations:animations completion:completion];
    }
    else
    {
        if (animations)
        {
            animations();
        }
        if (completion)
        {
            completion(YES);
        }
    }
}
@end
