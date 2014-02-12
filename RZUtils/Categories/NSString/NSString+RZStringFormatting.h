//
//  NSString+RZStringFormatting.h
//  Raizlabs
//
//  Created by Nick Donaldson on 5/8/12.

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

// NSString utilities for common string tasks
// TODO: Could be extended to also format zip codes, strip particular character sets from strings, etc...

#import <Foundation/Foundation.h>

@interface NSString (RZStringFormatting)

// string testing

//! Returns true if receiver contains only characters from allowedString
-(BOOL)rz_stringContainsOnlyCharactersFromString:(NSString*)allowedString;

//! Returns true if receiver contains only characters from allowedSet
-(BOOL)rz_stringContainsOnlyCharactersFromSet:(NSCharacterSet*)allowedSet;

// phone numbers

//! Returns the receiver stripped of any non-decimal-digit characters
-(NSString *)rz_rawNumberString;

//! Returns a string formatted as a North-American phone number (555)-555-5555
-(NSString *)rz_formattedPhoneStringWithExt:(NSString *)ext;

// credit cards

//! Spaces for amex card number
-(NSString *)rz_stringByInsertingSpacesForAmex;


// utilities

//! Returns a string obfuscated by obCharacter
-(NSString *)rz_stringObfuscatedWithCharacter:(unichar)obCharacter numberCharactersVisible:(NSUInteger)nCharsVisible;

//! Inserts a space into receiver every spaceInterval characters
-(NSString *)rz_stringByInsertingSpacesAtInterval:(NSInteger)spaceInterval;

@end
