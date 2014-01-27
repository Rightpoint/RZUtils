//
//  RZTweenAnimator.h
//  Raizlabs
//
//  Created by Nick D on 1/3/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
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
