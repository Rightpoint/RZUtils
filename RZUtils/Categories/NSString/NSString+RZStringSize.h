//
//  NSString+RZStringSize.h
//  Care
//
//  Created by Nicholas Bonatsakis on 3/6/14.
//  Copyright (c) 2014 Care. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A set of methods that mirror the string sizing that was deprecated in iOS 7.
 *
 *  NOTE: In most cases, a better choice would be to use auto-layout.
 */
@interface NSString (RZStringSize)

- (CGSize)rz_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
- (CGSize)rz_sizeWithFont:(UIFont *)font;

@end
