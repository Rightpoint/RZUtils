//
//  CAAnimation+RZBlocks.h
//  VirginPulse
//
//  Created by Nick Donaldson on 12/6/13.
//  Copyright (c) 2013 Virgin. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

// NOTE: Do NOT set the delegate of the animation after setting a block, or the
// block will not fire.

typedef void (^RZAnimationDidStartBlock)();
typedef void (^RZAnimationDidStopBlock)(BOOL finished);

@interface CAAnimation (RZBlocks)

- (void)rz_setAnimationDidStartBlock:(RZAnimationDidStartBlock)startBlock;
- (void)rz_setAnimationDidStopBlock:(RZAnimationDidStopBlock)stopBlock;

@end
