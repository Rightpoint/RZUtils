//
//  RZBlockKVOTests.m
//  RZUtilsTests
//
//  Created by Nick Donaldson on 7/1/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+RZBlockKVO.h"

@interface RZKVOTestObject : NSObject

@property (nonatomic, copy) NSString *aString;

@end

@implementation RZKVOTestObject

@end

#pragma mark -

@interface RZBlockKVOTests : XCTestCase

@end

@implementation RZBlockKVOTests

- (void)testObservation
{
    RZKVOTestObject *testObj = [RZKVOTestObject new];
    
    __weak RZKVOTestObject *weakTestObj = testObj;
    __block BOOL called = NO;
    [testObj rz_addObserver:self
                 forKeyPath:@"aString"
                    options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                  withChangeBlock:^(id object, NSDictionary *change) {
                      
                      XCTAssertEqualObjects(weakTestObj, object, @"Object in block does not match observed object");
                      
                      id value = [change objectForKey:NSKeyValueChangeNewKey];
                      if ( [value isEqual:[NSNull null]] ) {
                          value = nil;
                      }
                      
                      XCTAssertEqualObjects(value, weakTestObj.aString, @"Change not reflecting current value");
                      called = YES;
                  }];
    
    XCTAssertTrue(called, @"Block was not called initially");

    called = NO;
    testObj.aString = @"yo";
    
    XCTAssertTrue(called, @"Block was not called on value change");
    [testObj rz_removeObserver:self keyPath:nil];
}

- (void)testObserverDeallocation
{
    RZKVOTestObject *testObj = [RZKVOTestObject new];
    RZKVOTestObject *observerObj = [RZKVOTestObject new];
    
    __weak RZKVOTestObject *weakTestObj = testObj;
    __block BOOL called = NO;

    @autoreleasepool {

        [testObj rz_addObserver:observerObj
                     forKeyPath:@"aString"
                        options:NSKeyValueObservingOptionNew
                      withChangeBlock:^(id object, NSDictionary *change) {
                          XCTAssertEqualObjects(weakTestObj, object, @"Object in block does not match observed object");
                          called = YES;
                      }];
    
        testObj.aString = @"hi";
        XCTAssertTrue(called, @"Observation block not called");
    
        observerObj = nil;
    }
        
    called = NO;
    XCTAssertNoThrow(testObj.aString = @"Whaaat", @"KVO after dealloc of observer should not throw exception");
    XCTAssertFalse(called, @"Block should not be called after dealloc of observer");
}

- (void)testObserverRemoval
{
    RZKVOTestObject *testObj      = [RZKVOTestObject new];
    RZKVOTestObject *otherTestObj = [RZKVOTestObject new];

    __block BOOL firstBlockCalled = NO;
    __block BOOL secondBlockCalled = NO;

    [testObj rz_addObserver:self
                 forKeyPath:@"aString"
                    options:NSKeyValueObservingOptionNew
            withChangeBlock:^(id object, NSDictionary *change) {
                firstBlockCalled = YES;
            }];
    
    [otherTestObj rz_addObserver:self
                      forKeyPath:@"aString"
                         options:NSKeyValueObservingOptionNew
                 withChangeBlock:^(id object, NSDictionary *change) {
                    secondBlockCalled = YES;
                }];
	
    XCTAssertFalse(firstBlockCalled && secondBlockCalled, @"Neither block should have been called yet");
    
    testObj.aString = @"yo";
    
    XCTAssertTrue(firstBlockCalled, @"First block was not called on value change");
    XCTAssertFalse(secondBlockCalled, @"Second block should not be called yet");
	
    firstBlockCalled = NO;
    [testObj rz_removeObserver:self keyPath:nil];
	
    otherTestObj.aString = @"yo";
	
    XCTAssertTrue(secondBlockCalled, @"Second block should have been called. Removal as observer for first obj should not affect this one");
	[otherTestObj rz_removeObserver:self keyPath:nil];
}

@end
