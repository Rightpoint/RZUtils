//
//  UIFont+RZExtensions.m
//  Raizlabs
//
//  Created by Alex Rouse on 11/7/13.
//  Copyright (c) 2013 Raizlabs. 
//

#import "UIFont+RZExtensions.h"

@implementation UIFont (RZExtensions)

+ (UIFont *)rz_nonNilFontWithName:(NSString *)fontName size:(CGFloat)fontSize
{
    UIFont* font = [UIFont fontWithName:fontName size:fontSize];
    if (font == nil)
    {
        font = [UIFont systemFontOfSize:fontSize];
    }
    return font;
}

@end
