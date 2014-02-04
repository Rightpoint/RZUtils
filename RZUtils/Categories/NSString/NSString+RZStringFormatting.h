//
//  NSString+RZStringFormatting.h
//  Raizlabs
//
//  Created by Nick Donaldson on 5/8/12.
//  Copyright (c) 2012 Raizlabs. 
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
