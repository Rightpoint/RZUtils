//
//  NSAttributedString+RZExtensions.m
//  Raizlabs
//
//  Created by Alex Rouse on 12/13/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "NSAttributedString+RZExtensions.h"

@implementation NSAttributedString (RZExtensions)

+ (instancetype)attributedStringWithStringsAndAttributes:(id)firstString, ... NS_REQUIRES_NIL_TERMINATION
{
    NSMutableAttributedString* string = [[NSMutableAttributedString alloc] init];
    id param;
    NSDictionary* attributes;
    NSString* content = firstString;
    va_list argumentList;
    if (content)
    {
        va_start(argumentList, firstString);
        while ((param = va_arg(argumentList, id)) != nil)
        {
            if ([param isKindOfClass:[NSString class]])
            {
                content = param;
            }
            else if ([param isKindOfClass:[NSDictionary class]])
            {
                attributes = param;
            }
            
            if ([content isKindOfClass:[NSString class]] && [attributes isKindOfClass:[NSDictionary class]] )
            {
                NSAttributedString* str = [[NSAttributedString alloc] initWithString:content attributes:attributes];
                [string appendAttributedString:str];
                content = nil;
                attributes = nil;
            }
        }
        va_end(argumentList);
    }
    return [[NSAttributedString alloc] initWithAttributedString:string];
}

@end
