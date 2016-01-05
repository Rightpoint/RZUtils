//
//  RZAbout.h
//  RZUtils
//
//  Created by Nicholas Bonatsakis on 2/25/15.
//  Copyright (c) 2016 Raizlabs Inc. All rights reserved.
//

// Copyright 2016 Raizlabs and other contributors
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

@import Foundation;
@import MessageUI;

typedef void(^RZAboutSendFeedbackBlock)(MFMailComposeResult mailResult, NSError *error);

@interface RZAbout : NSObject

///-----------------------------------------
/// @name General
///-----------------------------------------

+ (instancetype)shared;

///-----------------------------------------
/// @name Send Feedback
///-----------------------------------------

/**
 *  Show a standard "Send Feedback" e-mail sheet. Note: This method will ensure that the mail nav bar looks presentable by doing devious things 
 *  with UIAppearance.
 *
 *  @param viewController The view controller onto which to present the mail controller
 *  @param email          The e-mail address to send the message to.
 *  @param tintColor      The tint color to use for the mail nav bar.
 *  @param completion     An optional completion block to be invoked upon mail action.
 */
- (void)presentSendFeedbackInController:(UIViewController *)viewController email:(NSString *)email tintColor:(UIColor *)tintColor completion:(RZAboutSendFeedbackBlock)completion;

///-----------------------------------------
/// @name Share App
///-----------------------------------------

/**
 *  Show a share sheet for sharing the app from the provided view controller.
 *
 *  @param viewController The view controller from which to present the sheet
 *  @param shareText      The text of the share message
 *  @param shareURL       The URL of the app, likely either the app store URL or a landing page
 */
- (void)presentShareAppInController:(UIViewController *)viewController shareText:(NSString *)shareText shareURL:(NSURL *)shareURL;

/**
 *  Show a share sheet for sharing the app from the provided view controller, allows for specifying iPad anchor and frame.
 *
 *  @param viewController The view controller from which to present the sheet
 *  @param shareText      The text of the share message
 *  @param shareURL       The URL of the app, likely either the app store URL or a landing page
 *  @param anchorView     The view in which to present the sheet (iPad only)
 *  @param frame          The frame in which to anchor the popover (iPad only)
 */
- (void)presentShareAppInController:(UIViewController *)viewController shareText:(NSString *)shareText shareURL:(NSURL *)shareURL anchorViewForPad:(UIView *)anchorView anchorFrame:(CGRect)frame;

///-----------------------------------------
/// @name Built By RZ
///-----------------------------------------

/**
 *  Returns an initialized view containing the RZ logo and build version/number
 *
 *  @param maxWidth The width of the view where you'll place this view.
 */
+ (UIView *)RZLogoViewConstrainedToWidth:(CGFloat)maxWidth;

///-----------------------------------------
/// @name App Info
///-----------------------------------------

/**
 *  iOS Version
 */
+ (NSString *)systemVersion;

/**
 *  The app display name.
 */
+ (NSString *)appName;

/**
 *  App version (short version)
 */
+ (NSString *)appVersion;

/**
 *  App build number
 */
+ (NSString *)appBuild;

/**
 *  A system summary info string.
 */
+ (NSString *)appInfoText;

/**
 *  The raw device model.
 */
+ (NSString *)deviceModel;

@end
