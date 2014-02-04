//
//  RZWebViewController.h
//  Raizlabs
//
//  Created by Alex Rouse on 11/12/13.
//  Copyright (c) 2013 Raizlabs. 
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

// These will return nil until the VC is loaded. DO NOT change the delegate on the webview.
@property (nonatomic, strong, readonly) UIWebView *webView;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicator;

// Intialize the webview with a localFile in the bundle
- (id)initWithPathForResource:(NSString*)resource
                      toolbar:(BOOL)showToolbar
               scalePageToFit:(BOOL)scalePageToFit;

// Intialize the webview with a remote Website URL
- (id)initWithRemoteURL:(NSURL*)webURL
                toolbar:(BOOL)showToolbar
         scalePageToFit:(BOOL)scalePageToFit;


@end


@protocol RZWebViewControllerDelegate <NSObject>

@optional
- (void)webViewControllerDidFinishLoad:(RZWebViewController *)webVC;

@end
