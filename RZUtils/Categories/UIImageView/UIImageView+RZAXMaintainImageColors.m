//
//  UIImageView+RZAXMaintainImageColors.m
//
//  Created by Justin Kaufman on 5/15/14.
//
//  Copyright 2014 Raizlabs and other contributors
//  http://raizlabs.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "UIImageView+RZAXMaintainImageColors.h"

#import <objc/runtime.h>
#import <CoreImage/CoreImage.h>

static NSString* const kRZAccessibilityCIColorInvertFilterName = @"CIColorInvert";
static NSString* const kRZAccessibilityCIGammaAdjustFilterName = @"CIGammaAdjust";
static NSString* const kRZAccessibilityCIGammaAdjustInputPowerKey = @"inputPower";
const CGFloat kRZAccessibilityCIGammaAdjustInputPowerValue = 2.2f;

const NSTimeInterval kRZAccessibilityInvertColorsTransitionDuration = 0.2f;

@interface UIImageView ()

@end

@implementation UIImageView (RZAXMaintainImageColors)

- (void)rz_invertImageColorsForAccessibility
{
    UIImage *outputUIImage = nil;

    // Grab backing CIImage, if we're lucky, or create one with the image contents.
    UIImage *inputUIImage = self.image;
    CIImage *inputCIImage = inputUIImage.CIImage;
    if ( inputCIImage == nil ) {
        inputCIImage = [CIImage imageWithCGImage:inputUIImage.CGImage];
    }
    
    // Invert colors, making sure to undo CIFIlter gamma correction.
    CIFilter *colorInvertFilter = [CIFilter filterWithName:kRZAccessibilityCIColorInvertFilterName];
    CIFilter *gammaAdjustFilter = [CIFilter filterWithName:kRZAccessibilityCIGammaAdjustFilterName];
    
    [gammaAdjustFilter setValue:@( 1 / kRZAccessibilityCIGammaAdjustInputPowerValue )
                         forKey:kRZAccessibilityCIGammaAdjustInputPowerKey];
    [gammaAdjustFilter setValue:inputCIImage forKey:kCIInputImageKey];
    inputCIImage = gammaAdjustFilter.outputImage;
    
    [colorInvertFilter setValue:inputCIImage forKey:kCIInputImageKey];
    inputCIImage = colorInvertFilter.outputImage;
    
    [gammaAdjustFilter setValue:@(kRZAccessibilityCIGammaAdjustInputPowerValue)
                         forKey:kRZAccessibilityCIGammaAdjustInputPowerKey];
    [gammaAdjustFilter setValue:inputCIImage forKey:kCIInputImageKey];
    inputCIImage = gammaAdjustFilter.outputImage;
    
    // Create a new UIImage from the filter output.
    // Note that [UIImage -initWithCIImage:] does not render correctly.
    CIContext *context = [CIContext contextWithOptions:nil];
    CGRect imageRect =  (CGRect){.origin = CGPointZero, .size = inputCIImage.extent.size};
    CGImageRef outputCGImage = [context createCGImage:inputCIImage fromRect:imageRect];
    outputUIImage = [UIImage imageWithCGImage:outputCGImage];
    CGImageRelease(outputCGImage);
    
    [UIView transitionWithView:self
                      duration:kRZAccessibilityInvertColorsTransitionDuration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.image = outputUIImage;
                    } completion:nil];
}

- (void)rz_accessibilityMaintainImageColorsWhenInverted
{
    [self setAccessibilityMaintainImageColors:YES];
    
    // Check invert state, inverting immediately if required.
    if ( UIAccessibilityIsInvertColorsEnabled() ) {
        [self rz_invertImageColorsForAccessibility];
    }
}

- (void)dealloc
{
    [self setAccessibilityMaintainImageColors:NO];
}

#pragma mark - Category Property Implementations

- (void)setAccessibilityMaintainImageColors:(BOOL)accessibilityMaintainImageColors
{
    if ( accessibilityMaintainImageColors == self.accessibilityMaintainImageColors ) {
        return;
    }
    else {
        objc_setAssociatedObject(self, @selector(accessibilityMaintainImageColors), @(accessibilityMaintainImageColors), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if ( accessibilityMaintainImageColors ) {
            
            __weak typeof(self) weakSelf = self;
            void (^accessibilityNotificationBlock)(NSNotification *note) = ^(NSNotification *note){
                __strong typeof(self) strongSelf = weakSelf;
                [strongSelf rz_invertImageColorsForAccessibility];
            };
            
            [[NSNotificationCenter defaultCenter] addObserverForName:UIAccessibilityInvertColorsStatusDidChangeNotification
                                                              object:nil
                                                               queue:nil
                                                          usingBlock:accessibilityNotificationBlock];
        }
        else {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UIAccessibilityInvertColorsStatusDidChangeNotification
                                                          object:nil];
        }
    }
}

- (BOOL)accessibilityMaintainImageColors
{
    BOOL accessibilityMaintainImageColorsToReturn = NO;
    
    NSNumber *accessibilityMaintainImageColorsNumber = objc_getAssociatedObject(self, @selector(accessibilityMaintainImageColors));
    if ( [accessibilityMaintainImageColorsNumber isKindOfClass:[NSNumber class]] )
    {
        accessibilityMaintainImageColorsToReturn = [accessibilityMaintainImageColorsNumber boolValue];
    }
    
    return accessibilityMaintainImageColorsToReturn;
}

@end
