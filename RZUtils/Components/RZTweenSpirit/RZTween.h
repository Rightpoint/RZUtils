//
//  RZTween.h
//  VirginPulse
//
//  Created by Nick D on 1/3/14.
//  Copyright (c) 2014 Virgin. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  A subclass of RZTween provides a way to interpolate a value of an arbitrary numerical type
 *  between several keyframes. Currently only linear interpolation is supported.
 *  A tween can be used as-is or with RZTweenAnimator.
 */

@interface RZTween : NSObject

// Returns @0 by default. Should subclass to return appropriate type wrapped in NSValue.
- (NSValue *)valueAtTime:(NSTimeInterval)time;

@end

@interface RZFloatTween : RZTween

- (void)addKeyFloat:(CGFloat)keyFloat atTime:(NSTimeInterval)time;

@end

//@interface RZCGAffineTransformTween : NSObject <RZTween>
//
//@end

//@interface RZRectTween : NSObject <RZTween>
//
//+ (instancetype)tweenWithStartTime:(NSTimeInterval)startTime
//                         startRect:(CGRect)startRect
//                           endTime:(NSTimeInterval)endTime
//                           endRect:(CGRect)endRect;
//
//@end
//
//@interface RZScaleTransformTween : NSObject <RZTween>
//
//+ (instancetype)tweenWithStartTime:(NSTimeInterval)startTime
//                        startScale:(CGSize)startScale
//                           endTime:(NSTimeInterval)endTime
//                          endScale:(CGSize)endScale;
//@end


// TODO - Color, rotation transform, whatever else
