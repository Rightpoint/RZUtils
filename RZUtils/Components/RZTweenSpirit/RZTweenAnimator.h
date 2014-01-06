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

@protocol RZTweenAnimatorDelegate;

@interface RZTweenAnimator : NSObject

// Add a tween for a particular object and keypath.
// If multiple tweens exist for the same object with overlapping intervals, the one that started first wins.
- (void)addTween:(RZTween *)tween forKeypath:(NSString *)keyPath ofObject:(id)object;

// set this to change the timeline position immediately
@property (nonatomic, assign) NSTimeInterval time;

// These are still in-development

//// Animate to a particular time
//- (void)animateToTime:(NSTimeInterval)time;
//
//// Animate to a particular time over a different duration
//- (void)animateToTime:(NSTimeInterval)time overDuration:(NSTimeInterval)duration;

@property (nonatomic, weak) id<RZTweenAnimatorDelegate> delegate;

@end

// ------------------------------------------------------------

@protocol RZTweenAnimatorDelegate <NSObject>

@optional
- (void)tweenAnimatorWillBeginAnimating:(RZTweenAnimator *)animator toTime:(NSTimeInterval)time overDuration:(NSTimeInterval)duration;
- (void)tweenAnimatorDidAnimate:(RZTweenAnimator *)animator;
- (void)tweenAnimatorDidFinishAnimating:(RZTweenAnimator *)animator;

@end
