//
//  RZAutoLayoutTests.m
//  RZUtilsTests
//
//  Created by Michael Gorbach on 8/5/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <RZUtils/UIView+RZAutoLayoutHelpers.h>

@interface RZAutoLayoutTests : XCTestCase

@end

@implementation RZAutoLayoutTests

- (void)testReturnsSingleView
{
    UIView *singleView = [[UIView alloc] initWithFrame:CGRectZero];
    XCTAssertEqual([UIView rz_commonAncestorForViews:@[singleView]], singleView);
}

- (void)testTwoUnrelatedViews
{
    UIView *alphaView = [[UIView alloc] initWithFrame:CGRectZero];
    UIView *betaView = [[UIView alloc] initWithFrame:CGRectZero];

    UIView *commonAncestor = [UIView rz_commonAncestorForViews:@[alphaView, betaView]];
    XCTAssertNil(commonAncestor);
}

- (void)testParentChildOrder1
{
    UIView *alphaView = [[UIView alloc] initWithFrame:CGRectZero];
    UIView *betaView = [[UIView alloc] initWithFrame:CGRectZero];
    [alphaView addSubview:betaView];

    UIView *commonAncestor = [UIView rz_commonAncestorForViews:@[alphaView, betaView]];
    XCTAssertEqual(commonAncestor, alphaView);

    commonAncestor = [UIView rz_commonAncestorForViews:@[betaView, alphaView]];
    XCTAssertEqual(commonAncestor, alphaView);
}

- (void)testParentChildAndUnrelated
{
    UIView *alphaView = [[UIView alloc] initWithFrame:CGRectZero];
    UIView *betaView = [[UIView alloc] initWithFrame:CGRectZero];
    [alphaView addSubview:betaView];

    UIView *gammaView = [[UIView alloc] initWithFrame:CGRectZero];

    UIView *commonAncestor = [UIView rz_commonAncestorForViews:@[betaView, alphaView, gammaView]];
    XCTAssertNil(commonAncestor);
}

- (void)testMultipleLevels
{
    UIView *a = [[UIView alloc] initWithFrame:CGRectZero];

    UIView *b = [[UIView alloc] initWithFrame:CGRectZero];
    [a addSubview:b];

    UIView *c = [[UIView alloc] initWithFrame:CGRectZero];
    [b addSubview:c];

    UIView *d = [[UIView alloc] initWithFrame:CGRectZero];
    [c addSubview:d];

    UIView *e = [[UIView alloc] initWithFrame:CGRectZero];
    [a addSubview:e];

    UIView *f = [[UIView alloc] initWithFrame:CGRectZero];
    [b addSubview:f];

    UIView *commonAncestor = [UIView rz_commonAncestorForViews:@[a, c]];
    XCTAssertEqual(commonAncestor, a);

    commonAncestor = [UIView rz_commonAncestorForViews:@[c, e]];
    XCTAssertEqual(commonAncestor, a);

    commonAncestor = [UIView rz_commonAncestorForViews:@[d, f]];
    XCTAssertEqual(commonAncestor, b);

    commonAncestor = [UIView rz_commonAncestorForViews:@[d, e]];
    XCTAssertEqual(commonAncestor, a);
}

@end
