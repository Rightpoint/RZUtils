//
//  RZCommonUtils.m
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

#import "RZCommonUtils.h"

#pragma mark - Math Funtions

CGFloat RZClampFloat(CGFloat value, CGFloat min, CGFloat max)
{
    return MIN(max, MAX(value, min));
}

CGFloat RZMapFloat(CGFloat value, CGFloat inMin, CGFloat inMax, CGFloat outMin, CGFloat outMax, BOOL clamp)
{
    CGFloat result = ((value - inMin) / (inMax - inMin)) * (outMax - outMin) + outMin;
    if ( clamp ) {
        result = RZClampFloat(result, MIN(outMin,outMax), MAX(outMin,outMax));
    }
    return result;
}

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#pragma mark - UIKit Helpers

UIViewAnimationOptions RZAnimationOptionFromCurve(UIViewAnimationCurve curve)
{
    UIViewAnimationOptions option = 0;
    switch ( curve )
    {
        case UIViewAnimationCurveEaseIn:
            option = UIViewAnimationOptionCurveEaseIn;
            break;
            
        case UIViewAnimationCurveEaseInOut:
            option = UIViewAnimationOptionCurveEaseInOut;
            break;
            
        case UIViewAnimationCurveEaseOut:
            option = UIViewAnimationOptionCurveEaseOut;
            break;
            
        case UIViewAnimationCurveLinear:
            option = UIViewAnimationOptionCurveLinear;
            break;
            
        default: {
            // This shows up for the keyboard curve in iOS7.
            // As of yet, not documented, but this works...
            // http://stackoverflow.com/questions/18957476/ios-7-keyboard-animation
            if ( (int)curve == 7 ) {
                option = (curve << 16);
            }
        }
            break;
    }
    return option;
}

#endif
