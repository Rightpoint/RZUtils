//
//  RZLoadingImageView
//
//  Created by Nicholas Donaldson on 9/24/12.
//  Copyright (c) 2012 Raizlabs. 
//

#import <UIKit/UIKit.h>
#import "RZImageCache.h"

@class RZLoadingImageView;

@protocol RZLoadingImageViewDelegate <NSObject>

@optional
- (void)loadingImageView:(RZLoadingImageView*)loadingImageView finishedLoadingURL:(NSURL*)url;
- (void)loadingImageView:(RZLoadingImageView*)loadingImageView failedToLoadURL:(NSURL*)url;

@end

@interface RZLoadingImageView : UIImageView <UIAppearance, RZImageCacheDelegate>

@property (nonatomic, weak) id<RZLoadingImageViewDelegate> delegate;

@property (nonatomic, assign) UIViewContentMode imageContentMode;
@property (nonatomic, assign) BOOL showPlaceholderOnError;
@property (nonatomic, strong) UIImage *errorPlaceholderImage UI_APPEARANCE_SELECTOR;

- (void)setLoading:(BOOL)loading;

- (void)loadImageFromPath:(NSString*)path;
- (void)loadImageFromPath:(NSString*)path decompress:(BOOL)decompress;
- (void)loadImageFromPath:(NSString *)path resizeToSize:(CGSize)newSize preserveAspectRatio:(BOOL)preserveAspect decompress:(BOOL)decompress;
- (void)loadImageFromURL:(NSURL*)url;
- (void)loadImageFromURL:(NSURL*)url decompress:(BOOL)decompress;

- (void)setImage:(UIImage *)image animated:(BOOL)animated;

- (void)cancelRequest;

@end
