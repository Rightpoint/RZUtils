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
