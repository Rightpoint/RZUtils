//
//  RZUtilityMacros.h
//
//  Created by Nick Donaldson on 10/11/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

//  This file contains macros for quick conversions and whatnot.

#ifndef RZUtilityMacros_h
#define RZUtilityMacros_h

#import <Foundation/Foundation.h>

#define RZNilToEmptyString(x)   (x ? x : @"")
#define RZNilToZeroNumber(x)    (x ? x : @0)
#define RZStringToNumber(x)     ([x isKindOfClass:[NSNumber class]] ? x : ([x isKindOfClass:[NSString class]] ? @([x floatValue]) : nil))
#define RZNumberToString(x)     ([x isKindOfClass:[NSString class]] ? x : ([x isKindOfClass:[NSNumber class]] ? [x stringValue] : nil))

#define RZColorFromRGB(r,g,b)       [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:1.0]
#define RZColorFromRGBA(r,g,b,a)    [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:a/255.f]


#endif
