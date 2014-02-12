//
//  RZAnimatedCountingLabel.m
//  Raizlabs
//
//  Created by Nick Donaldson on 11/13/13.

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

#import "RZAnimatedCountingLabel.h"

@interface RZAnimatedCountingLabel ()

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, copy) RZAnimatedCountingLabelFormatBlock formatBlock;

@property (nonatomic, strong) NSNumber *currentNumber;
@property (nonatomic, strong) NSNumber *initialNumber;
@property (nonatomic, strong) NSNumber *targetNumber;

@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

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

- (NSNumberFormatter *)numberFormatter
{
    // Currently this is locked to US localization (comma delimited)
    if (_numberFormatter == nil)
    {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        _numberFormatter.maximumFractionDigits = 0;
        _numberFormatter.usesGroupingSeparator = YES;
        _numberFormatter.groupingSeparator = @",";
        _numberFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    }
    return _numberFormatter;
}
#pragma mark - Public

- (void)setFormatBlock:(RZAnimatedCountingLabelFormatBlock)formatBlock
{
    _formatBlock = formatBlock;
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
        valueString = [self.numberFormatter stringFromNumber:self.currentNumber];
    }
    
    self.text = valueString;
}

@end
