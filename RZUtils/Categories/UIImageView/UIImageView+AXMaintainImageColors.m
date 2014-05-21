//
//  UIImageView+AXMaintainImageColors.m
//  RZUtils
//
//  Created by Justin Kaufman on 5/15/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "UIImageView+AXMaintainImageColors.h"

#import <objc/runtime.h>
#import <CoreImage/CoreImage.h>

static NSString* const kRZAccessibilityCIColorInvertFilterName = @"CIColorInvert";
static NSString* const kRZAccessibilityCIGammaAdjustFilterName = @"CIGammaAdjust";
static NSString* const kRZAccessibilityCIGammaAdjustInputPowerKey = @"inputPower";
const CGFloat kRZAccessibilityCIGammaAdjustInputPowerValue = 2.2f;

const NSTimeInterval kRZAccessibilityInvertColorsTransitionDuration = 0.2f;

@interface UIImageView ()

@end

@implementation UIImageView (AXMaintainImageColors)

- (void)rz_invertImagesColorsForAccessibility
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
    
    [gammaAdjustFilter setValue:@(1/kRZAccessibilityCIGammaAdjustInputPowerValue)
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

- (void)accessibilityMaintainImageColorsWhenInverted
{
    [self setAccessibilityMaintainImageColors:YES];
    
    // Check invert state, inverting immediately if required.
    if ( UIAccessibilityIsInvertColorsEnabled() ) {
        [self rz_invertImagesColorsForAccessibility];
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
                [strongSelf rz_invertImagesColorsForAccessibility];
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
