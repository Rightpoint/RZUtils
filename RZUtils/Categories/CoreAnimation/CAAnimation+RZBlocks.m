//
//  CAAnimation+RZBlocks.m
//  Raizlabs
//
//  Created by Nick Donaldson on 12/6/13.

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


