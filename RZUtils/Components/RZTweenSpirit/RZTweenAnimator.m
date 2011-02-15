//
//  RZTweenAnimator.m
//  Raizlabs
//
//  Created by Nick D on 1/3/14.

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

#import "RZTweenAnimator.h"

@interface RZTweenAnimator ()

@property (nonatomic, strong) NSMutableDictionary *tweensToBlocks;

- (void)animateToTime:(NSTimeInterval)time usingScale:(double)timeScale;

// CADisplayLink
@property (nonatomic, strong) CADisplayLink *frameTimer;
@property (nonatomic, assign) NSTimeInterval targetTime;
@property (nonatomic, assign) double timeScale;

- (void)startFrameTimer;
- (void)cancelFrameTimer;
- (void)frameTick:(CADisplayLink *)frameTimer;

- (void)setValuesForCurrentTime;

@end

@implementation RZTweenAnimator

- (id)init
{
    self = [super init];
    if (self)
    {
        self.tweensToBlocks = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Adding tweens

- (void)addTween:(RZTween *)tween forKeyPath:(NSString *)keyPath ofObject:(id)object
{
    __weak __typeof(object) weakObj = object;
    [self addTween:tween withUpdateBlock:^(NSValue *value) {
        [weakObj setValue:value forKeyPath:keyPath];
    }];
}

- (void)addTween:(RZTween *)tween withUpdateBlock:(RZTweenAnimatorUpdateBlock)frameBlock
{
    NSParameterAssert(tween);
    NSParameterAssert(frameBlock);
    
    [self.tweensToBlocks setObject:[frameBlock copy] forKey:tween];
}

#pragma mark - Public animation

- (void)setTime:(NSTimeInterval)time
{
    [self cancelFrameTimer];
    _time = time;
    [self setValuesForCurrentTime];
}

- (void)animateToTime:(NSTimeInterval)time
{
    if ([self.delegate respondsToSelector:@selector(tweenAnimatorWillBeginAnimating:toTime:overDuration:)])
    {
        NSTimeInterval normDuration = time - _time;
        [self.delegate tweenAnimatorWillBeginAnimating:self toTime:time overDuration:fabs(normDuration)];
    }
    
    [self animateToTime:time usingScale:1.0];
}

- (void)animateToTime:(NSTimeInterval)time overDuration:(NSTimeInterval)duration
{
    if (fabs(duration) <= 0.001 || time == _time)
    {
        self.time = time;
    }
    else
    {
        // OK if this is negative - it will step backwards
        NSTimeInterval normDuration = time - _time;
        double scale = normDuration/duration;
     
        if ([self.delegate respondsToSelector:@selector(tweenAnimatorWillBeginAnimating:toTime:overDuration:)])
        {
            [self.delegate tweenAnimatorWillBeginAnimating:self toTime:time overDuration:fabs(normDuration)];
        }
        
        [self animateToTime:time usingScale:scale];
    }
}

#pragma mark - Private

- (void)animateToTime:(NSTimeInterval)time usingScale:(double)timeScale
{
    [self cancelFrameTimer];
    self.targetTime = time;
    self.timeScale = timeScale;
    [self startFrameTimer];
}

- (void)setValuesForCurrentTime
{
    [self.tweensToBlocks enumerateKeysAndObjectsUsingBlock:^(RZTween * tween, RZTweenAnimatorUpdateBlock frameBlock, BOOL *stop) {
        NSValue *value = [tween valueAtTime:self.time];
        if (value != nil)
        {
            frameBlock(value);
        }
    }];
    
    if ([self.delegate respondsToSelector:@selector(tweenAnimatorDidAnimate:)])
    {
        [self.delegate tweenAnimatorDidAnimate:self];
    }
}

#pragma mark - DisplayLink

- (void)startFrameTimer
{
    if (self.frameTimer == nil)
    {
        self.frameTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(frameTick:)];
        [self.frameTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)cancelFrameTimer
{
    if (self.frameTimer != nil)
    {
        [self.frameTimer invalidate];
        self.frameTimer = nil;
        if ([self.delegate respondsToSelector:@selector(tweenAnimatorDidFinishAnimating:)])
        {
            [self.delegate tweenAnimatorDidFinishAnimating:self];
        }
    }
}

- (void)frameTick:(CADisplayLink *)frameTimer
{
    BOOL finished = NO;
    NSTimeInterval nextTime = _time + (frameTimer.duration * self.timeScale);
    if ((self.timeScale > 0 && nextTime >= self.targetTime) ||
        (self.timeScale < 0 && nextTime <= self.targetTime))
    {
        nextTime = self.targetTime;
        finished = YES;
    }
    
    _time = nextTime;
    
    [self setValuesForCurrentTime];
    
    if (finished)
    {
        [self cancelFrameTimer];
    }
}

@end

