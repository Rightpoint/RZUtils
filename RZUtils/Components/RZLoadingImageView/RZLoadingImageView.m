//
//  RZLoadingImageView.m
//
//  Created by Nicholas Donaldson on 9/24/12.

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

#import "RZLoadingImageView.h"
#import <QuartzCore/QuartzCore.h>


#define kTransitionTime 0.25

@interface RZLoadingImageView ()

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, retain) UIActivityIndicatorView *loadingSpinner;

- (void)showPlaceholder;

- (void)commonInit;

@end

@implementation RZLoadingImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFit;
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.imageRenderingMode = UIImageRenderingModeAutomatic;
    self.showPlaceholderOnError = YES;
    self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingSpinner.hidesWhenStopped = YES;
    [self.loadingSpinner stopAnimating];
    [self addSubview:self.loadingSpinner];
}

- (void)dealloc
{
    [self cancelRequest];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.loadingSpinner.center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
}

- (void)setLoading:(BOOL)loading
{
    if (loading)
    {
        self.image = nil;
        [self.loadingSpinner startAnimating];
    }
    else
    {
        [self.loadingSpinner stopAnimating];
    }
}

- (void)loadImageFromPath:(NSString *)path
{
    [self loadImageFromPath:path decompress:YES];
}

- (void)loadImageFromPath:(NSString *)path decompress:(BOOL)decompress
{
    [self loadImageFromPath:path resizeToSize:CGSizeZero preserveAspectRatio:YES decompress:decompress];
}

- (void)loadImageFromPath:(NSString *)path resizeToSize:(CGSize)newSize preserveAspectRatio:(BOOL)preserveAspect decompress:(BOOL)decompress
{
    [self loadImageFromPath:path resizeToSize:newSize preserveAspectRatio:preserveAspect checkForUpdates:NO decompress:decompress];
}

- (void)loadImageFromPath:(NSString *)path resizeToSize:(CGSize)newSize preserveAspectRatio:(BOOL)preserveAspect checkForUpdates:(BOOL)updates decompress:(BOOL)decompress
{
    [self cancelRequest];

    if (path == nil){
        [self showPlaceholder];
        return;
    }

    [self setLoading:YES];

    self.imageURL = [[RZImageCache sharedCache] downloadImageFromPath:path decompress:decompress resizeToSize:newSize preserveAspectRatio:preserveAspect checkForUpdates:updates delegate:self];
}

- (void)loadImageFromURL:(NSURL *)url
{
    [self loadImageFromURL:url decompress:YES];
}

- (void)loadImageFromURL:(NSURL *)url decompress:(BOOL)decompress
{
    [self loadImageFromURL:url decompress:decompress checkForUpdates:NO];
}

- (void)loadImageFromURL:(NSURL*)url decompress:(BOOL)decompress checkForUpdates:(BOOL)checkForUpdates
{
    [self cancelRequest];
    
    if (url == nil){
        [self showPlaceholder];
        return;
    }
    
    [self setLoading:YES];
    
    self.imageURL = url;
    [[RZImageCache sharedCache] downloadImageFromURL:url decompress:decompress resizeToSize:CGSizeZero preserveAspectRatio:YES checkForUpdates:checkForUpdates delegate:self];
}

- (void)setImage:(UIImage *)image animated:(BOOL)animated
{
    if ([image respondsToSelector:@selector(imageWithRenderingMode:)])
    {
        image = [image imageWithRenderingMode:self.imageRenderingMode];
    }
    if (animated){
        
        self.image = image;
        
        CGFloat initialAlpha = self.alpha;
        
        self.alpha = 0.f;
        
        [UIView animateWithDuration:kTransitionTime
                        animations:^{
                            self.alpha = initialAlpha;
                        }];
    }
    else{
        self.image = image;
    }

    [self setLoading:NO];
}

- (void)cancelRequest
{
    if (self.imageURL){
        [[RZImageCache sharedCache] cancelImageDownloadFromURL:self.imageURL withDelegate:self];
        self.imageURL = nil;
    }

    [self setImage:nil animated:NO];
}

- (void)showPlaceholder
{
    if (self.errorPlaceholderImage != nil && self.showPlaceholderOnError){
        self.contentMode = (self.errorPlaceholderImage.size.width > self.bounds.size.width || self.errorPlaceholderImage.size.height > self.bounds.size.height) ? UIViewContentModeScaleAspectFit : UIViewContentModeCenter;
        [self setImage:self.errorPlaceholderImage animated:YES];
    }
    else{
        [self setImage:nil animated:NO];
    }
}

#pragma mark - RZImageCache delegate

- (void)imageCacheFinishedLoadingImage:(UIImage *)image fromURL:(NSURL *)url wasCached:(BOOL)wasCached
{        
    [self setImage:image animated:!wasCached];
    [self setLoading:NO];
    
    if ([self.delegate respondsToSelector:@selector(loadingImageView:finishedLoadingURL:)])
    {
        [self.delegate loadingImageView:self finishedLoadingURL:url];
    }
}

- (void)imageCacheFailedToLoadImageFromURL:(NSURL *)url error:(NSError *)error
{        
    self.imageURL = nil;
    [self setLoading:NO];
    [self showPlaceholder];
    
    if ([self.delegate respondsToSelector:@selector(loadingImageView:failedToLoadURL:)])
    {
        [self.delegate loadingImageView:self failedToLoadURL:url];
    }
}
@end
