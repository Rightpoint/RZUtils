//
//  NSAttributedString+RZStyledText.h
//
//  Created by jkaufman on 3/2/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

/**
 Adds some convenience methods to the NSAttributedString class.
 */
@interface NSAttributedString (RZStyledText)

/**
 Replaces a dangling soft-hyphen in this string with its visible representation, the hyphen-minus "-".
 @returns An autoreleased copy of this NSAttributedString with the change applied.
 */
- (NSAttributedString *)attributedStringWithVisibleHyphen;

/**
 Adjusts the point size of every font attribute in this string by the given amount.
 @param points Desired change in point size. This may be positive or negative.
 @returns An autoreleased copy of this NSAttributedString with the change applied.
 */
- (NSAttributedString *)attributedStringWithPointSizeAdjustment:(NSInteger)points;

@end
