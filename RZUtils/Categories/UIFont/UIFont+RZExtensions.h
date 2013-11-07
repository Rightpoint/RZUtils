//
//  UIFont+RZExtensions.h
//  Raizlabs
//
//  Created by Alex Rouse on 11/7/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (RZExtensions)

// Returns the font with the name or defaults to system font instead of returning nil.
// This should be used when adding a font to a dictionary as to not insert nil.
+ (UIFont *)rz_nonNilFontWithName:(NSString *)fontName size:(CGFloat)fontSize;

@end
