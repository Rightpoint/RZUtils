//
//  NSDictionary+RZExtensions.h
//
//  Created by Stephen Barnes on 4/9/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (RZExtensions)

- (id)validObjectForKey:(id)aKey;
- (id)validObjectForKeyPath:(id)aKeyPath;

// Ensures the value returned is a NSNumber. Converts from NSString if possible.
// returns nil if not valid.
- (id)numberForKey:(id)aKey;

@end
