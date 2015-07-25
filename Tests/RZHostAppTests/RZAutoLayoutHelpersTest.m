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

static CGFloat RZAutoLayoutHelpersTestContainerWidth    = 1000.0f;
static CGFloat RZAutoLayoutHelpersTestContainerHeight   = 1000.0f;
static CGFloat RZAutoLayoutHelpersTestCenterOffset      = 22.0f;
static CGFloat RZAutoLayoutHelpersTestAllowableDelta    = 0.5f;

@interface RZAutoLayoutHelpersContainerView : UIView

@end

@implementation RZAutoLayoutHelpersContainerView

- (CGSize)intrinsicContentSize {
    return CGSizeMake(RZAutoLayoutHelpersTestContainerWidth, RZAutoLayoutHelpersTestContainerHeight);
}

@end

@interface RZTestViewOne : UIView

@end

@implementation RZTestViewOne

- (CGSize)intrinsicContentSize {
    return CGSizeMake(250.0f, 250.0f);
}

@end

@interface RZTestViewTwo : UIView

@end

@implementation RZTestViewTwo

- (CGSize)intrinsicContentSize {
    return CGSizeMake(175.0f, 330.0f);
}

@end

@interface RZUtilsTestAppTests : XCTestCase

@property (nonatomic) RZAutoLayoutHelpersContainerView *containerView;
@property (nonatomic) RZTestViewOne *testViewOne;
@property (nonatomic) RZTestViewTwo *testViewTwo;

@end

@implementation RZUtilsTestAppTests

- (void)setUp
{
    [super setUp];
    
    self.containerView = [[RZAutoLayoutHelpersContainerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, RZAutoLayoutHelpersTestContainerWidth, RZAutoLayoutHelpersTestContainerHeight)];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.testViewOne = [[RZTestViewOne alloc] init];
    self.testViewTwo = [[RZTestViewTwo alloc] init];
    self.testViewOne.translatesAutoresizingMaskIntoConstraints = NO;
    self.testViewTwo.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    
    XCTAssertEqualWithAccuracy(frameOne.origin.x, 375.0f, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(frameOne.origin.y, 375.0f, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(frameOne.size.width, 250.0f, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(frameOne.size.height, 250.0f, RZAutoLayoutHelpersTestAllowableDelta);
    
    XCTAssertEqualWithAccuracy(CGRectGetMidX(frameOne), 500.0f, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(CGRectGetMidY(frameOne), 500.0f, RZAutoLayoutHelpersTestAllowableDelta);
    
    CGRect frameTwo = self.testViewTwo.frame;
    
    XCTAssertEqualWithAccuracy(frameTwo.origin.x, 412.5f, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(frameTwo.origin.y, 335.0f, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(frameTwo.size.width, 175.0f, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(frameTwo.size.height, 330.0f, RZAutoLayoutHelpersTestAllowableDelta);
    
    XCTAssertEqualWithAccuracy(CGRectGetMidX(frameTwo), 500.0f, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(CGRectGetMidY(frameTwo), 500.0f, RZAutoLayoutHelpersTestAllowableDelta);
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
    
    XCTAssertEqualWithAccuracy(frameOne.origin.x, 397.0f, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(frameOne.origin.y, 397.0f, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(frameOne.size.width, 250.0f, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(frameOne.size.height, 250.0f, RZAutoLayoutHelpersTestAllowableDelta);
    
    XCTAssertEqualWithAccuracy(CGRectGetMidX(frameOne), 522.0f, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(CGRectGetMidY(frameOne), 522.0f, RZAutoLayoutHelpersTestAllowableDelta);
    
    CGRect frameTwo = self.testViewTwo.frame;
    
    XCTAssertEqualWithAccuracy(frameTwo.origin.x, 434.5f, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(frameTwo.origin.y, 357.0f, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(frameTwo.size.width, 175.0f, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(frameTwo.size.height, 330.0f, RZAutoLayoutHelpersTestAllowableDelta);
    
    XCTAssertEqualWithAccuracy(CGRectGetMidX(frameTwo), 522.0f, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(CGRectGetMidY(frameTwo), 522.0f, RZAutoLayoutHelpersTestAllowableDelta);
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
    
    XCTAssertEqualWithAccuracy(frameOne.origin.x, 0.0f, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(frameOne.origin.y, 0.0f, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(frameOne.size.width, RZAutoLayoutHelpersTestContainerWidth, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(frameOne.size.height, RZAutoLayoutHelpersTestContainerHeight, RZAutoLayoutHelpersTestAllowableDelta);
    
    CGRect frameTwo = self.testViewTwo.frame;
    
    XCTAssertEqualWithAccuracy(frameTwo.origin.x, 17.0f, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(frameTwo.origin.y, 21.0f, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(frameTwo.size.width, 962.0f, RZAutoLayoutHelpersTestAllowableDelta);
    XCTAssertEqualWithAccuracy(frameTwo.size.height, 962.0f, RZAutoLayoutHelpersTestAllowableDelta);
    
    XCTAssertEqualWithAccuracy(frameTwo.origin.x, 17.0f, RZAutoLayoutHelpersTestAllowableDelta);
}

@end
