//
//  UIView+RZAnimations.h
//  Raizlabs
//
//  Created by Alex Rouse on 11/25/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (RZAnimations)

// Adds a BOOL parameter to control if we should animate or just execute the blocks.
// Good for cases like - (void)showViewAnimated:(BOOL)animated
+ (void)animateWithDuration:(NSTimeInterval)duration
                      delay:(NSTimeInterval)delay
                    options:(UIViewAnimationOptions)options
                 animations:(void (^)(void))animations
                 completion:(void (^)(BOOL finished))completion
              shouldAnimate:(BOOL)shouldAnimate;

@end
