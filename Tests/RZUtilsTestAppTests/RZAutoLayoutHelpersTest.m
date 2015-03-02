//
//  RZAutoLayoutHelpersTest.m
//
//  Created by Sean O'Shea on 3/1/15.

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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "UIView+RZAutoLayoutHelpers.h"

@interface RZAutoLayoutHelpersContainerView : UIView

@end

@implementation RZAutoLayoutHelpersContainerView

@end

@interface RZUtilsTestAppTests : XCTestCase

@property (nonatomic) RZAutoLayoutHelpersContainerView *containerView;
@property (nonatomic) UIView *testViewOne;
@property (nonatomic) UIView *testViewTwo;

@end

static CGFloat RZAutoLayoutHelpersTestContainerWidth    = 1000.0f;
static CGFloat RZAutoLayoutHelpersTestContainerHeight   = 1000.0f;
static CGFloat RZAutoLayoutHelpersTestCenterOffset      = 22.0f;

static CGFloat RZAutoLayoutHelpersTestAllowableDelta    = 1.0f;

@implementation RZUtilsTestAppTests

- (void)setUp
{
    [super setUp];
    
    self.containerView = [[RZAutoLayoutHelpersContainerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, RZAutoLayoutHelpersTestContainerWidth, RZAutoLayoutHelpersTestContainerHeight)];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.testViewOne = [[UIView alloc] init];
    self.testViewTwo = [[UIView alloc] init];
    self.testViewOne.translatesAutoresizingMaskIntoConstraints = NO;
    self.testViewTwo.translatesAutoresizingMaskIntoConstraints = NO;
    [self.testViewOne rz_pinSizeTo:CGSizeMake(250.0f, 250.0f)];
    [self.testViewTwo rz_pinSizeTo:CGSizeMake(175.0f, 330.0f)];
    
    [self.containerView addSubview:self.testViewOne];
    [self.containerView addSubview:self.testViewTwo];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)forceConstraintsEvaluation
{
    [self forceConstraintsEvaluationForAllSubviewsOfView:self.containerView];
}

- (void)forceConstraintsEvaluationForAllSubviewsOfView:(UIView *)view
{
    for (UIView *subview in view.subviews) {
        [self forceConstraintsEvaluationForAllSubviewsOfView:subview];
    }
    [view layoutIfNeeded];
}

- (void)testCenteringViews
{
    [self.testViewOne rz_centerHorizontallyInContainer];
    [self.testViewOne rz_centerVerticallyInContainer];
    [self.testViewTwo rz_centerHorizontallyInContainer];
    [self.testViewTwo rz_centerVerticallyInContainer];
    
    [self forceConstraintsEvaluation];
    
    XCTAssert([self.testViewOne rz_pinnedCenterXConstraint] != nil);
    XCTAssert([self.testViewOne rz_pinnedCenterYConstraint] != nil);
    XCTAssert([self.testViewTwo rz_pinnedCenterXConstraint] != nil);
    XCTAssert([self.testViewTwo rz_pinnedCenterYConstraint] != nil);
    
    CGRect frameOne = self.testViewOne.frame;
    
    XCTAssert([self roundedEquals:frameOne.origin.x valueTwo:375.0f]);
    XCTAssert([self roundedEquals:frameOne.origin.y valueTwo:375.0f]);
    XCTAssert([self roundedEquals:frameOne.size.width valueTwo:250.0f]);
    XCTAssert([self roundedEquals:frameOne.size.height valueTwo:250.0f]);
    
    XCTAssert([self roundedEquals:CGRectGetMidX(frameOne) valueTwo:500.0f]);
    XCTAssert([self roundedEquals:CGRectGetMidY(frameOne) valueTwo:500.0f]);
    
    CGRect frameTwo = self.testViewTwo.frame;
    
    XCTAssert([self roundedEquals:frameTwo.origin.x valueTwo:412.5f]);
    XCTAssert([self roundedEquals:frameTwo.origin.y valueTwo:335.0f]);
    XCTAssert([self roundedEquals:frameTwo.size.width valueTwo:175.0f]);
    XCTAssert([self roundedEquals:frameTwo.size.height valueTwo:330.0f]);
    
    XCTAssert([self roundedEquals:CGRectGetMidX(frameTwo) valueTwo:500.0f]);
    XCTAssert([self roundedEquals:CGRectGetMidY(frameTwo) valueTwo:500.0f]);
}

