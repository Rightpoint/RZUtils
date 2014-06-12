//
//  UIView+RZAnimation.h
//  UniFirst
//
//  Created by Andrew McKnight on 6/11/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
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

#import <UIKit/UIKit.h>

@interface UIView (RZAnimation)

/**
 *  Perform a UIView animation, with the option to execute the statements inside
 *  the animation block as animated or not.
 *
 *  @param duration   Duration of the animations if animated is YES.
 *  @param delay      Delay before animations start.
 *  @param options    Animation options.
 *  @param animations Block containing operations for optional animation, but always executed.
 *  @param completion Animation completion block, always executed.
 *  @param animated   YES to animate the operations in animations block, NO to perform them immediately.
 */
+ (void)animateWithDuration:(NSTimeInterval)duration
                      delay:(NSTimeInterval)delay
                    options:(UIViewAnimationOptions)options
                 animations:(void (^)(void))animations
                 completion:(void (^)(BOOL))completion
                   animated:(BOOL)animated;

@end
