//
//  RZDelayedOperation.h
//  SiteSpectSDK
//
//  Created by Nick Donaldson on 1/30/14.
//  Copyright (c) 2014 SiteSpect. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RZDelayedOperationBlock)();

/**
 *   When started, the (concurrent) operation will schedule a timer on the main run loop to execute after a delay.
 *   Returns a reference to an RZDelayedOperation object, which may be used to reset the timer or cancel entirely.
 *   Once cancelled or finished executing, the operation is invalidated and cannot be restarted.
 *
 *   This operation class can be used in a queue, but be aware that it will hold up execution of other operations
 *   in a serial queue. This class was designed to work as a standalone operation:
 *
 *      [operation start]; // starts the execution timer and returns
 */

@interface RZDelayedOperation : NSOperation

/**
*   @param delay The delay time in seconds. Must not be negative.
*   @param block The block to be executed. Must not be nil.
*/
+ (instancetype)operationPerformedAfterDelay:(NSTimeInterval)delay withBlock:(RZDelayedOperationBlock)block;

/**
*   Optionally provide a queue on which the block is to be performed.
*   @param queue Queue on which the block will be performed. Defaults to main queue.
*/
+ (instancetype)operationPerformedAfterDelay:(NSTimeInterval)delay onQueue:(dispatch_queue_t)queue withBlock:(RZDelayedOperationBlock)block;

/** Resets the delay timer to zero and starts counting down again */
- (void)resetTimer;

@end