- (void)testCenteringWithOffsetViews
{
    [self.testViewOne rz_centerHorizontallyInContainerWithOffset:RZAutoLayoutHelpersTestCenterOffset];
    [self.testViewOne rz_centerVerticallyInContainerWithOffset:RZAutoLayoutHelpersTestCenterOffset];
    [self.testViewTwo rz_centerHorizontallyInContainerWithOffset:RZAutoLayoutHelpersTestCenterOffset];
    [self.testViewTwo rz_centerVerticallyInContainerWithOffset:RZAutoLayoutHelpersTestCenterOffset];
    
    [self forceConstraintsEvaluation];
    
    XCTAssert([self.testViewOne rz_pinnedCenterXConstraint] != nil);
    XCTAssert([self.testViewOne rz_pinnedCenterYConstraint] != nil);
    XCTAssert([self.testViewTwo rz_pinnedCenterXConstraint] != nil);
    XCTAssert([self.testViewTwo rz_pinnedCenterYConstraint] != nil);
    
    CGRect frameOne = self.testViewOne.frame;
    
    XCTAssert([self roundedEquals:frameOne.origin.x valueTwo:397.0f]);
    XCTAssert([self roundedEquals:frameOne.origin.y valueTwo:397.0f]);
    XCTAssert([self roundedEquals:frameOne.size.width valueTwo:250.0f]);
    XCTAssert([self roundedEquals:frameOne.size.height valueTwo:250.0f]);
    
    XCTAssert([self roundedEquals:CGRectGetMidX(frameOne) valueTwo:522.0f]);
    XCTAssert([self roundedEquals:CGRectGetMidY(frameOne) valueTwo:522.0f]);
    
    CGRect frameTwo = self.testViewTwo.frame;
    
    XCTAssert([self roundedEquals:frameTwo.origin.x valueTwo:434.5f]);
    XCTAssert([self roundedEquals:frameTwo.origin.y valueTwo:357.0f]);
    XCTAssert([self roundedEquals:frameTwo.size.width valueTwo:175.0f]);
    XCTAssert([self roundedEquals:frameTwo.size.height valueTwo:330.0f]);
    
    XCTAssert([self roundedEquals:CGRectGetMidX(frameTwo) valueTwo:522.0f]);
    XCTAssert([self roundedEquals:CGRectGetMidY(frameTwo) valueTwo:522.0f]);
}

- (void)testPinningViews {
    
    [self.testViewOne rz_pinTopSpaceToSuperviewWithPadding:0.0f];
    [self.testViewOne rz_pinRightSpaceToSuperviewWithPadding:0.0f];
    [self.testViewOne rz_pinBottomSpaceToSuperviewWithPadding:0.0f];
    [self.testViewOne rz_pinLeftSpaceToSuperviewWithPadding:0.0f];
    
    [self.testViewTwo rz_pinTopSpaceToSuperviewWithPadding:21.0f];
    [self.testViewTwo rz_pinRightSpaceToSuperviewWithPadding:21.0f];
    [self.testViewTwo rz_pinBottomSpaceToSuperviewWithPadding:17.0f];
    [self.testViewTwo rz_pinLeftSpaceToSuperviewWithPadding:17.0f];
    
    [self forceConstraintsEvaluation];
    
    XCTAssert([self.testViewOne rz_pinnedTopConstraint] != nil);
    XCTAssert([self.testViewOne rz_pinnedRightConstraint] != nil);
    XCTAssert([self.testViewOne rz_pinnedBottomConstraint] != nil);
    XCTAssert([self.testViewOne rz_pinnedLeftConstraint] != nil);
    XCTAssert([self.testViewTwo rz_pinnedTopConstraint] != nil);
    XCTAssert([self.testViewTwo rz_pinnedRightConstraint] != nil);
    XCTAssert([self.testViewTwo rz_pinnedBottomConstraint] != nil);
    XCTAssert([self.testViewTwo rz_pinnedLeftConstraint] != nil);
    
    CGRect frameOne = self.testViewOne.frame;
    
    XCTAssert([self roundedEquals:frameOne.origin.x valueTwo:0.0f]);
    XCTAssert([self roundedEquals:frameOne.origin.y valueTwo:0.0f]);
    XCTAssert([self roundedEquals:frameOne.size.width valueTwo:RZAutoLayoutHelpersTestContainerWidth]);
    XCTAssert([self roundedEquals:frameOne.size.height valueTwo:RZAutoLayoutHelpersTestContainerHeight]);
    
    CGRect frameTwo = self.testViewTwo.frame;
    
    XCTAssert([self roundedEquals:frameTwo.origin.x valueTwo:17.0f]);
    XCTAssert([self roundedEquals:frameTwo.origin.y valueTwo:21.0f]);
    XCTAssert([self roundedEquals:frameTwo.size.width valueTwo:962.0f]);
    XCTAssert([self roundedEquals:frameTwo.size.height valueTwo:962.0f]);
}

- (BOOL)roundedEquals:(CGFloat)valueOne valueTwo:(CGFloat)valueTwo {
    // accommodates for rounding issues which happen when unit tests are run on an iPhone 6 Plus
    return fabs((valueOne) - (valueTwo)) < RZAutoLayoutHelpersTestAllowableDelta;
}

@end
