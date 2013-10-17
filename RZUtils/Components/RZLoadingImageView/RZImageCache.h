//
//  RZImageCache.h
//
//  Created by Nick Donaldson on 2/27/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

// Use delegate so we can easily manage multiple requests for the same image
@protocol RZImageCacheDelegate <NSObject>

- (void)imageCacheFinishedLoadingImage:(UIImage*)image fromURL:(NSURL*)url wasCached:(BOOL)wasCached;
- (void)imageCacheFailedToLoadImageFromURL:(NSURL*)url error:(NSError*)error;

@end

@interface RZImageCache : NSObject

@property (nonatomic, strong) NSURL *baseURL;

+ (RZImageCache*)sharedCache;

- (void)purgeInMemoryCache;
- (void)setMaxInMemoryCacheSizeBytes:(NSUInteger)bytes; // approximate

// Not fully-qualified - path is appended to baseURL
// Requires that baseURL has been set, and returns full URL
- (NSURL*)downloadImageFromPath:(NSString*)path decompress:(BOOL)decompress delegate:(id<RZImageCacheDelegate>)delegate;
- (void)cancelImageDownloadFromPath:(NSString*)path;
- (void)cancelImageDownloadFromPath:(NSString*)path withDelegate:(id<RZImageCacheDelegate>)delegate;

// Fully-qualified URL
- (void)downloadImageFromURL:(NSURL*)url decompress:(BOOL)decompress delegate:(id<RZImageCacheDelegate>)delegate;
- (void)cancelImageDownloadFromURL:(NSURL*)url;
- (void)cancelImageDownloadFromURL:(NSURL*)url withDelegate:(id<RZImageCacheDelegate>)delegate;

@end
