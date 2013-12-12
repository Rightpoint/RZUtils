//
//  CAAnimation+RZBlocks.m
//  VirginPulse
//
//  Created by Nick Donaldson on 12/6/13.
//  Copyright (c) 2013 Virgin. All rights reserved.
//

#import "CAAnimation+RZBlocks.h"

@interface RZCAAnimationBlockDelegate : NSObject

@property (nonatomic, copy) RZAnimationDidStartBlock startBlock;
@property (nonatomic, copy) RZAnimationDidStopBlock stopBlock;

@end

@implementation RZCAAnimationBlockDelegate

- (void)animationDidStart:(CAAnimation *)anim
{
    if (self.startBlock)
    {
        self.startBlock();
        self.startBlock = nil;
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.stopBlock)
    {
        self.stopBlock(flag);
        self.stopBlock = nil;
    }
}

@end

// -----

@implementation CAAnimation (RZBlocks)

- (void)rz_setAnimationDidStartBlock:(RZAnimationDidStartBlock)startBlock
{
    id delegate = self.delegate;
    if (delegate != nil && [delegate isKindOfClass:[RZCAAnimationBlockDelegate class]])
    {
        RZCAAnimationBlockDelegate *blockDelegate = delegate;
        [blockDelegate setStartBlock:startBlock];
    }
    else if (startBlock != nil)
    {
        RZCAAnimationBlockDelegate *blockDelegate = [RZCAAnimationBlockDelegate new];
        [blockDelegate setStartBlock:startBlock];
        self.delegate = blockDelegate;
    }
}

- (void)rz_setAnimationDidStopBlock:(RZAnimationDidStopBlock)stopBlock
{
    id delegate = self.delegate;
    if (delegate != nil && [delegate isKindOfClass:[RZCAAnimationBlockDelegate class]])
    {
        RZCAAnimationBlockDelegate *blockDelegate = delegate;
        [blockDelegate setStopBlock:stopBlock];
    }
    else if (stopBlock != nil)
    {
        RZCAAnimationBlockDelegate *blockDelegate = [RZCAAnimationBlockDelegate new];
        [blockDelegate setStopBlock:stopBlock];
        self.delegate = blockDelegate;
    }
}


@end


