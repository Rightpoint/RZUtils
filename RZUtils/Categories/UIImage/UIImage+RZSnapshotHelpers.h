//
//  UIImage+SnapshotHelpers.h
//
//  Created by Stephen Barnes on 4/30/14.

//
//  (See line: ..if you redistribute the Apple Software in its entirety and
//  WITHOUT MODIFICATIONS, you must retain this notice and the following
//  text and disclaimers in all such redistributions of the Apple Software.)

/*
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 
 Copyright © 2013 Apple Inc.
 WWDC 2013 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2013
 Session. Please refer to the applicable WWDC 2013 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and
 your use, installation, modification or redistribution of this Apple
 software constitutes acceptance of these terms. If you do not agree with
 these terms, please do not use, install, modify or redistribute this
 Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple. Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis. APPLE MAKES
 NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE
 IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 EA1002
 5/3/2013
 */

#import <UIKit/UIKit.h>

/**
 * Class for returning unmodified and blurred snapshots as a single object.
 *
 * @param unmodifiedSnapshot      The unblurred snapshot.
 * @param blurredSnapshot         The blurred snapshot.
 **/
@interface RZSnapshotHelperSnapshots : NSObject

@property (strong, nonatomic) UIImage *unmodifiedSnapshot;
@property (strong, nonatomic) UIImage *blurredSnapshot;

@end

@interface UIImage (RZSnapshotHelpers)

/**
 *  Blur the contents of a given UIView and return the result as a UIImage. Faster than Apple's supplied
 *  image blur method for iOS 7. iOS 7+.
 *
 *  @param view                  The UIView to be blurred.
 *  @param waitForUpdate         A Boolean value that indicates whether the snapshot should be rendered after recent changes have been incorporated. Specify the value NO if you want to render a snapshot in the view hierarchy’s current state, which might not include recent changes.
 *  @param blurRadius            The Gaussian blur radius. Specify higher values for more blurring.
 *  @param tintColor             Apply tint color to the returned UIImage*. Tint color ONLY APPLIES when blurring radius is non-negligible.
 *  @param saturationDeltaFactor The color saturation of the resulting blurred image.  Ranges between 0-1.0f. A value of 1.0f is fully saturated, while a value of 0.0f is completely unsaturated.
 *
 *  @return a blurred, UIImage created from the supplied UIView.
 */
+ (UIImage *)rz_blurredImageByCapturingView:(UIView *)view afterScreenUpdate:(BOOL)waitForUpdate withRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor;

/**
 *  Blur the contents of a given UIView and return an NSArray contining two images: the first being the image snapshot and the second being the blurred image.
 *  This can be useful for applying a continuous blur effect (by overlaying these two images and modifiying the alpha of the blurred image) without having to take repeated snapshots.
 *  Faster than Apple's supplied image blur method for iOS 7. iOS 7+.
 *
 *  @param view                  The UIView to be blurred.
 *  @param waitForUpdate         A Boolean value that indicates whether the snapshot should be rendered after recent changes have been incorporated. Specify the value NO if you want to render a snapshot in the view hierarchy’s current state, which might not include recent changes.
 *  @param blurRadius            The Gaussian blur radius. Specify higher values for more blurring.
 *  @param tintColor             Apply tint color to the returned UIImage*. Tint color ONLY APPLIES when blurring radius is non-negligible.
 *  @param saturationDeltaFactor The color saturation of the resulting blurred image.  Ranges between 0-1.0f. A value of 1.0f is fully saturated, while a value of 0.0f is completely unsaturated.
 *
 *  @return an RZOriginalAndModifiedSnapshots object with the unmodified and blurred snapshots.
 */
+ (RZSnapshotHelperSnapshots *)rz_unblurredAndblurredImagesByCapturingView:(UIView *)view afterScreenUpdate:(BOOL)waitForUpdate withRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor;

/**
 *  Blur the contents of a given UIView and return the result as a UIImage.  Faster than Apple's supplied
 *  image blur method for iOS 7. iOS 7+.
 *
 *  @param blurRadius            The Gaussian blur radius. Specify higher values for more blurring.
 *  @param tintColor             Apply tint color to the returned UIImage*. Tint color ONLY APPLIES when blurring radius is non-negligible.
 *  @param saturationDeltaFactor The color saturation of the resulting blurred image.  Ranges between 0-1.0f. A value of 1.0f is fully saturated, while a value of 0.0f is completely unsaturated.
 *
 *  @return a blurred, UIImage created from the supplied UIView.
 */
- (UIImage *)rz_blurredImageWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor;

/**
 *  Take a snapshot of a supplied UIView and return it as an UIImage*.  iOS7+.
 *
 *  @param view          The UIView to be captured.
 *  @param waitForUpdate A Boolean value that indicates whether the snapshot should be rendered after recent changes have been incorporated. Specify the value NO if you want to render a snapshot in the view hierarchy’s current state, which might not include recent changes.
 *
 *  @return a UIImage created from the supplied UIView.
 */
+ (UIImage *)rz_imageByCapturingView:(UIView *)view afterScreenUpdate:(BOOL)waitForUpdate;

@end
