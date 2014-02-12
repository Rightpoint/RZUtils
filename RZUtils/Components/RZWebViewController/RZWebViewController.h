//
//  RZWebViewController.h
//  Raizlabs
//
//  Created by Alex Rouse on 11/12/13.

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
