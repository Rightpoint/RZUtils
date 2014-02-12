//
//  RZAnimatedCountingLabel.h
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
