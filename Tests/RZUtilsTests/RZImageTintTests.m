//
//  RZImageTintTests.m
//  RZUtilsTests
//
//  Created by Zev Eisenberg on 5/11/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <RZUtils/UIImage+RZTint.h>

@interface RZImageTintTests : XCTestCase

@property (strong, nonatomic) UIImage *testImage;

@end

@implementation RZImageTintTests

- (void)setUp
{
    [super setUp];
    self.testImage = [UIImage imageNamed:@"Raizlabs Logo"];
}

- (void)testTinting
{
    XCTAssertNotNil(self.testImage);

    NSData *testData = UIImagePNGRepresentation(self.testImage);

    UIImage *blueImage1 = [self.testImage rz_tintedImageWithColor:[UIColor blueColor]];
    NSData *blueData1 = UIImagePNGRepresentation(blueImage1);

    XCTAssertNotEqualObjects(testData, blueData1, @"A tinted image should not be the same as the original, unless the original has changed since this test was written");

    UIImage *redImage = [blueImage1 rz_tintedImageWithColor:[UIColor redColor]];
    NSData *redData = UIImagePNGRepresentation(redImage);

    XCTAssertNotEqualObjects(blueData1, redData, @"Two of the same image, tinted with different colors, should not be equal");

    UIImage *blueImage2 = [redImage rz_tintedImageWithColor:[UIColor blueColor]];
    NSData *blueData2 = UIImagePNGRepresentation(blueImage2);

    XCTAssertEqualObjects(blueData1, blueData2, @"An image, tinted a different color and then tinted the original color again, should result in the same image");
}

- (void)testAttributes
{
    XCTAssertNotNil(self.testImage);

    UIEdgeInsets capInsets = UIEdgeInsetsMake(1.0f, 2.0f, 5.0f, 3.0f);
    UIEdgeInsets alignmentRectInsets = UIEdgeInsetsMake(5.0f, 4.0f, 3.0f, 2.0f);
    UIImageResizingMode resizingMode = UIImageResizingModeStretch;
    UIImage *testImageWithAttributes = [self.testImage resizableImageWithCapInsets:capInsets resizingMode:resizingMode];
    testImageWithAttributes = [testImageWithAttributes imageWithAlignmentRectInsets:alignmentRectInsets];
    NSData *dataWithAttributes = UIImagePNGRepresentation(testImageWithAttributes);

    // first check assumptions about how these properties work
    XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(capInsets, testImageWithAttributes.capInsets));
    XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(alignmentRectInsets, testImageWithAttributes.alignmentRectInsets));
    XCTAssertEqual(resizingMode, testImageWithAttributes.resizingMode);

    // make sure the attributes survive the tinting of the image
    UIImage *tintedImage = [testImageWithAttributes rz_tintedImageWithColor:[UIColor purpleColor]];
    NSData *tintedData = UIImagePNGRepresentation(tintedImage);
    XCTAssertNotEqualObjects(dataWithAttributes, tintedData);

    XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(capInsets, tintedImage.capInsets));
    XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(alignmentRectInsets, tintedImage.alignmentRectInsets));
    XCTAssertEqual(resizingMode, tintedImage.resizingMode);
}

- (void)testNonOpaqueColor
{
    XCTAssertNotNil(self.testImage);

    NSData *testData = UIImagePNGRepresentation(self.testImage);

    UIImage *alphaTintedImage = [self.testImage rz_tintedImageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5f]];
    NSData *alphaTintedData = UIImagePNGRepresentation(alphaTintedImage);
    XCTAssertNotEqualObjects(testData, alphaTintedData, @"An image tinted with a color whose alpha component is not 1 should be different from the original");
}

@end
