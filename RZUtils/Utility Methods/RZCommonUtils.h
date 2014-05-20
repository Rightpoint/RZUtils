//
//  RZCommonUtils.h
//
//  Common utility macros and functions serving a broad set of applications.
//
// Created by Nick Donaldson on 10/11/13.
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

#ifndef RZCommonUtils_h
#define RZCommonUtils_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// ===============================================
//               Conversion Macros
// ===============================================

/**
 *  If argument is nil, it will be converted to NSNull.
 */
#define RZNilToNSNull(x) (x ? x : [NSNull null])

/**
 *  If argument is NSNull, it will be converted to nil.
 */
#define RZNSNullToNil(x) ([x isEqual:[NSNull null]] ? nil : x)

/**
 *  If argument is nil, it will be converted to an empty string
 */
#define RZNilToEmptyString(x) (x ? x : @"")

/**
 *  If argument is nil, it will be converted to @0
 */
#define RZNilToZeroNumber(x) (x ? x : @0)

/**
 *  If argument is an NSString, it will be converted to its NSNumber equivalent.
 */
#define RZStringToNumber(x) \
    (NSNumber *)([x isKindOfClass:[NSNumber class]] ? x : ([x isKindOfClass:[NSString class]] ? @([x floatValue]) : nil))

/**
 *  If argument is an NSNumber, it will be converted to its NSString equivalent.
 */
#define RZNumberToString(x) \
    (NSString *)([x isKindOfClass:[NSString class]] ? x : ([x isKindOfClass:[NSNumber class]] ? [x stringValue] : nil))


// ===============================================
//            Color Conversion Macros
// ===============================================

/**
 *  Convert 8-bit rgb values (0-255) to a UIColor
 *
 *  @param r Red value
 *  @param g Green value
 *  @param b Blue Value
 *
 *  @return A new UIColor built from the provided values.
 */
#define RZColorFromRGB(r,g,b) [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:1.0]

/**
 *  Convert 8-bit rgba values (0-255) to a UIColor
 *
 *  @param r Red value
 *  @param g Green value
 *  @param b Blue value
 *  @param a Alpha value
 *
 *  @return A new UIColor built from the provided values.
 */
#define RZColorFromRGBA(r,g,b,a) [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:a/255.f]

// ===============================================
//                    Math
// ===============================================

/**
 *  Clamp a floating point number so it lies within a min and max.
 *  Values greater than max or less than min are "clipped" to max or min, respectively.
 *
 *  @param value Value to clamp
 *  @param min   Minimum output value
 *  @param max   Maximum output value
 *
 *  @return The clamped value
 */
OBJC_EXTERN CGFloat RZClampFloat(CGFloat value,
                                 CGFloat min,
                                 CGFloat max);

/**
 *  Linearly map a floating point number to a different range, optionally clamping the output.
 *  
 *  For example, mapping 0.5 from (0.0, 1.0) to (10.0, 20.0) will yield 15.0.
 *
 *  @param value  The value to map
 *  @param inMin  The minimum value of the input range
 *  @param inMax  The maximum value of the input range
 *  @param outMin The minimum value of the output range
 *  @param outMax The maximum value of the output range
 *  @param clamp  When YES, the output will be clamped to the output range
 *
 *  @return The mapped value in the new range
 */
OBJC_EXTERN CGFloat RZMapFloat(CGFloat value,
                               CGFloat inMin,
                               CGFloat inMax,
                               CGFloat outMin,
                               CGFloat outMax,
                               BOOL clamp);


// ===============================================
//                UIKit Helpers
// ===============================================

/**
 *  Convert a UIViewAnimationCurve to the corresponding UIViewAnimationOption.
 *  Correctly handles the undefined keyboard animation curve in iOS7.
 *
 *  @param curve The curve to convert to an option
 *
 *  @return The converted UIViewAnimationOptions
 */
OBJC_EXTERN UIViewAnimationOptions RZAnimationOptionFromCurve(UIViewAnimationCurve curve);

#endif
