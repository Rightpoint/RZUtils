//
//  UIImage+RZAverageColor.h
//  UniFirst
//
//  Created by Connor Smith on 5/27/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

@interface UIImage (RZAverageColor)

/**
 *  Returns the average color of a UIImage instance.
 *  @see @p UIColor+RZExtensions.h to use this with @p +[UIColor rz_contrastForColor:]
 *
 *  @return The average color of a UIImage instance.
 */
- (UIColor *)rz_averageColor;

@end
