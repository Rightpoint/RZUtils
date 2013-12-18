//
//  NSString+RZStringFormatting.m
//  Raizlabs
//
//  Created by Nick Donaldson on 5/8/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import "NSString+RZStringFormatting.h"

@implementation NSString (RZStringFormatting)

-(BOOL)rz_stringContainsOnlyCharactersFromString:(NSString*)allowedString{
    NSCharacterSet *allowedSet = [NSCharacterSet characterSetWithCharactersInString:allowedString];
    return [self stringByTrimmingCharactersInSet:allowedSet].length == 0;
}

-(BOOL)rz_stringContainsOnlyCharactersFromSet:(NSCharacterSet *)allowedSet{
    return [self stringByTrimmingCharactersInSet:allowedSet].length == 0;
}

-(NSString *)rz_formattedPhoneStringWithExt:(NSString *)ext {
    NSString *rawNumber = [[(NSString *) self copy] rz_rawNumberString]; //for readability
    NSString *formattedNumber = nil;
    
    if(rawNumber.length > 0){ //the "# or *" initial character exception
        NSCharacterSet *validCharacters = [NSCharacterSet decimalDigitCharacterSet];
        unichar oneChar = [rawNumber characterAtIndex:0];
        if(![validCharacters characterIsMember:oneChar]){
            return rawNumber;
        }
    }else {
        return rawNumber;
    }
    if (rawNumber.length >=4 && rawNumber.length <= 7) {
        formattedNumber = [NSString stringWithFormat:@"%@-%@", [rawNumber substringToIndex:3], [rawNumber  substringFromIndex:3]];
    } else if (rawNumber.length >= 8 && rawNumber.length <= 10) {
        formattedNumber = [NSString stringWithFormat:@"(%@) %@-%@", [rawNumber substringToIndex:3], [rawNumber substringWithRange:NSMakeRange(3,3)], [rawNumber substringFromIndex:6]];
    } else {
        formattedNumber = rawNumber;
    }
    
    if(ext.length > 0)
    {
        return [NSString stringWithFormat:@"%@  %@ %@", formattedNumber, @"Ext.", ext];
    }
    else
    {
        return formattedNumber;
    }
}


-(NSString *)rz_rawNumberString
{
    NSString *formattedNumber = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; //for readability
    NSMutableString *rawNumber = [NSMutableString string];
    NSCharacterSet *validCharacters = [NSCharacterSet decimalDigitCharacterSet];
    for (NSUInteger i = 0; i < [formattedNumber length]; i++) 
    {
        unichar oneChar = [formattedNumber characterAtIndex:i];
        if ([validCharacters characterIsMember:oneChar])
        {
            [rawNumber appendString:[formattedNumber substringWithRange:NSMakeRange(i,1)]];
        }
    }
    return rawNumber;
}


-(NSString *)rz_stringByInsertingSpacesForAmex {
    
    NSMutableString *spacedString = [NSMutableString string];
    
    // group of 4, 6, and 5
    for (NSUInteger i = 0; i < self.length; i++){
        [spacedString appendString:[self substringWithRange:NSMakeRange(i,1)]];    
        if (i==3 || i==9){
            [spacedString appendString:@" "];
        }
    }
    
    return spacedString;
}


-(NSString *)rz_stringObfuscatedWithCharacter:(unichar)obCharacter numberCharactersVisible:(NSUInteger)nCharsVisible
{
    if (!self.length) return self;
    NSString *stringToObfuscate = [self copy];
    
    const unichar _obChar = obCharacter;
    NSString *obCharString = [NSString stringWithCharacters:&_obChar length:1];
    NSMutableString *obString = [NSMutableString string];
    
    NSInteger nCharsToReplace = nCharsVisible ? stringToObfuscate.length - nCharsVisible : stringToObfuscate.length;
    if (nCharsToReplace <= 0) return self;
    
    for (NSInteger i = 0; i < nCharsToReplace; i++){
        [obString appendString:obCharString];
    }
    // tack on last character unobfoscated
    if (nCharsVisible > 0)
        [obString appendString:[stringToObfuscate substringWithRange:NSMakeRange(nCharsToReplace, nCharsVisible)]];
    
    return obString;
}

-(NSString *)rz_stringByInsertingSpacesAtInterval:(NSInteger)spaceInterval{
    
    // print warning?
    if (spaceInterval <= 0) return self;
    
    NSMutableString *spacedString = [NSMutableString string];
    
    for (NSUInteger i = 0; i < self.length; i++){
        [spacedString appendString:[self substringWithRange:NSMakeRange(i,1)]];    
        if (i && ((i+1) % spaceInterval) == 0){
            [spacedString appendString:@" "];
        }
    }
    
    return spacedString;
}

@end
