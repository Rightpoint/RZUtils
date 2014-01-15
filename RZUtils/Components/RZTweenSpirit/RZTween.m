//
//  RZTween.m
//  Raizlabs
//
//  Created by Nick D on 1/3/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZTween.h"

static float RZTweenClampFloat(float value, float min, float max)
{
    return MIN(max, MAX(value, min));
}

static float RZTweenMapFloat(float value, float inMin, float inMax, float outMin, float outMax, BOOL clamp)
{
    float result = ((value - inMin)/(inMax - inMin)) * (outMax - outMin) + outMin;
    if (clamp)
    {
        result = RZTweenClampFloat(result, MIN(outMin,outMax), MAX(outMin,outMax));
    }
    return result;
}

// -----------------------------

@interface RZTweenKeyFrame : NSObject

+ (instancetype)keyFrameWithTime:(NSTimeInterval)time value:(NSValue *)value;

@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, strong) NSValue *value;

@end

@implementation RZTweenKeyFrame

+ (instancetype)keyFrameWithTime:(NSTimeInterval)time value:(NSValue *)value
{
    RZTweenKeyFrame *kf = [RZTweenKeyFrame new];
    kf.time = time;
    kf.value = value;
    return kf;
}

@end

// -----------------------------


@interface RZTween ()

@property (nonatomic, strong) NSMutableArray *sortedKeyFrames;
- (void)addKeyFrame:(RZTweenKeyFrame *)keyFrame;

- (NSArray *)nearestKeyFramesForTime:(NSTimeInterval)time;

@end

@implementation RZTween

- (id)init
{
    self = [super init];
    if (self)
    {
        self.sortedKeyFrames = [NSMutableArray array];
    }
    return self;
}

- (NSValue *)valueAtTime:(NSTimeInterval)time
{
    return @0;
}

- (void)addKeyFrame:(RZTweenKeyFrame *)keyFrame
{
    if (self.sortedKeyFrames.count == 0)
    {
        [self.sortedKeyFrames addObject:keyFrame];
    }
    else
    {
        NSUInteger newIndex = [self.sortedKeyFrames indexOfObject:keyFrame
                                                    inSortedRange:NSMakeRange(0, self.sortedKeyFrames.count)
                                                          options:NSBinarySearchingInsertionIndex
                                                  usingComparator:^NSComparisonResult(RZTweenKeyFrame *kf1, RZTweenKeyFrame *kf2) {
                                                      return [@(kf1.time) compare:@(kf2.time)];
                                                  }];
        [self.sortedKeyFrames insertObject:keyFrame atIndex:newIndex];
    }
}

- (NSArray *)nearestKeyFramesForTime:(NSTimeInterval)time
{
    NSArray *kframes = nil;
    if (self.sortedKeyFrames.count > 0)
    {
        RZTweenKeyFrame *searchFrame = [RZTweenKeyFrame keyFrameWithTime:time value:nil];
        NSUInteger insertIndex = [self.sortedKeyFrames indexOfObject:searchFrame
                                                       inSortedRange:NSMakeRange(0, self.sortedKeyFrames.count)
                                                             options:NSBinarySearchingInsertionIndex
                                                     usingComparator:^NSComparisonResult(RZTweenKeyFrame *kf1, RZTweenKeyFrame *kf2) {
                                                         return [@(kf1.time) compare:@(kf2.time)];
                                                     }];
        
        if (insertIndex == 0)
        {
            kframes = @[[self.sortedKeyFrames firstObject]];
        }
        else if (insertIndex == self.sortedKeyFrames.count)
        {
            kframes = @[[self.sortedKeyFrames lastObject]];
        }
        else
        {
            kframes = @[[self.sortedKeyFrames objectAtIndex:insertIndex-1],
                        [self.sortedKeyFrames objectAtIndex:insertIndex]];
        }
    }
    return kframes;
}

@end

// -----------------------------

