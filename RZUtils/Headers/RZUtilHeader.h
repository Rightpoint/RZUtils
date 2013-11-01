//
//  RZUtilHeader.h
//
//  Created by Nick Donaldson on 10/11/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#ifndef RZUtilHeader_h
#define RZUtilHeader_h

#import <Foundation/Foundation.h>

#define RZNilToEmptyString(x)   (x ? x : @"")
#define RZNilToZeroNumber(x)    (x ? x : @0)
#define RZStringToNumber(x)     ([x isKindOfClass:[NSNumber class]] ? x : ([x isKindOfClass:[NSString class]] ? @([x floatValue]) : nil))
#define RZNumberToString(x)     ([x isKindOfClass:[NSString class]] ? x : ([x isKindOfClass:[NSNumber class]] ? [x stringValue] : nil))

#define RZColorFromRGB(r,g,b)       [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:1.0]
#define RZColorFromRGBA(r,g,b,a)    [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:a/255.f]

// Dispatch to main queue synchronously, regardless of current thread
static inline void rz_dispatch_main_reentrant(void(^block)())
{
    if (block)
    {
        if ([NSThread isMainThread])
        {
            block();
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), block);
        }
    }
}

#endif
