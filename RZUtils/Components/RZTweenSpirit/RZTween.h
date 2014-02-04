//
//  RZTween.h
//  Raizlabs
//
//  Created by Nick D on 1/3/14.
//  Copyright (c) 2014 Raizlabs. 
//

#import <Foundation/Foundation.h>

/*!
 *  A subclass of RZTween provides a way to interpolate a value of an arbitrary numerical type
 *  between several keyframes. Currently only linear interpolation is supported.
 *  A tween can be used as-is or with RZTweenAnimator.
 */

@interface RZTween : NSObject <NSCopying>

// Returns @0 by default. Should subclass to return appropriate type wrapped in NSValue.
- (NSValue *)valueAtTime:(NSTimeInterval)time;

- (BOOL)isEqualToTween:(RZTween *)tween;

@end

@interface RZFloatTween : RZTween

- (void)addKeyFloat:(CGFloat)keyFloat atTime:(NSTimeInterval)time;

@end

// Obviously can't tween between bool values,
// so this simply returns the most recent boolean keyframe value
@interface RZBooleanTween : RZTween

- (void)addKeyBool:(BOOL)keyBool atTime:(NSTimeInterval)time;

@end

@interface RZTransformTween : RZTween

- (void)addKeyTransform:(CGAffineTransform)transform atTime:(NSTimeInterval)time;

@end

// TODO:
// - Color
// - CGRect
// - Other curves besides linear
