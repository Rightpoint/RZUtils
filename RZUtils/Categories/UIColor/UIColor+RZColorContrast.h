//
//  UIColor+RZColorContrast.h
//  UniFirst
//
//  Created by Connor Smith on 5/26/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (UFColorContrast)

/**
 *  Determines whether text over a color should be displayed as black or white. 
 *  Uses YIQ color space with the technique decribes here: http://24ways.org/2010/calculating-color-contrast/
 *
 *  @param color The color that text will be displayed over.
 *
 *  @return [UIColor blackColor] or [UIColor whiteColor] depending on the contrast.
 */
+ (UIColor *)contrastForColor:(UIColor *)color;

@end
