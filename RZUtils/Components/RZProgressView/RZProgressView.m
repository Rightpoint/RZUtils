//
//  RZProgressView.m
//  Raizlabs
//
//  Created by Zev Eisenberg on 4/2/14.

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

#import "RZProgressView.h"

const CGFloat kRZProgressDefaultHeight = 2.0;
const CGFloat kRZProgressDefaultHeightBar = 2.5;
const CGFloat kRZProgressAccessibilityMinimumHeight = 22.0;

const CGFloat kRZProgressMinBarWidth = 4.0;

const float kRZProgressDefaultValue = 0.0;
const float kRZProgressMinValue = 0;
const float kRZProgressMaxValue = 1;

const CGFloat kRZProgressAnimationVelocity = 210;

#define kRZProgressTrackColorDefault [UIColor colorWithRed:183.0/255.0 green:183.0/255.0 blue:183.0/255.0 alpha:1]
#define kRZProgressTrackColorBar     [UIColor clearColor]

#define CLAMP(num, minVal, maxVal) (MAX(MIN(num, maxVal), minVal))

@interface RZProgressView ()

@property (strong, nonatomic) UIImageView *trackImageView;
@property (strong, nonatomic) UIImageView *progressImageView;

@property (strong, nonatomic) NSLayoutConstraint *progressConstraint;

@property (strong, nonatomic) NSNumberFormatter *numberFormatter;

@end

@implementation RZProgressView

