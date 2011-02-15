//
//  RZImageCache.h
//
//  Created by Nick Donaldson on 2/27/13.

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
- (NSURL*)downloadImageFromPath:(NSString *)path decompress:(BOOL)decompress resizeToSize:(CGSize)size preserveAspectRatio:(BOOL)preserveAspect delegate:(id<RZImageCacheDelegate>)delegate;
- (void)cancelImageDownloadFromPath:(NSString*)path;
- (void)cancelImageDownloadFromPath:(NSString*)path withDelegate:(id<RZImageCacheDelegate>)delegate;

// Fully-qualified URL
- (void)downloadImageFromURL:(NSURL*)url decompress:(BOOL)decompress delegate:(id<RZImageCacheDelegate>)delegate;
- (void)downloadImageFromURL:(NSURL *)url decompress:(BOOL)decompress resizeToSize:(CGSize)size preserveAspectRatio:(BOOL)preserveAspect delegate:(id<RZImageCacheDelegate>)delegate;
- (void)cancelImageDownloadFromURL:(NSURL*)url;
- (void)cancelImageDownloadFromURL:(NSURL*)url withDelegate:(id<RZImageCacheDelegate>)delegate;

@end
