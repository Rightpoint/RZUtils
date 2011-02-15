//
//  NSAttributedString+RZExtensions.m
//  Raizlabs
//
//  Created by Alex Rouse on 12/13/13.

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

#import "NSAttributedString+RZExtensions.h"

@implementation NSAttributedString (RZExtensions)

+ (instancetype)rz_attributedStringWithStringsAndAttributes:(id)firstString, ... NS_REQUIRES_NIL_TERMINATION
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
