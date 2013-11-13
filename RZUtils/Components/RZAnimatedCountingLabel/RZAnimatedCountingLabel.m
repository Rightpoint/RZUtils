//
//  RZAnimatedCountingLabel.m
//  Raizlabs
//
//  Created by Nick Donaldson on 11/13/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "RZAnimatedCountingLabel.h"

@interface RZAnimatedCountingLabel ()

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, copy) RZAnimatedCountingLabelFormatBlock formatBlock;

@property (nonatomic, strong) NSNumber *currentNumber;
@property (nonatomic, strong) NSNumber *initialNumber;
@property (nonatomic, strong) NSNumber *targetNumber;

@property (nonatomic, assign) CFTimeInterval animationDuration;
@property (nonatomic, assign) CFTimeInterval animationStartTimestamp;
@property (nonatomic, assign) CFTimeInterval lastUpdateTimestamp;

@property (nonatomic, copy) void (^animationCompletion)(BOOL finished);

- (void)displayLinkTick:(CADisplayLink *)displayLink;

- (void)updateLabelText;

@end

@implementation RZAnimatedCountingLabel

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        _updateInterval = 0.1;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        _updateInterval = 0.1;
    }
    return self;
}


#pragma mark - Public

- (void)setFormatBlock:(RZAnimatedCountingLabelFormatBlock)formatBlock
{
    self.formatBlock = formatBlock;
}

- (void)setNumberValue:(NSNumber *)numberValue
{
    if (self.displayLink && self.animationCompletion)
    {
        self.animationCompletion(NO);
        self.animationCompletion = nil;
    }
    
    [self.displayLink invalidate];
    self.displayLink = nil;
    self.currentNumber = numberValue;
    [self updateLabelText];
}

- (void)animateToNumberValue:(NSNumber *)numberValue duration:(CFTimeInterval)duration completion:(void (^)(BOOL))completion
{
    if (self.displayLink && self.animationCompletion)
    {
        self.animationCompletion(NO);
    }
    
    [self.displayLink invalidate];
    self.displayLink = nil;

    self.animationCompletion = completion;
    self.initialNumber = self.currentNumber ? self.currentNumber : @0;
    
    self.animationDuration = duration;
    self.targetNumber = numberValue;
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick:)];
    self.lastUpdateTimestamp = self.animationStartTimestamp = 0;
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark - Private

- (void)displayLinkTick:(CADisplayLink *)displayLink
{
    // TODO: actually use bezier curve timing function...
    CFTimeInterval td = displayLink.timestamp - self.lastUpdateTimestamp;
    if (td >= self.updateInterval || self.animationStartTimestamp == 0)
    {
        if (self.animationStartTimestamp == 0)
        {
            self.lastUpdateTimestamp = self.animationStartTimestamp = CACurrentMediaTime();
        }
        else
        {
            self.lastUpdateTimestamp = displayLink.timestamp - self.updateInterval;
        }
        
        CGFloat range = (self.targetNumber.floatValue - self.initialNumber.floatValue);
        CGFloat progress = MAX(0, MIN(1, (displayLink.timestamp - self.animationStartTimestamp)/self.animationDuration));
        CGFloat tweenedNumber = range * progress + self.initialNumber.floatValue;
        
        self.currentNumber = @(tweenedNumber);
        [self updateLabelText];
     
        if (displayLink.timestamp - self.animationStartTimestamp >= self.animationDuration)
        {
            [displayLink invalidate];
            self.displayLink = nil;
            
            if (self.animationCompletion)
            {
                self.animationCompletion(YES);
                self.animationCompletion = nil;
            }
        }
    }
}

- (void)updateLabelText
{
    NSString *valueString = nil;
    
    if (self.formatBlock)
    {
        valueString = self.formatBlock(self.currentNumber);
    }
    else
    {
        valueString = [NSString stringWithFormat:@"%d", self.currentNumber.integerValue];
    }
    
    self.text = valueString;
}

@end
