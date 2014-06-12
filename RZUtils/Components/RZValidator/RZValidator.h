//
//  RZValidator.h
//  RZLogin
//
//  Created by Joshua Leibsly on 3/21/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

// constants for keys used in 'validation info' dictionary;
// these can be expanded upon to support additional types of validation
//
// keys for validation rules:
#define kFieldValidationRegexKey    @"regex"
#define kFieldValidationMinCharsKey @"minChars"
#define kFieldValidationMaxCharsKey @"maxChars"
//
// keys for validation message:
#define kFieldValidationFailureMessage @"msg"

/**
 *  A validation block type that returns YES if given string is valid.
 *
 *  @param str String that will be tested for validity.
 *
 *  @return Whether or not str is valid.
 */
typedef BOOL (^ValidationBlock)(NSString *str);

// Use a distinct 'localization table' for RZValidator messages (i.e. the file 'RZValidatorLocalizable.strings')
#define RZValidatorLocalizedString(x, y) NSLocalizedStringFromTable((x), @"RZValidatorLocalizable", (y))

@interface RZValidator : NSObject

/**
 *  Initialize with a validation-info dictionary
 *
 *  @param validationConditions Conditions that determine the rules for passing validity.
 *
 *  @return An instance of RZValidator.
 */
- (id)initWithValidationConditions:(NSDictionary *)validationConditions;

/**
 *  Initialize with a block.
 *
 *  @param validationBlock A block that determines validity.
 *
 *  @return An instance of RZValidator.
 */
- (id)initWithValidationBlock:(ValidationBlock)validationBlock;

// a localized message describing the reason for failure
// TODO: move this message to 'per-condition' that is checked
@property (copy, nonatomic) NSString *localizedViolationString;
@property (copy, nonatomic) NSString *localizedViolationStringTitle;

// method to validate a string.
- (BOOL)isValidForString:(NSString *)str;

// convenience constructors
+ (RZValidator *)validatorWithConditions:(NSDictionary *)validationConditions;
+ (RZValidator *)validatorWithBlock:(ValidationBlock)validationBlock;

// some standard validators
+ (RZValidator *)emailAddressLooseValidator;
+ (RZValidator *)emailAddressStrictValidator; //Based on RFC 2822
+ (RZValidator *)notEmptyValidator;
+ (RZValidator *)notEmptyValidatorForFieldName:(NSString *)fieldName;

@end
