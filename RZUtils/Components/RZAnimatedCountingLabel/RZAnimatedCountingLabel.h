//
//  RZAnimatedCountingLabel.h
//  VirginPulse
//
//  Created by Nick Donaldson on 11/13/13.
//  Copyright (c) 2013 Virgin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

// Block that returns a formatted NSString from an NSNumber argument
typedef NSString * (^RZAnimatedCountingLabelFormatBlock)(NSNumber *number);

@interface RZAnimatedCountingLabel : UILabel

// Interval at which number is updated. Defaults to 100 ms (10 updates per second)
@property (nonatomic, assign) NSTimeInterval updateInterval;

// By default just formats as decimal integer. Provide a block here to use custom formatting
- (void)setFormatBlock:(RZAnimatedCountingLabelFormatBlock)formatBlock;

// Set number value without animation. Will cancel existing animation.
- (void)setNumberValue:(NSNumber *)numberValue;

// Set number value with animation. Will cancel existing animation before starting.
- (void)animateToNumberValue:(NSNumber *)numberValue duration:(CFTimeInterval)duration completion:(void(^)(BOOL finished))completion;

@end
