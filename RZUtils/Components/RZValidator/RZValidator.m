//
//  RZValidator.m
//  RZLogin
//
//  Created by Joshua Leibsly on 3/21/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "RZValidator.h"

//Typedef to identify whether we are validation with a dictionary or a block.
typedef enum {
    RZValidationTypeBlock,
    RZValidationTypeDictionary
} RZValidationType;

@interface RZValidator ()

//Store the validation type and the info dictionary or block.
@property (nonatomic, assign) RZValidationType validationType;
@property (nonatomic, strong) NSDictionary *validationConditions;
@property (strong) ValidationBlock validationBlock;

@end

@implementation RZValidator

// constructor that accepts a dictionary of validation information
- (id)initWithValidationConditions:(NSDictionary *)validationConditions
{
    if(self = [super init])
    {
        self.validationType = RZValidationTypeDictionary;
        self.validationConditions = validationConditions;
    }
    
    return self;
}

// constructor that accepts a validation block
- (id)initWithValidationBlock:(ValidationBlock)validationBlock
{
    if(self = [super init])
    {
        self.validationType = RZValidationTypeBlock;
        self.validationBlock = validationBlock;
    }
    
    return self;
}

// validates a given string against the receiver (validator)
- (BOOL)isValidForString:(NSString *)str
{
    // if validation type is a dictionary, iterate through the keys and validate appropriately...
    if(self.validationType == RZValidationTypeDictionary)
    {
        NSArray *allKeys = [self.validationConditions allKeys];
        for(NSString *key in allKeys)
        {
            if([key isEqualToString:kFieldValidationRegexKey]) //Regex case. Use NSPredicate to validate.
            {
                NSPredicate *regexPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", [self.validationConditions objectForKey:key]];
                if(![regexPredicate evaluateWithObject:str])
                {
                    return NO;
                }
            }
            else if([key isEqualToString:kFieldValidationMinCharsKey]) //Min chars case. Check length of string.
            {
                int minChars = [[self.validationConditions objectForKey:key] intValue];
                if(str.length < minChars)
                {
                    return NO;
                }
            }
            else if([key isEqualToString:kFieldValidationMaxCharsKey]) //Max chars case. Check length of string.
            {
                int maxChars = [[self.validationConditions objectForKey:key] intValue];
                if(str.length > maxChars)
                {
                    return NO;
                }
            }
        }
        
    } else if(self.validationType == RZValidationTypeBlock)  {
        
        // if the validator uses a block, pass the string to the block and return the result
        return self.validationBlock(str);
    }
    return YES;
}

#pragma mark - Convenience constructors

+ (RZValidator *)validatorWithConditions:(NSDictionary *)validationConditions
{
    return [[self alloc] initWithValidationConditions:validationConditions];
}

+ (RZValidator *)validatorWithBlock:(ValidationBlock)validationBlock
{
    return [[self alloc] initWithValidationBlock:validationBlock];
}

+ (RZValidator *)emailAddressLooseValidator
{
    NSString *emailRegEx =  @"[\\w+-]+(\\.[\\w+-]+)*@([\\w-]+\\.)+[\\w-]+";
    
    RZValidator *validator = [[self alloc] initWithValidationConditions:@{kFieldValidationRegexKey: emailRegEx}];
    validator.localizedViolationString = RZValidatorLocalizedString(@"invalid email address", @"Please enter a valid email address.");
    return validator;
}

+ (RZValidator *)emailAddressStrictValidator
{
    //Regex expression from: http://www.cocoawithlove.com/2009/06/verifying-that-string-is-email-address.html
    NSString *emailRegEx =  @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
                            @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
                            @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
                            @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
                            @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
                            @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
                            @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    RZValidator *validator = [[self alloc] initWithValidationConditions:@{kFieldValidationRegexKey: emailRegEx}];
    validator.localizedViolationString = RZValidatorLocalizedString(@"invalid email address", @"Please enter a valid email address.");
    return validator;
}

+ (RZValidator *)notEmptyValidator
{
    RZValidator *validator = [[self alloc] initWithValidationConditions:@{kFieldValidationMinCharsKey : @"1"}];
    validator.localizedViolationString = RZValidatorLocalizedString(@"field required", @"Field cannot be empty, please try again.");
    return validator;
}

+ (RZValidator *)notEmptyValidatorForFieldName:(NSString *)fieldName
{
    RZValidator *validator = [[self alloc] initWithValidationConditions:@{kFieldValidationMinCharsKey : @"1"}];
    validator.localizedViolationString = [NSString stringWithFormat:
                                          RZValidatorLocalizedString(@"%@ field must not be empty", @"%@ cannot be empty, please try again."), fieldName];
    return validator;
}
                                      
@end
