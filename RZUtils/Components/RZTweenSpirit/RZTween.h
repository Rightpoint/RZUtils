//
//  RZTween.h
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

@import Foundation;

/*!
 *  A subclass of RZTween provides a way to interpolate a value of an arbitrary numerical type
 *  between several keyframes. Currently only linear interpolation is supported.
 *  A tween can be used as-is or with RZTweenAnimator.
 */


/**
 *  Different animation curves that are supported by the tween.
 */
typedef NS_ENUM(u_int8_t, RZTweenCurveType)
{
    /**
     *  y = x
     */
    RZTweenCurveTypeLinear,
    /**
     *  y = x^2
     */
    RZTweenCurveTypeQuadraticEaseIn,
    /**
     *  y = -(x * (x-2))
     */
    RZTweenCurveTypeQuadraticEaseOut,
    /**
     *  see RZTweenQuadraticEaseInOut for description.
     */
    RZTweenCurveTypeQuadraticEaseInOut,
    /**
     *  y = sin(π/2 * (x-1))
     */
    RZTweenCurveTypeSineEaseIn,
    /**
     *  y = sin(π/2 * x)
     */
    RZTweenCurveTypeSineEaseOut,
    /**
     *  y = (1 - cos(π * x))/2
     */
    RZTweenCurveTypeSineEaseInOut
};

@interface RZTween : NSObject <NSCopying>

/**
 *  The animation curve type to use for a paticular tween
 */
@property (nonatomic, assign) RZTweenCurveType curveType;

// TODO: remove the requirement for NSValue to support objects (UIColor)
/**
 *  Returns @0 by default.  Should subclass to return appropriate type wrapped in NSValue
 *
 *  @param time animation offset
 *
 *  @return value for KVC.
 */
- (NSValue *)valueAtTime:(NSTimeInterval)time;

- (BOOL)isEqualToTween:(RZTween *)tween;

@end

@interface RZFloatTween : RZTween

- (void)addKeyFloat:(CGFloat)keyFloat atTime:(NSTimeInterval)time;

@end

/**
 *  Obviously can't tween between bool values,
 *  so this simply returns the most recent boolean keyframe value.
 */
@interface RZBooleanTween : RZTween

- (void)addKeyBool:(BOOL)keyBool atTime:(NSTimeInterval)time;

@end

// TODO:  may need to look into a bug with rotation transforms.
@interface RZTransformTween : RZTween

- (void)addKeyTransform:(CGAffineTransform)transform atTime:(NSTimeInterval)time;

@end

@interface RZRectTween : RZTween

- (void)addKeyRect:(CGRect)rect atTime:(NSTimeInterval)time;

@end

@interface RZPointTween : RZTween

- (void)addKeyPoint:(CGPoint)point atTime:(NSTimeInterval)time;

@end

// TODO:
// - Color
// - Bounce Curves.