@implementation RZFloatTween

- (void)addKeyFloat:(CGFloat)keyFloat atTime:(NSTimeInterval)time
{
    [self addKeyFrame:[RZTweenKeyFrame keyFrameWithTime:time value:@(keyFloat)]];
}


- (NSValue*)valueAtTime:(NSTimeInterval)time
{
    NSNumber *value = @0;
    NSArray *nearestKeyFrames = [self nearestKeyFramesForTime:time];
    if (nearestKeyFrames.count > 0)
    {
        if (nearestKeyFrames.count == 1)
        {
            RZTweenKeyFrame *kf = [nearestKeyFrames firstObject];
            value = (NSNumber*)kf.value;
        }
        else
        {
            RZTweenKeyFrame *kf1 = [nearestKeyFrames firstObject];
            RZTweenKeyFrame *kf2 = [nearestKeyFrames lastObject];
            value = @(RZTweenMapFloat(time, kf1.time, kf2.time, [(NSNumber*)kf1.value floatValue], [(NSNumber*)kf2.value floatValue], YES));
        }
    }
    return value;
}

@end

// -----------------------------

@implementation RZBooleanTween

- (void)addKeyBool:(BOOL)keyBool atTime:(NSTimeInterval)time
{
    [self addKeyFrame:[RZTweenKeyFrame keyFrameWithTime:time value:@(keyBool)]];
}


- (NSValue*)valueAtTime:(NSTimeInterval)time
{
    NSNumber *value = @0;
    NSArray *nearestKeyFrames = [self nearestKeyFramesForTime:time];
    if (nearestKeyFrames.count > 0)
    {
        RZTweenKeyFrame *kf = [nearestKeyFrames firstObject];
        value = (NSNumber*)kf.value;
    }
    return value;
}

@end

// -----------------------------

@implementation RZTransformTween

- (void)addKeyTransform:(CGAffineTransform)transform atTime:(NSTimeInterval)time
{
    [self addKeyFrame:[RZTweenKeyFrame keyFrameWithTime:time value:[NSValue valueWithCGAffineTransform:transform]]];
}


- (NSValue*)valueAtTime:(NSTimeInterval)time
{
    NSValue *transformValue = [NSValue valueWithCGAffineTransform:CGAffineTransformIdentity];
    NSArray *nearestKeyFrames = [self nearestKeyFramesForTime:time];
    if (nearestKeyFrames.count > 0)
    {
        if (nearestKeyFrames.count == 1)
        {
            RZTweenKeyFrame *kf = [nearestKeyFrames firstObject];
            transformValue = kf.value;
        }
        else
        {
            RZTweenKeyFrame *kf1 = [nearestKeyFrames firstObject];
            RZTweenKeyFrame *kf2 = [nearestKeyFrames lastObject];
            
            CGAffineTransform tf1 = [kf1.value CGAffineTransformValue];
            CGAffineTransform tf2 = [kf2.value CGAffineTransformValue];
            
            CGAffineTransform finalTf;
            finalTf.a = RZTweenMapFloat(time, kf1.time, kf2.time, tf1.a, tf2.a, YES);
            finalTf.b = RZTweenMapFloat(time, kf1.time, kf2.time, tf1.b, tf2.b, YES);
            finalTf.c = RZTweenMapFloat(time, kf1.time, kf2.time, tf1.c, tf2.c, YES);
            finalTf.d = RZTweenMapFloat(time, kf1.time, kf2.time, tf1.d, tf2.d, YES);
            finalTf.tx = RZTweenMapFloat(time, kf1.time, kf2.time, tf1.tx, tf2.tx, YES);
            finalTf.ty = RZTweenMapFloat(time, kf1.time, kf2.time, tf1.ty, tf2.ty, YES);
            
            transformValue = [NSValue valueWithCGAffineTransform:finalTf];
        }
    }
    return transformValue;
}

@end

