//
//  RZWebViewController.h
//  Raizlabs
//
//  Created by Alex Rouse on 11/12/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

// A simple webview for displaying local/remote HTML content.
#import <UIKit/UIKit.h>

@protocol RZWebViewControllerDelegate;

@interface RZWebViewController : UIViewController

@property (weak, nonatomic) id<RZWebViewControllerDelegate> delegate;

// Should the webview be alloud to open additional links
@property (nonatomic, assign) BOOL allowsWebNavigation;

// Allows sharing of the website.
@property (nonatomic, assign) BOOL allowsSharing;
@property (nonatomic, strong) NSArray *sharingItems;
@property (nonatomic, strong) NSArray *excludedActivityTypes;

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

// Intialize the webview with a localFile in the bundle
- (id)initWithPathForResource:(NSString *)resource;

// Intialize the webview with a remote Website URL
- (id)initWithRemoteURL:(NSURL *)webURL;


@end


@protocol RZWebViewControllerDelegate <NSObject>

@optional
- (void)webViewControllerDidFinishLoad:(RZWebViewController *)webVC;

@end