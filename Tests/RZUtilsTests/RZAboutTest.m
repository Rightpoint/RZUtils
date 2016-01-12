//
//  RZAboutTest.m
//  RZUtilsTests
//
//  Created by Nicholas Bonatsakis on 1/6/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RZAbout.h"

@interface RZAboutTest : XCTestCase

@end

@implementation RZAboutTest

- (void)testInstance
{
    XCTAssertNotNil([RZAbout shared]);
}

- (void)testLogoView
{
    UIView *view = [RZAbout RZLogoViewConstrainedToWidth:320.0f];
    XCTAssertNotNil(view);
    XCTAssertEqual(view.bounds.size.width, 320.0f);
}

- (void)testInfo
{
    XCTAssertNotNil([RZAbout appName]);
    XCTAssertNotNil([RZAbout appInfoText]);
    XCTAssertNotNil([RZAbout appBuild]);
    XCTAssertNotNil([RZAbout appVersion]);
}

@end
