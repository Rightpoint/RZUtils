//
//  RZAbout.m
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

@import UIKit;
#import "RZAbout.h"
#import <sys/utsname.h>
#import "RZNavBarStyle.h"

@implementation RZAboutMailController

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.savedNavBarStyle restoreAppearanceState];
}

@end

@interface RZAbout () <MFMailComposeViewControllerDelegate>
@property (copy, nonatomic) RZAboutSendFeedbackBlock feedbackBlock;
@end

@implementation RZAbout

#pragma mark - General

+ (instancetype)shared
{
    static id s = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s = [[[self class] alloc] init];
    });

    return s;
}

#pragma mark - Send Feedback

- (void)presentSendFeedbackInController:(UIViewController *)viewController email:(NSString *)email tintColor:(UIColor *)tintColor completion:(RZAboutSendFeedbackBlock)completion
{
    NSParameterAssert(viewController);
    NSParameterAssert(viewController.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPhone);
    NSParameterAssert(email);

    self.feedbackBlock = completion;

    NSString *subject = [NSString stringWithFormat:NSLocalizedString(@"%@ (%@) Feedback", @"E-mail feedback subject format."),
                                                                     [[self class] appName],
                                                                     [[self class] appVersion]];
    NSString *body = [NSString stringWithFormat:@"\n\n\n-----\nVersion: %@ (%@)\nDevice: %@\n",
                      [[self class] appVersion],
                      [[self class] appBuild],
                      [[self class] deviceModel]];

    RZNavBarStyle *navBarStyle = [RZNavBarStyle saveAppearanceState];
    [RZNavBarStyle clearAppearanceState];

    RZAboutMailController *mailVC = [[RZAboutMailController alloc] init];

    mailVC.savedNavBarStyle = navBarStyle;
    mailVC.navigationBar.tintColor = tintColor;

    [mailVC setToRecipients:@[email]];
    [mailVC setSubject:subject];
    [mailVC setMessageBody:body isHTML:NO];

    mailVC.mailComposeDelegate = self;

    [viewController presentViewController:mailVC animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (self.feedbackBlock) {
        self.feedbackBlock(result, error);
    }

    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Sharing

- (void)presentShareAppInController:(UIViewController *)viewController shareText:(NSString *)shareText shareURL:(NSURL *)shareURL
{
    [self presentShareAppInController:viewController shareText:shareText shareURL:shareURL anchorViewForPad:nil anchorFrame:CGRectNull];
}

- (void)presentShareAppInController:(UIViewController *)viewController shareText:(NSString *)shareText shareURL:(NSURL *)shareURL anchorViewForPad:(UIView *)anchorView anchorFrame:(CGRect)frame
{
    NSParameterAssert(viewController);
    NSParameterAssert(shareText);
    NSParameterAssert(shareURL);

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[shareText, shareURL] applicationActivities:nil];

    if (anchorView) {
        activityVC.popoverPresentationController.sourceView = anchorView;
        activityVC.popoverPresentationController.sourceRect = frame;
    }

    [viewController presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - Built by RZ

+ (UIView *)RZLogoViewConstrainedToWidth:(CGFloat)maxWidth
{
    CGFloat viewHeight = 140.0f;
    CGFloat imageHeight = 40.0f;
    CGFloat labelHeight = 30.0f;

    UIView *logoView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, maxWidth, viewHeight)];
    logoView.backgroundColor = [UIColor clearColor];

    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, viewHeight - labelHeight - imageHeight, logoView.frame.size.width, imageHeight)];
    logoImageView.backgroundColor = [UIColor clearColor];
    logoImageView.contentMode = UIViewContentModeCenter;
    logoImageView.accessibilityLabel = NSLocalizedString(@"Designed and developed by Raizlabs.", @"Indication that this app was designed and developed by Raizlabs");
    logoImageView.isAccessibilityElement = YES;
    logoImageView.accessibilityTraits = UIAccessibilityTraitNone;

    NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"logo-built-by-RZ" withExtension:@"png"];
    if (imageURL != nil) {
        logoImageView.image = [UIImage imageWithContentsOfFile:[imageURL path]];
    }

    [logoView addSubview:logoImageView];

    UILabel *buildLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, viewHeight - labelHeight, logoView.frame.size.width, labelHeight)];
    buildLabel.backgroundColor = [UIColor clearColor];
    buildLabel.textAlignment = NSTextAlignmentCenter;
    buildLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.51 alpha:1];
    buildLabel.font =  [UIFont systemFontOfSize:15.0f];
    buildLabel.text = [NSString stringWithFormat:@"%@ (%@)", [[self class] appVersion], [[self class] appBuild]];
    buildLabel.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"Version %@ build %@", @"Accessible version of app version and build number label"), [[self class] accessibleAppVersion], [[self class] appBuild]];
    [logoView addSubview:buildLabel];

    return logoView;
}

#pragma mark - App Info

+ (NSString *)systemVersion
{
    return [UIDevice currentDevice].systemVersion ?: NSLocalizedString(@"Unknown", nil);
}

+ (NSString *)appName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] ?: @"Unknown";
}

+ (NSString *)appVersion
{
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: @"Unknown";
}

+ (NSString *)accessibleAppVersion
{
    if (UIAccessibilityIsVoiceOverRunning()) {
        return [[[self appVersion] componentsSeparatedByString:@"."] componentsJoinedByString:NSLocalizedString(@" point ", @"The spelled out version of the “point” in version numbers, like 2 point 0 point 1, with spaces on either side")];
    }
    else {
        return [self appVersion];
    }
}

+ (NSString *)appBuild
{
    return [[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey] ?: NSLocalizedString(@"Unknown", nil);
}

+ (NSString *)deviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return @(systemInfo.machine) ?: NSLocalizedString(@"Unknown", nil);
}

+ (NSString *)appInfoText
{
    NSString *str = @"";
    str = [str stringByAppendingFormat:NSLocalizedString(@"App Version %@\n", nil), [self appVersion]];
    str = [str stringByAppendingFormat:NSLocalizedString(@"iOS Version: %@", nil), [self systemVersion]];

    return str;
}

@end