- (instancetype)initWithProgressViewStyle:(RZProgressViewStyle)style
{
    self = [super initWithFrame:CGRectZero];
    if ( self ) {
        self.progressViewStyle = style;
        [self sharedSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        self.progressViewStyle = RZProgressViewStyleDefault;
        [self sharedSetup];
    }
    return self;
}

#pragma mark - private methods

- (void)sharedSetup
{
    self.isAccessibilityElement = YES;
    
    self.trackImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.progressImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    [self tintColorDidChange];
    
    self.progressImageView.backgroundColor = self.tintColor;
    
    NSDictionary *views = @{@"track" : self.trackImageView,
                            @"progress" : self.progressImageView};
    
    for (NSString *key in views) {
        UIView *view = views[key];
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    [self addSubview:self.trackImageView];
    [self addSubview:self.progressImageView];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[track]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[track]|" options:0 metrics:nil views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[progress]" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[progress]|" options:0 metrics:nil views:views]];
    
    [self updateProgressConstraint];
    
    [self setProgress:kRZProgressDefaultValue animated:NO];
}

- (void)updateProgressConstraint
{
    CGFloat minWidth = kRZProgressMinBarWidth;
    if ( self.progressImage ) {
        minWidth = self.progressImage.capInsets.left + self.progressImage.capInsets.right;
    }
    
    CGFloat actualWidth = CGRectGetWidth(self.bounds) * self.progress;
    
    CGFloat widthToUse = actualWidth;
    
    CGFloat fractionToUse;
    
    if ( actualWidth < minWidth ) {
        fractionToUse = 0;
    }
    else {
        fractionToUse = widthToUse / CGRectGetWidth(self.bounds);
    }
    
    [self removeConstraint:self.progressConstraint];
    
    self.progressConstraint = [NSLayoutConstraint constraintWithItem:self.progressImageView
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:fractionToUse
                                                            constant:0];
    
    [self addConstraint:self.progressConstraint];
    [self setNeedsUpdateConstraints];
}

+ (CGFloat)roundSizeUpToNearestScreenPixel:(CGFloat)sizeInPoints
{
    CGFloat screenPixelsPerPoint = 1 / [UIScreen mainScreen].scale;
    CGFloat amountGreaterThanWholeNumberOfScreenPixels = fmod(sizeInPoints, screenPixelsPerPoint);
    CGFloat retVal = sizeInPoints;
    if ( amountGreaterThanWholeNumberOfScreenPixels != 0 ) {
        retVal += (screenPixelsPerPoint - amountGreaterThanWholeNumberOfScreenPixels);
    }
    return retVal;
}

#pragma mark - subclass overrides

- (void)layoutSubviews
{
    [self updateProgressConstraint];
    
    [super layoutSubviews];
    if ( (!self.trackImage && !self.progressImage) && self.progressViewStyle == RZProgressViewStyleDefault ) {
        CGFloat cornerRadius = CGRectGetHeight(self.bounds) / 2;
        self.layer.cornerRadius = cornerRadius;
        self.layer.masksToBounds = YES;
    }
    else {
        self.layer.cornerRadius = 0;
        self.layer.masksToBounds = NO;
    }
}

- (CGSize)intrinsicContentSize
{
    CGFloat intrinsicHeight;
    
    if ( self.trackImage ) {
        intrinsicHeight = self.trackImage.size.height;
    }
    else {
        switch ( self.progressViewStyle ) {
            case RZProgressViewStyleDefault:
                intrinsicHeight = [[self class] roundSizeUpToNearestScreenPixel:kRZProgressDefaultHeight];
                break;
            case RZProgressViewStyleBar:
                intrinsicHeight = [[self class] roundSizeUpToNearestScreenPixel:kRZProgressDefaultHeightBar];
                break;
        }
    }
    return CGSizeMake(UIViewNoIntrinsicMetric, intrinsicHeight);
}

- (void)tintColorDidChange
{
    if ( !self.trackImage ) {
        // Set the track tint color to the user-defined value, or else the appropriate default value.
        switch ( self.progressViewStyle ) {
            case RZProgressViewStyleDefault:
                self.trackImageView.backgroundColor = self.trackTintColor ?: kRZProgressTrackColorDefault;
                break;
            case RZProgressViewStyleBar:
                self.trackImageView.backgroundColor = self.trackTintColor ?: kRZProgressTrackColorBar;
                break;
        }
    }
    else {
        self.trackImageView.backgroundColor = [UIColor clearColor];
    }
    
    if ( !self.progressImage ) {
        self.progressImageView.backgroundColor = self.progressTintColor ?: self.tintColor;
    }
    else {
        self.progressImageView.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - properties (setters)

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    progress = CLAMP(progress, kRZProgressMinValue, kRZProgressMaxValue);
    
    NSTimeInterval duration = 0;
    if ( animated ) {
        CGFloat width = CGRectGetWidth(self.bounds);
        CGFloat distance = fabsf(progress - self.progress) * width;
        duration = distance / kRZProgressAnimationVelocity;
    }
    
    _progress = progress;
    
    [self updateProgressConstraint];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)setProgressViewStyle:(RZProgressViewStyle)progressViewStyle
{
    _progressViewStyle = progressViewStyle;
    [self tintColorDidChange];
    [self invalidateIntrinsicContentSize];
}

- (void)setProgress:(float)progress
{
    [self setProgress:progress animated:NO];
}

- (void)setProgressTintColor:(UIColor *)progressTintColor
{
    _progressTintColor = progressTintColor;
    [self tintColorDidChange];
}

- (void)setTrackTintColor:(UIColor *)trackTintColor
{
    _trackTintColor = trackTintColor;
    [self tintColorDidChange];
}

- (void)setProgressImage:(UIImage *)progressImage
{
    if ( progressImage ) {
        self.layer.cornerRadius = 0;
        self.layer.masksToBounds = NO;
        self.progressImageView.backgroundColor = [UIColor clearColor];
    }
    else {
        self.progressImageView.backgroundColor = self.tintColor;
    }
    
    self.progressImageView.image = progressImage;
    [self invalidateIntrinsicContentSize];
}

- (void)setTrackImage:(UIImage *)trackImage
{
    if ( trackImage ) {
        self.layer.cornerRadius = 0;
        self.layer.masksToBounds = NO;
        self.trackImageView.backgroundColor = [UIColor clearColor];
    }
    else {
        [self tintColorDidChange];
    }
    
    self.trackImageView.image = trackImage;
    [self invalidateIntrinsicContentSize];
}

#pragma mark - properties (getters)

- (UIImage *)trackImage
{
    return self.trackImageView.image;
}

- (UIImage *)progressImage
{
    return self.progressImageView.image;
}

- (NSNumberFormatter *)numberFormatter
{
    if ( !_numberFormatter ) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = NSNumberFormatterPercentStyle;
    }
    return _numberFormatter;
}

#pragma mark - accessibility

- (CGRect)accessibilityFrame
{
    CGRect screenCoordinatesFrame = UIAccessibilityConvertFrameToScreenCoordinates(self.frame, self.superview);
    if ( CGRectGetHeight(screenCoordinatesFrame) < kRZProgressAccessibilityMinimumHeight ) {
        CGFloat difference = kRZProgressAccessibilityMinimumHeight - CGRectGetHeight(screenCoordinatesFrame);
        screenCoordinatesFrame = CGRectInset(screenCoordinatesFrame, 0, - difference / 2);
    }
    
    return screenCoordinatesFrame;
}

- (NSString *)accessibilityLabel
{
    return NSLocalizedString(@"Progress", @"Noun, as in Progress Bar");
}

- (NSString *)accessibilityValue
{
    return [self.numberFormatter stringFromNumber:@(self.progress)];
}

- (UIAccessibilityTraits)accessibilityTraits
{
    // According to https://developer.apple.com/library/ios/documentation/userexperience/conceptual/UIKitUICatalog/UIProgressView.html
    // UIProgressView returns Updates Frequently and User Interaction Enabled. But User Interaction Enabled is not
    // a real UIAccessibilityTraits value, so this is most likely a documentation bug. By inspecting the iOS
    // Simualator with the Accessibility Inspector, we see that UIProgressView returns only UIAccessibilityTraitUpdatesFrequently.
    return UIAccessibilityTraitUpdatesFrequently;
}

@end
