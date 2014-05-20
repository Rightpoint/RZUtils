//
//  RZDispatch.h
//
//  Utility extensions for libdispatch
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

// This file contains inline functions and macros for working with grand central dispatch.

#ifndef RZDispatch_h
#define RZDispatch_h

#import <Foundation/Foundation.h>

/**
 *  Convenience method to dispatch_async on the main queue.
 *
 *  @param block Block to perform on main queue
 */
OBJC_EXTERN void rz_dispatch_async_main(void(^block)());

/**
 *  Dispatch to main queue synchronously, regardless of current thread.
 *
 *  @param block Block to perform on main queue
 */
OBJC_EXTERN void rz_dispatch_main_reentrant(void(^block)());

#endif
