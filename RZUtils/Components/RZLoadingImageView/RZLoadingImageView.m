//
//  RZLoadingImageView.m
//
//  Created by Nicholas Donaldson on 9/24/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
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
        self.imageContentMode = UIViewContentModeScaleAspectFit;
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        self.imageContentMode = self.contentMode;
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
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
    if (loading){
        // Reset content mode
        self.image = nil;
        self.contentMode = UIViewContentModeScaleAspectFit;
        [self.loadingSpinner startAnimating];
    }
    else{
        self.contentMode = self.imageContentMode;
        [self.loadingSpinner stopAnimating];
    }
}

- (void)loadImageFromPath:(NSString *)path
{
    [self loadImageFromPath:path decompress:YES];
}

- (void)loadImageFromPath:(NSString *)path decompress:(BOOL)decompress
{
    [self cancelRequest];
    
    if (path == nil){
        [self showPlaceholder];
        return;
    }
    
    [self setLoading:YES];
    
    self.imageURL = [[RZImageCache sharedCache] downloadImageFromPath:path decompress:decompress delegate:self];
}

- (void)loadImageFromURL:(NSURL *)url
{
    [self loadImageFromURL:url decompress:YES];
}

- (void)loadImageFromURL:(NSURL *)url decompress:(BOOL)decompress
{
    [self cancelRequest];
    
    if (url == nil){
        [self showPlaceholder];
        return;
    }
    
    [self setLoading:YES];
    
    self.imageURL = url;
    [[RZImageCache sharedCache] downloadImageFromURL:url decompress:decompress delegate:self];
}

- (void)setImage:(UIImage *)image animated:(BOOL)animated
{
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
