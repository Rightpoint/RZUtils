//
//  RZDelayedOperation.h
//
//  Created by Nick Donaldson on 1/30/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RZDelayedOperationBlock)();

/**
 *   When started, the (concurrent) operation will schedule a timer on the main run loop to execute after a delay.
 *   A reference to an RZDelayedOperation object may be used to reset the delay timer or cancel the operation entirely.
 *   Once cancelled or finished executing, the operation is invalidated and cannot be restarted.
 *
 *	 This class was designed to work as a standalone operation:
 *
 *      [operation start]; // starts the execution timer and returns
 *
 *   However, it can still be used in an operation queue, but be aware that it may hold up execution of other 
 *	 operations in the queue until it is finished.
 */

@interface RZDelayedOperation : NSOperation

/**
*	Creates an operation with a block to be performed on the main queue after a delay.
*
*   @param delay The delay time in seconds. Must not be negative.
*   @param block The block to be executed. Must not be nil.
*/
+ (instancetype)operationPerformedAfterDelay:(NSTimeInterval)delay withBlock:(RZDelayedOperationBlock)block;

/**
*   Optionally provide a dispatch queue on which the block is to be performed.
*   @param queue Queue on which the block will be performed. Must not be nil.
*/
+ (instancetype)operationPerformedAfterDelay:(NSTimeInterval)delay onQueue:(dispatch_queue_t)queue withBlock:(RZDelayedOperationBlock)block;

/** 
*   Resets the delay timer to zero and starts counting down again.
*   Only valid to call before operation has finished.
*/
- (void)resetTimer;

@end
