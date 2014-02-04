//
//  RZTweenAnimator.h
//  Raizlabs
//
//  Created by Nick D on 1/3/14.

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

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "RZTween.h"

typedef void (^RZTweenAnimatorUpdateBlock)(NSValue *value);

@protocol RZTweenAnimatorDelegate;

@interface RZTweenAnimator : NSObject

/**
 * Add a tween for a particular keyPath on an object. If the data type for the tween does not match the expected
 * type for the keyPath, an exception will likely be raised.
 */
- (void)addTween:(RZTween *)tween forKeyPath:(NSString *)keyPath ofObject:(id)object;

/**
 * Add a tween with a frame update block. Block is called for each update with current tweened value.
 */
- (void)addTween:(RZTween *)tween withUpdateBlock:(RZTweenAnimatorUpdateBlock)frameBlock;

/** 
 * Represents the current position of the animation timeline.
 * Set this to change the timeline position immediately
 */
@property (nonatomic, assign) NSTimeInterval time;

/** Animate to a particular time */
- (void)animateToTime:(NSTimeInterval)time;

/** Animate to a particular time over a different duration */
- (void)animateToTime:(NSTimeInterval)time overDuration:(NSTimeInterval)duration;

@property (nonatomic, weak) id<RZTweenAnimatorDelegate> delegate;

@end

// ------------------------------------------------------------

@protocol RZTweenAnimatorDelegate <NSObject>

@optional
- (void)tweenAnimatorWillBeginAnimating:(RZTweenAnimator *)animator toTime:(NSTimeInterval)time overDuration:(NSTimeInterval)duration;
- (void)tweenAnimatorDidAnimate:(RZTweenAnimator *)animator;
- (void)tweenAnimatorDidFinishAnimating:(RZTweenAnimator *)animator;

@end
