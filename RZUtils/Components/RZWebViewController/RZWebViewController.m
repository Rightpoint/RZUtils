//
//  RZWebViewController.m
//  Raizlabs
//
//  Created by Alex Rouse on 11/12/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "RZWebViewController.h"

@interface RZWebViewController () <UIWebViewDelegate>

@property (nonatomic, copy) NSURL *webContentURL;

- (void)sharePressed;

@end

@implementation RZWebViewController

- (id)initWithPathForResource:(NSString *)resource
{
    self = [super init];
    if (self)
    {
        // For now we are assuming that everything is HTML.  In the future we may want to allow the ability to specify this.
        self.webContentURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:resource ofType:@"html"] isDirectory:NO];
    }
    return self;
}
- (id)initWithRemoteURL:(NSURL *)webURL
{
    self = [super init];
    if (self)
    {
        self.webContentURL = webURL;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeView];
    
    if (self.webContentURL)
    {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.webContentURL]];
    }

    if(self.allowsSharing)
    {
        UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sharePressed)];
        self.navigationItem.rightBarButtonItem = shareItem;
    }
}

- (void)dealloc
{
    //Required
    self.webView.delegate = nil;
}

- (void)initializeView
{
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.webView];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] init];
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.center = self.webView.center;
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.view addSubview:self.activityIndicator];
}

- (void)sharePressed
{
    UIActivityViewController *shareVC = [[UIActivityViewController alloc] initWithActivityItems:self.sharingItems applicationActivities:nil];
    shareVC.excludedActivityTypes = self.excludedActivityTypes;
    [self presentViewController:shareVC animated:YES completion:nil];
}

#pragma mark - WebView Delegate Methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (!self.allowsWebNavigation)
    {
        return navigationType == UIWebViewNavigationTypeOther;
    }
    
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden = NO;
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewControllerDidFinishLoad:)])
    {
        [self.delegate webViewControllerDidFinishLoad:self];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

@end
