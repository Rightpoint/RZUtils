//
//  NSObject+RZBlockKVO.h
//
//  Created by Nick Donaldson on 10/21/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RZKVOBlock)(NSDictionary *change);

@interface NSObject (RZBlockKVO)

// Start observing changes on an object/keypath, using a change block. Will automatically stop observing when observer is deallocated.
- (void)rz_beginObservingObject:(NSObject *)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options withBlock:(RZKVOBlock)block;

// Stop observing changes on an object/keypath.
// If keyPath is nil, will stop observing all observed keypaths on object
- (void)rz_endObservingObject:(NSObject *)object keyPath:(NSString *)keyPath;

@end
