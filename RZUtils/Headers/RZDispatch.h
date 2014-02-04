//
//  RZDispatch.h
//
//  Created by Nick Donaldson on 10/11/13.
//  Copyright (c) 2013 Raizlabs. 
//

// This file contains inline functions and macros for working with grand central dispatch.

#ifndef RZDispatch_h
#define RZDispatch_h


#import <Foundation/Foundation.h>

// Dispatch to main queue synchronously, regardless of current thread.
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
