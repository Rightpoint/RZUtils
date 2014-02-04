//
//  UIImage+RZStretchHelpers.h
//
//  Created by Stephen Barnes on 4/9/13.
//  Copyright (c) 2013 Raizlabs. 
//


#import <UIKit/UIKit.h>

@interface UIImage (RZStretchHelpers)

- (UIImage*)makeStretchable;
- (UIImage*)makeStretchableWithCapInsets:(UIEdgeInsets)insets;

@end
