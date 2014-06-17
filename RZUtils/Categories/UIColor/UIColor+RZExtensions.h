//
//  UIColor+RZExtensions.h
//
//  Created by Nick Donaldson on 5/20/14.

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

@interface UIColor (RZExtensions)

/**
 *  Convert 8-bit RGB values (0-255) to a UIColor
 *
 *  @param r Red value
 *  @param g Green value
 *  @param b Blue Value
 *
 *  @return A new UIColor with the provided values
 */
+ (UIColor *)rz_colorFrom8BitRed:(uint8_t)r green:(uint8_t)g blue:(uint8_t)b;

/**
 *  Convert 8-bit RGBA values (0-255) to a UIColor
 *
 *  @param r Red value
 *  @param g Green value
 *  @param b Blue value
 *  @param a Alpha value
 *
 *  @return A new UIColor with the provided values
 */
+ (UIColor *)rz_colorFrom8BitRed:(uint8_t)r green:(uint8_t)g blue:(uint8_t)b alpha:(uint8_t)a;

/**
 *  Convert an 8-bit white value to a UIColor
 *
 *  @param white White value
 *
 *  @return A new UIColor with the provided white value
 */
+ (UIColor *)rz_colorFrom8BitWhite:(uint8_t)white;

/**
 *  Convert 8-bit white and alpha values to a UIColor
 *
 *  @param white White value
 *  @param alpha Alpha value
 *
 *  @return A new UIColor with the provided values
 */
+ (UIColor *)rz_colorFrom8BitWhite:(uint8_t)white alpha:(uint8_t)alpha;

/**
 *  Convert a hex literal to a UIColor.
 *  Expects RGB only. Blue is LSB, then green, then red. MSB is ignored.
 *
 *  @param hexLiteral Hex literal representing the color.
 *
 *  @return A new UIColor with the hex value provided
 */
+ (UIColor *)rz_colorFromHex:(uint32_t)hexLiteral;

/**
 *  Convert a RGB hex string to a UIColor.
 *  String is assumed to be a full 24-bit RGB hex string.
 *
 *  @param string Hex string representing the color.
 *
 *  @return A new UIColor with the hex value provided
 */
+ (UIColor *)rz_colorFromHexString:(NSString *)string;

/**
 *  Determines whether text over a color should be displayed as black or white.
 *  Uses YIQ color space with the technique decribes here: http://24ways.org/2010/calculating-color-contrast/
 *
 *  @param color The color that text will be displayed over.
 *
 *  @return @p[UIColor blackColor] or @p[UIColor whiteColor] depending on the contrast.
 */
+ (UIColor *)rz_contrastForColor:(UIColor *)color;

/**
 *  @return A string, prefixed with “#”, followed by six lowercase hexadecimal digits. The alpha channel is ignored.
 */
- (NSString *)rz_hexString;

@end
