//
//  RZWaiter.h
//  RZUtils
//
//  Created by Nick Bonatsakis on 06/19/2013.
//  Copyright (c) 2014 RaizLabs. All rights reserved.
//
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

typedef BOOL (^RZWaiterPollBlock)(void);
typedef void (^RZWaiterTimeout)(void);


/**
 *  The Waiter: a utility for aiding in testing asynchronous operations. Enables a test to
 *  wait while the main runloop continues, until a supplied condition evaluates to true or the timeout
 *  period is exceeded. 
 *  WARNING: This utility is intended for use in tests ONLY. If you use it in shipped project code, I will find you and smack you.
 */
@interface RZWaiter : NSObject

/**
 *  Wait for the given timeout, polling every N time interval. While waiting, the main runloop continues to run.
 *
 *  @param timeout         Overall timeout in sec.
 *  @param pollingInterval Interval at which to poll in sec.
 *  @param conditionBlock  Evaluated condition to determine if expected condition has been satisfied. (required parameter)
 *  @param timeoutBlock    Executed when the "wait" period is exceeded (timeout). This is usually a good place to call XCTFail() (required parameter)
 */
+ (void)waitWithTimeout:(NSTimeInterval)timeout
           pollInterval:(NSTimeInterval)pollingInterval
         checkCondition:(RZWaiterPollBlock)conditionBlock
              onTimeout:(RZWaiterTimeout)timeoutBlock;

@end
