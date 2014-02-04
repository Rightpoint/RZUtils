//
//  RZUtilityMacros.h
//
//  Created by Nick Donaldson on 10/11/13.
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

//  This file contains macros for quick conversions and whatnot.

#ifndef RZUtilityMacros_h
#define RZUtilityMacros_h

#import <Foundation/Foundation.h>

#define RZNilToNSNull(x)        (x ? x : [NSNull null])
#define RZNSNullToNil(x)        ([x isEqual:[NSNull null]] ? nil : x)

#define RZNilToEmptyString(x)   (x ? x : @"")
#define RZNilToZeroNumber(x)    (x ? x : @0)
#define RZStringToNumber(x)     (NSNumber *)([x isKindOfClass:[NSNumber class]] ? x : ([x isKindOfClass:[NSString class]] ? @([x floatValue]) : nil))
#define RZNumberToString(x)     (NSString *)([x isKindOfClass:[NSString class]] ? x : ([x isKindOfClass:[NSNumber class]] ? [x stringValue] : nil))

#define RZColorFromRGB(r,g,b)       [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:1.0]
#define RZColorFromRGBA(r,g,b,a)    [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:a/255.f]

// Clamp a float within a range
inline static float RZClampFloat(float value, float min, float max)
{
    return MIN(max, MAX(value, min));
}

// Map a float to a different range
inline static float RZMapFloat(float value, float inMin, float inMax, float outMin, float outMax, BOOL clamp)
{
    float result = ((value - inMin)/(inMax - inMin)) * (outMax - outMin) + outMin;
    if (clamp)
    {
        result = RZClampFloat(result, MIN(outMin,outMax), MAX(outMin,outMax));
    }
    return result;
}

#endif
