//
//  NSObject+RZBlockKVO.h
//
//  Created by Nick Donaldson on 10/21/13.

// Copyright 2014 Raizlabs and other contributors
// http://raizlabs.com/
// 
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>

typedef void (^RZKVOBlock)(NSDictionary *change) __attribute__((deprecated("Use use RZKVOChangeBlock instead.")));
typedef void (^RZKVOChangeBlock)(id object, NSDictionary *change);

/**
 *  Block-based KVO extensions. 
 *  @warning NOT THREAD SAFE.
 */
@interface NSObject (RZBlockKVO)

/**
 *  Add observer for changes on an object/keypath, using a change block. Will automatically remove observer when observer is deallocated.
 *
 *  @param observer The observer to add for the receiver. Used only as hash for block - not retained. Must not be nil.
 *  @param keyPath  The keypath on the receiver to observe. Must not be nil.
 *  @param options  The options for observing.
 *  @param block    The block that will be performed for KVO observation events. Must not be nil.
 */
- (void)rz_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options withBlock:(RZKVOBlock)block __attribute__((deprecated("Use rz_addObserver:forKeyPath:options:withChangeBlock: instead.")));

/**
 *  Add observer for changes on an object/keypath, using a change block. Will automatically remove observer when observer is deallocated.
 *
 *  @param observer The observer to add for the receiver. Used only as hash for block - not retained. Must not be nil.
 *  @param keyPath  The keypath on the receiver to observe. Must not be nil.
 *  @param options  The options for observing.
 *  @param block    The block that will be performed for KVO observation events. Must not be nil.
 */
- (void)rz_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options withChangeBlock:(RZKVOChangeBlock)block;

/**
 *  Remove observer for keypath on receiver.
 *
 *  @param observer The observer to remove. Must not be nil.
 *  @param keyPath  The keypath for which to remove the observer. If nil, all observers for reciever are removed.
 */
- (void)rz_removeObserver:(NSObject *)observer keyPath:(NSString *)keyPath;

@end
