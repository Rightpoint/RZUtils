//
//  RZKeychain.h
//
//  Original solution by StackOverflow user Anomie: http://stackoverflow.com/q/5251820

#import <Foundation/Foundation.h>

@interface RZKeychain : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;

+ (void) setValue:(id)value forKey:(NSString*)key inService:(NSString*)service;
+ (void) removeValueForKey:(NSString*)key inService:(NSString*)service;
+ (id) valueForKey:(NSString*)key inService:(NSString*)service;

@end
