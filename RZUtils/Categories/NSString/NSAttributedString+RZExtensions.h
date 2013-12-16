//
//  NSAttributedString+RZExtensions.h
//  Raizlabs
//
//  Created by Alex Rouse on 12/13/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (RZExtensions)

// Provide a list of strings followed by attributes and returns a NSAttributedString for their combination.
//
//  Example:
//  [NSAttributedString attributedStringWithStringsAndAttributes:@"test",attributes,@"test2,attributes2,nil];
// 

+ (instancetype)attributedStringWithStringsAndAttributes:(id)firstString, ... NS_REQUIRES_NIL_TERMINATION;

@end
