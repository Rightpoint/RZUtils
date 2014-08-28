//
//  NSObject+RZBlockKVO.m
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

#import "NSObject+RZBlockKVO.h"
#import <objc/runtime.h>

static char kRZAssociatedObservationsKey;

@interface RZBlockObservation : NSObject

- (instancetype)initWithObservedObject:(NSObject *)object observer:(NSObject *)observer keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(RZKVOChangeBlock)block;

@property (nonatomic, weak) NSObject *observedObject;
@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) RZKVOChangeBlock block;

@end

// -------------

@implementation NSObject (RZBlockKVO)

- (NSMutableArray*)rz_blockObservations
{
    NSMutableArray *observations = objc_getAssociatedObject(self, &kRZAssociatedObservationsKey);
    if ( observations == nil ) {
        observations = [NSMutableArray array];
        objc_setAssociatedObject(self, &kRZAssociatedObservationsKey, observations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observations;
}

- (void)rz_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options withBlock:(RZKVOBlock)block
{
    [self rz_addObserver:observer forKeyPath:keyPath options:options withChangeBlock:^(id object, NSDictionary *change) {
        block(change);
    }];
}

- (void)rz_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options withChangeBlock:(RZKVOChangeBlock)block
{
    [[observer rz_blockObservations] addObject:[[RZBlockObservation alloc] initWithObservedObject:self observer:observer keyPath:keyPath options:options block:block]];
}

- (void)rz_removeObserver:(NSObject *)observer keyPath:(NSString *)keyPath
{
    NSIndexSet *indexes = [[observer rz_blockObservations] indexesOfObjectsPassingTest:^BOOL(RZBlockObservation *obs, NSUInteger idx, BOOL *stop) {
        return (([obs.observer isEqual:observer] || obs.observer == nil) && (keyPath == nil || [keyPath isEqualToString:obs.keyPath]));
    }];
    
    if ( indexes.count > 0 ) {
        [[observer rz_blockObservations] removeObjectsAtIndexes:indexes];
    }
}

@end

// ----------

@implementation RZBlockObservation

- (instancetype)initWithObservedObject:(NSObject *)object observer:(NSObject *)observer keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(RZKVOChangeBlock)block
{
    self = [super init];
    if ( self ) {
        self.observedObject = object;
        self.observer = observer;
        self.keyPath = keyPath;
        self.block = block;
        
        
        [object addObserver:self forKeyPath:keyPath options:options context:nil];
    }
    return self;
}

- (void)dealloc
{
    if ( self.observedObject ) {
        @try {
            [self.observedObject removeObserver:self forKeyPath:self.keyPath];
        }
        @catch (NSException *exception) {}
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( self.block ) {
        self.block(object, change);
    }
}

@end
