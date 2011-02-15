//
//  RZWebViewController.m
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

#import "RZWebViewController.h"

@interface RZWebViewController () <UIWebViewDelegate>

@property (nonatomic, copy) NSURL *webContentURL;

@property (nonatomic, weak) UIBarButtonItem *backButtonItem;
@property (nonatomic, weak) UIBarButtonItem *forwardButtonItem;
@property (nonatomic, weak) UIBarButtonItem *refreshButtonItem;

@property (nonatomic, strong, readwrite) UIWebView *webView;
@property (nonatomic, strong, readwrite) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) BOOL showsToolbar;
@property (nonatomic, assign) BOOL scalesPages;

- (void)initializeView;
- (void)updateBackForwardButtons;
- (void)sharePressed;

@end

@implementation RZWebViewController

- (id)initWithPathForResource:(NSString *)resource toolbar:(BOOL)showToolbar scalePageToFit:(BOOL)scalePageToFit
{
    self = [super init];
    if (self)
    {
        // For now we are assuming that everything is HTML.  In the future we may want to allow the ability to specify this.
        self.webContentURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:resource ofType:@"html"] isDirectory:NO];
        self.showsToolbar = showToolbar;
        self.scalesPages = scalePageToFit;
    }
    return self;
}

- (id)initWithRemoteURL:(NSURL *)webURL toolbar:(BOOL)showToolbar scalePageToFit:(BOOL)scalePageToFit
{
    self = [super init];
    if (self)
    {
        self.webContentURL = webURL;
        self.showsToolbar = showToolbar;
        self.scalesPages = scalePageToFit;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.showsToolbar && self.navigationController)
    {
        [self.navigationController setToolbarHidden:NO animated:animated];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.activityIndicator.center = CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.5);
}

- (void)dealloc
{
    //Required
    self.webView.delegate = nil;
}

#pragma mark - Private

- (void)initializeView
{
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.frame = self.view.bounds;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.webView.scalesPageToFit = self.scalesPages;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] init];
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.center = self.webView.center;
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.view addSubview:self.activityIndicator];
    
    // Toolbar items
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self.webView action:@selector(reload)];
    UIBarButtonItem *middleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"◄" style:UIBarButtonItemStylePlain target:self.webView action:@selector(goBack)];
    UIBarButtonItem *bfSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    bfSpace.width = 40.f;
    UIBarButtonItem *fwdItem = [[UIBarButtonItem alloc] initWithTitle:@"►" style:UIBarButtonItemStylePlain target:self.webView action:@selector(goForward)];
    
    self.refreshButtonItem = refreshItem;
    self.backButtonItem = backItem;
    self.forwardButtonItem = fwdItem;
    
    self.toolbarItems = @[refreshItem, middleSpace, backItem, bfSpace, fwdItem];
}

- (void)updateBackForwardButtons
{
    self.backButtonItem.enabled     = self.webView.canGoBack;
    self.forwardButtonItem.enabled  = self.webView.canGoForward;
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
    self.refreshButtonItem.enabled = NO;
    [self updateBackForwardButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    self.refreshButtonItem.enabled = YES;
    [self updateBackForwardButtons];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewControllerDidFinishLoad:)])
    {
        [self.delegate webViewControllerDidFinishLoad:self];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    self.refreshButtonItem.enabled = YES;
    [self updateBackForwardButtons];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

@end
