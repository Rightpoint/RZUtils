//
//  NSDictionary+RZExtensions.m
//
//  Created by Stephen Barnes on 4/9/13.
//  Copyright (c) 2013 Raizlabs. 
//

#import "NSDictionary+RZExtensions.h"

@implementation NSDictionary (RZExtensions)

- (id)validObjectForKey:(id)aKey
{
    id obj = [self objectForKey:aKey];
    if (obj == [NSNull null]) {
        obj = nil;
    }
    
    return obj;
}

- (id)validObjectForKeyPath:(id)aKeyPath
{
    id obj = [self valueForKeyPath:aKeyPath];
    if (obj == [NSNull null]) {
        obj = nil;
    }
    
    return obj;
}

- (id)numberForKey:(id)aKey
{
    id object = [self validObjectForKey:aKey];
    
    if([object isKindOfClass:[NSString class]])
    {
        NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        object = [formatter numberFromString:object];
    }
    else if(![object isKindOfClass:[NSNumber class]])
    {
        object = nil;
    }
    
    return object;
}

@end
