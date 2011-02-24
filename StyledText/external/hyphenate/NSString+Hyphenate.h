//
//  NSString+Hyphenate.h
//
//  Created by Eelco Lempsink on 09-06-10.
//  Copyright 2010 Tupil. All rights reserved.
//

#import <Foundation/Foundation.h>

// This will not work out of the box!  You'll need some files from the 
// hyphen library and dictionaries.  See the README.txt for more information.

@interface NSString (Hyphenate)

// Returns the string with added soft-hyphens (UTF-8 char x00AD).
//
// The hyphenation library will be loaded using the locale identifiers name 
// (with the format hyph_%@.dic) and the locale will also be used to tokenize
// the string into words.
//
// If you pass nil as the locale, this function tries to use 
// CFStringTokenizerCopyBestStringLanguage to guess the language.
//
// The loaded dictionary will be cached, so for the best performance group your
// hyphenation tasks per locale.
- (NSString*)stringByHyphenatingWithLocale:(NSLocale*)locale;

@end
