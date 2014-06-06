//
//  RZWaiter.h
//  RZUtils
//
//  Created by Nick Bonatsakis on 06/19/2013.
//  Copyright (c) 2014 RaizLabs. All rights reserved.
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
 *  Create a new instance of the waiter.
 *
 *  @return The new instance.
 */
+ (instancetype)waiter;

/**
 *  Wait for the given timeout, polling every N time interval. While waiting, the main runloop continues to run.
 *
 *  @param timeout         Overall timeout in sec.
 *  @param pollingInterval Interval at which to poll in sec.
 *  @param conditionBlock  Evaluated condition to determine if expected condition has been satisfied. (required parameter)
 *  @param timeoutBlock    Executed when the "wait" period is exceeded (timeout). This is usually a good place to call XCTFail() (required parameter)
 */
- (void)waitWithTimeout:(NSTimeInterval)timeout
           pollInterval:(NSTimeInterval)pollingInterval
         checkCondition:(RZWaiterPollBlock)conditionBlock
              onTimeout:(RZWaiterTimeout)timeoutBlock;

@end
