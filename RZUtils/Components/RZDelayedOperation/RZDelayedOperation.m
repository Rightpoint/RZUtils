//
//  RZDelayedOperation.m
//
//  Created by Nick Donaldson on 1/30/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZDelayedOperation.h"

typedef NS_ENUM(NSInteger, RZDelayedOperationState)
{
    RZDelayedOperationStateReady = 1,
    RZDelayedOperationStateExecuting = 2,
    RZDelayedOperationStateFinished = 3
};

@interface RZDelayedOperation ()

@property (nonatomic, assign) RZDelayedOperationState state;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) RZDelayedOperationBlock block;
@property (nonatomic, strong) dispatch_queue_t blockQueue;
@property (nonatomic, assign) NSTimeInterval delay;

- (void)startTimer;
- (void)invalidateTimer;
- (void)timerFired:(NSTimer*)timer;

- (void)finish;

@end

@implementation RZDelayedOperation

+ (instancetype)operationPerformedAfterDelay:(NSTimeInterval)delay withBlock:(RZDelayedOperationBlock)block
{
    return [[self class] operationPerformedAfterDelay:delay onQueue:dispatch_get_main_queue() withBlock:block];
}

+ (instancetype)operationPerformedAfterDelay:(NSTimeInterval)delay onQueue:(dispatch_queue_t)queue withBlock:(RZDelayedOperationBlock)block
{
    NSParameterAssert(block);
    NSParameterAssert(queue);
    NSAssert(delay >= 0, @"Delay must be positive");
    
    RZDelayedOperation *delayedOp = [[RZDelayedOperation alloc] init];
    delayedOp.block = block;
    delayedOp.blockQueue = queue;
    delayedOp.delay = delay;
    return delayedOp;
}

- (id)init
{
    self = [super init];
    if (self) {
        _state = RZDelayedOperationStateReady;
    }
    return self;
}

- (void)dealloc
{
    [self cancel];
}

- (void)resetTimer
{
    if ([self isExecuting])
    {
        [self invalidateTimer];
        [self startTimer];
    }
    else
    {
        // Exception seems a little harsh here, so just log a warning.
        NSLog(@"[RZDelayedOperation]: WARNING - Cannot reset timer on finished or cancelled operaion");
    }
}

- (void)startTimer
{
    self.timer = [NSTimer timerWithTimeInterval:self.delay target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)invalidateTimer
{
    // Must invalidate on main thread
    if (self.timer != nil)
    {
        if ([NSThread isMainThread])
        {
            [self.timer invalidate];
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.timer invalidate];
            });
        }
    }
    
    self.timer = nil;
}

- (void)timerFired:(NSTimer *)timer
{
    dispatch_async(self.blockQueue, ^{
        
        if ( !self.isCancelled ) {
            
            self.block();
            
            if ( [NSThread isMainThread] ) {
                [self invalidateTimer];
                [self finish];
            }
            else {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self invalidateTimer];
                    [self finish];
                });
            }
        }
    });
}

#pragma mark - NSOperation

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isReady
{
    return ([super isReady] && self.block != nil && self.state == RZDelayedOperationStateReady);
}

- (BOOL)isExecuting
{
    return (self.state == RZDelayedOperationStateExecuting);
}

- (BOOL)isFinished
{
    return (self.state == RZDelayedOperationStateFinished);
}

- (void)start
{
    if ([self isReady] && ![self isCancelled])
    {
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isReady"];
        self.state = RZDelayedOperationStateExecuting;
        [self didChangeValueForKey:@"isReady"];
        [self didChangeValueForKey:@"isExecuting"];
        
        [self startTimer];
    }
}

- (void)finish
{
    self.block = nil;
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    self.state = RZDelayedOperationStateFinished;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)cancel
{
    if (![self isFinished] && ![self isCancelled]) {
        [super cancel];
        [self invalidateTimer];
        [self finish];
    }
}


@end
