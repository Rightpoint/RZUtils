//
//  RZTweenAnimator.m
//  Raizlabs
//
//  Created by Nick D on 1/3/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZTweenAnimator.h"

@interface RZPropertyTween : NSObject

@property (nonatomic, strong) RZTween *tween;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, weak) id object;

@end

@implementation RZPropertyTween
@end

@interface RZTweenAnimator ()

@property (nonatomic, strong) NSMutableDictionary *animatedTweens;

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
        self.animatedTweens = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Adding tweens

- (void)addTween:(RZTween *)tween forKeypath:(NSString *)keyPath ofObject:(id)object
{
    NSParameterAssert(tween);
    NSParameterAssert(keyPath);
    NSParameterAssert(object);

    RZPropertyTween *pt = [RZPropertyTween new];
    pt.tween = tween;
    pt.object = object;
    pt.keyPath = keyPath;
    
    NSString *kpHash = [NSString stringWithFormat:@"%p_%@", object, keyPath];
    [self.animatedTweens setObject:pt forKey:kpHash];
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
    NSArray *allTweens = [self.animatedTweens allValues];
    [allTweens enumerateObjectsUsingBlock:^(RZPropertyTween *pt, NSUInteger idx, BOOL *stop) {
        
        NSValue *value = [pt.tween valueAtTime:self.time];
        if (value != nil)
        {
            [pt.object setValue:value forKeyPath:pt.keyPath];
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
    if ((self.timeScale > 0 && nextTime >= _time) ||
        (self.timeScale < 0 && nextTime <= _time))
    {
        nextTime = _time;
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

