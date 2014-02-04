//
//  NSObject+RZBlockKVO.m
//
//  Created by Nick Donaldson on 10/21/13.
//  Copyright (c) 2013 Raizlabs. 
//

#import "NSObject+RZBlockKVO.h"
#import <objc/runtime.h>

static char kRZAssociatedObservationsKey;

@interface RZBlockObservation : NSObject

- (instancetype)initWithObservedObject:(NSObject *)object observer:(NSObject *)observer keyPath:(NSString *)keypPath options:(NSKeyValueObservingOptions)options block:(RZKVOBlock)block;

@property (nonatomic, weak) NSObject *observedObject;
@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) RZKVOBlock block;

@end

// -------------

@implementation NSObject (RZBlockKVO)

- (NSMutableArray*)rz_blockObservations
{
    NSMutableArray *observations = objc_getAssociatedObject(self, &kRZAssociatedObservationsKey);
    if (observations == nil)
    {
        observations = [NSMutableArray array];
        objc_setAssociatedObject(self, &kRZAssociatedObservationsKey, observations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observations;
}


- (void)rz_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options withBlock:(RZKVOBlock)block
{
    [[observer rz_blockObservations] addObject:[[RZBlockObservation alloc] initWithObservedObject:self observer:observer keyPath:keyPath options:options block:block]];
}

- (void)rz_removeObserver:(NSObject *)observer keyPath:(NSString *)keyPath
{
    NSIndexSet *indexes = [[observer rz_blockObservations] indexesOfObjectsPassingTest:^BOOL(RZBlockObservation *obs, NSUInteger idx, BOOL *stop) {
        return (([obs.observer isEqual:observer] || obs.observer == nil) && (keyPath == nil || [keyPath isEqualToString:obs.keyPath]));
    }];
    
    if (indexes.count > 0)
    {
        [[observer rz_blockObservations] removeObjectsAtIndexes:indexes];
    }
}

@end

// ----------

@implementation RZBlockObservation

- (instancetype)initWithObservedObject:(NSObject *)object observer:(NSObject *)observer keyPath:(NSString *)keypPath options:(NSKeyValueObservingOptions)options block:(RZKVOBlock)block
{
    self = [super init];
    if (self)
    {
        self.observedObject = object;
        self.observer = observer;
        self.keyPath = keypPath;
        self.block = block;
        
        
        [object addObserver:self forKeyPath:keypPath options:options context:nil];
    }
    return self;
}

- (void)dealloc
{
    if (self.observedObject)
    {
        @try {
            [self.observedObject removeObserver:self forKeyPath:self.keyPath];
        }
        @catch (NSException *exception) {}
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.block)
    {
        self.block(change);
    }
}

@end
