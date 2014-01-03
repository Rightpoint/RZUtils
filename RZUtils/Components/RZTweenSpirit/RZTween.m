//
//  RZTween.m
//  VirginPulse
//
//  Created by Nick D on 1/3/14.
//  Copyright (c) 2014 Virgin. All rights reserved.
//

#import "RZTween.h"

static float RZTweenMapFloat(float value, float inMin, float inMax, float outMin, float outMax, BOOL clamp)
{
    float result = ((value - inMin)/(inMax - inMin)) * (outMax - outMin) + outMin;
    if (clamp)
    {
        result = RZClampFloat(result, MIN(outMin,outMax), MAX(outMin,outMax));
    }
    return result;
}

// -----------------------------

@interface RZTweenKeyFrame : NSObject

@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, strong) NSValue *value;

@end

@implementation RZTweenKeyFrame
@end

// -----------------------------


@interface RZTween ()

@property (nonatomic, strong) NSMutableArray *sortedKeyFrames;



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

@end

// -----------------------------

@implementation RZFloatTween

- (void)addKeyFloat:(CGFloat)keyFloat atTime:(NSTimeInterval)time
{
    [self.keyValues setObject:@(keyFloat) forKey:@(time)];
}

- (NSValue*)valueAtTime:(NSTimeInterval)time
{

}

- (id)copyWithZone:(NSZone *)zone
{
    RZFloatTween *copy = [RZFloatTween new];
    copy->_keyValues = [_keyValues copy];
    return copy;
}

// -----------------------------


@end


