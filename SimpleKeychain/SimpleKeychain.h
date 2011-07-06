//
//  SimpleKeychain.h
//  Rue La La
//
//  Created by jkaufman on 3/23/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//
//  Simple wrapper for saving NSCoding-compliant objects to Keychain.
//  Original solution by StackOverflow user Anomie: http://stackoverflow.com/q/5251820

#import <Foundation/Foundation.h>

@class SimpleKeychainUserPass;

@interface SimpleKeychain : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;

@end