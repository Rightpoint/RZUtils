//
//  NSObject+RZBlockKVO.h
//
//  Created by Nick Donaldson on 10/21/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RZKVOBlock)(NSDictionary *change);

@interface NSObject (RZBlockKVO)

// Add observer for changes on an object/keypath, using a change block. Will automatically remove observer when observer is deallocated.
- (void)rz_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options withBlock:(RZKVOBlock)block;

// Remove observer for keypath
// If keyPath is nil, will stop observing all observed keypaths
- (void)rz_removeObserver:(NSObject *)observer keyPath:(NSString *)keyPath;

@end
