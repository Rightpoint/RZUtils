//
//  RZImageCache.m
//
//  Created by Nick Donaldson on 2/27/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "RZImageCache.h"
#import "RZImageDecompressionOperation.h"
#import "RZWebServiceManager.h"
#import "RZFileManager.h"
#import "UIImage+RZResize.h"

#define RZImageCacheError(fmt, ...) NSLog((@"[RZImageCache] Error: " fmt), ##__VA_ARGS__)

// 50 mb
#define kRZImageCacheDefaultMaxMemCacheSizeBytes    52428800

@interface UIImage (RZImageCacheByteSize)

- (NSUInteger)approxSizeInBytes;

@end

@implementation UIImage (RZImageCacheByteSize)

- (NSUInteger)approxSizeInBytes
{
    // assume 4 bytes per pixel
    return self.size.width * self.size.height * 4;
}

@end

@interface RZImageCache ()

// Using a separate webservice manager so it doesn't tie up other webservices
@property (nonatomic, strong) RZWebServiceManager *imageWebserviceManager;

@property (nonatomic, strong) RZFileManager *fileManager;

@property (nonatomic, strong) NSOperationQueue *decompressionQueue;

@property (nonatomic, strong) NSCache *inMemoryImageCache;

@property (nonatomic, strong) NSMutableSet* downloadingUrls;

// Manage multiple requests for the same image
@property (nonatomic, strong) NSMutableDictionary *delegates;

- (BOOL)isDownloadingURL:(NSURL*)url;

- (void)addDelegate:(id<RZImageCacheDelegate>)delegate forURL:(NSURL*)url;
- (void)removeDelegate:(id<RZImageCacheDelegate>)delegate forURL:(NSURL*)url;

- (void)notifyDelegatesOfSuccessForURL:(NSURL*)url withImage:(UIImage*)image fromCache:(BOOL)fromCache;
- (void)notifyDelegatesOfFailureForURL:(NSURL*)url withError:(NSError*)error;

@end

@implementation RZImageCache

+ (RZImageCache*)sharedCache
{
    static RZImageCache* sharedCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[RZImageCache alloc] initInternal];
    });
    return sharedCache;
}

- (id)init
{
    [NSException raise:NSInternalInconsistencyException format:@"-init is not a valid initializer for singleton BHImageCache. Use +sharedCache."];
    return nil;
}

- (id)initInternal{
    self = [super init];
    if (self){
        self.imageWebserviceManager = [[RZWebServiceManager alloc] init];
        [self.imageWebserviceManager setMaximumConcurrentRequests:4];
        
        self.fileManager = [[RZFileManager alloc] init];
        self.fileManager.webManager = self.imageWebserviceManager;
        self.fileManager.shouldCacheDownloads = NO;
        
        self.decompressionQueue = [[NSOperationQueue alloc] init];
        self.decompressionQueue.maxConcurrentOperationCount = 1;
        
        self.inMemoryImageCache = [[NSCache alloc] init];
        [self.inMemoryImageCache setTotalCostLimit:kRZImageCacheDefaultMaxMemCacheSizeBytes];
        
        self.downloadingUrls = [NSMutableSet setWithCapacity:10];
        
        self.delegates = [[NSMutableDictionary alloc] initWithCapacity:10];
        
    }
    return self;
}


#pragma mark - Public

- (void)purgeInMemoryCache
{
    [self.inMemoryImageCache removeAllObjects];
}

- (void)setMaxInMemoryCacheSizeBytes:(NSUInteger)bytes
{
    [self.inMemoryImageCache setTotalCostLimit:bytes];
}

- (NSURL*)downloadImageFromPath:(NSString *)path decompress:(BOOL)decompress delegate:(id<RZImageCacheDelegate>)delegate
{
    return [self downloadImageFromPath:path decompress:decompress resizeToSize:CGSizeZero preserveAspectRatio:YES delegate:delegate];
}

- (NSURL*)downloadImageFromPath:(NSString *)path decompress:(BOOL)decompress resizeToSize:(CGSize)size preserveAspectRatio:(BOOL)preserveAspect delegate:(id<RZImageCacheDelegate>)delegate
{
    NSURL *imageURL = nil;
    if (self.baseURL){
        imageURL = [NSURL URLWithString:path relativeToURL:self.baseURL];
        [self downloadImageFromURL:imageURL decompress:decompress resizeToSize:size preserveAspectRatio:preserveAspect delegate:delegate];
    }
    else{
        RZImageCacheError(@"No base URL has been set.");

        if (delegate){
            [delegate imageCacheFailedToLoadImageFromURL:nil error:nil];
        }
    }
    return imageURL;
}

- (void)downloadImageFromURL:(NSURL *)url decompress:(BOOL)decompress delegate:(id<RZImageCacheDelegate>)delegate
{
    [self downloadImageFromURL:url decompress:decompress resizeToSize:CGSizeZero preserveAspectRatio:YES delegate:delegate];
}

- (void)downloadImageFromURL:(NSURL *)url decompress:(BOOL)decompress resizeToSize:(CGSize)size preserveAspectRatio:(BOOL)preserveAspect delegate:(id<RZImageCacheDelegate>)delegate
{
    if (url){

        BOOL resizing = (size.width > 0 && size.height > 0);

        // Use the absolute URL for the cache key. If we are resizing, append the size on to the key.
        // Use the requested size as the key because we do not yet know the actual size of the resized image (we haven't downloaded the image yet).
        NSString *cacheKey = url.absoluteString;
        if(resizing)
        {
            NSString *sizeString = [NSString stringWithFormat:@"%fx%f", size.width, size.height];
            cacheKey = [NSString stringWithFormat:@"%@%@", cacheKey, sizeString];
        }
        UIImage *image = [self.inMemoryImageCache objectForKey:cacheKey];
        if (image == nil){
            
            if (delegate){
                [self addDelegate:delegate forURL:url];
            }
            
            // If we're downloading this image already, just add delegate, don't do anything else
            if (![self isDownloadingURL:url]){
                
                [self.downloadingUrls addObject:url];
            
                [self.fileManager downloadFileFromURL:url withProgressDelegate:nil completion:^(BOOL success, NSURL *downloadedFile, RZWebServiceRequest *request) {
                    
                    if (success){
                        
                        BOOL loadedFromCache = (request == nil);
                        
                        if (decompress){
                            
                            RZImageDecompressionOperation *decomp = [[RZImageDecompressionOperation alloc] initWithFileURL:downloadedFile webUrl:url resizeToSize:size preserveAspectRatio:preserveAspect completion:^(UIImage *image) {
                                
                                if (image){
                                    [self.inMemoryImageCache setObject:image forKey:cacheKey cost:[image approxSizeInBytes]];
                                    [self notifyDelegatesOfSuccessForURL:url withImage:image fromCache:NO];
                                }
                                else{
                                    RZImageCacheError(@"Unable to decompress image from URL: %@", url);
                                    [self notifyDelegatesOfFailureForURL:url withError:nil];
                                }
                                
                                [self.downloadingUrls removeObject:url];

                            }];
                            
                            [self.decompressionQueue addOperation:decomp];
                        }
                        else{
                            NSData *imgData = [NSData dataWithContentsOfURL:downloadedFile];
                            UIImage *image = [UIImage imageWithData:imgData];

                            // If a resize size is provided, resize the image.
                            if(resizing)
                            {
                                image = [UIImage imageWithImage:image scaledToSize:size preserveAspectRatio:preserveAspect];
                            }

                            [self.downloadingUrls removeObject:url];
                            [self.inMemoryImageCache setObject:image forKey:cacheKey];
                            [self notifyDelegatesOfSuccessForURL:url withImage:image fromCache:loadedFromCache];
                        }
                        
                    }
                    else{
                        
                        // The download failed
                        [self.downloadingUrls removeObject:url];
                        RZImageCacheError(@"Image download failed with error: %@", request.error);
                        [self notifyDelegatesOfFailureForURL:url withError:request.error];
                    }
                                        
                }];
                
            } // Image was already downloading, do nothing else
            
        }
        else{
            // Got image from in-memory cache, just return to delegate
            [delegate imageCacheFinishedLoadingImage:image fromURL:url wasCached:YES];
        }
        
    }
    else{
        
        // URL was nil
        RZImageCacheError(@"Attempt to download image from nil URL");
        [delegate imageCacheFailedToLoadImageFromURL:nil error:nil];
    }
}

- (void)cancelImageDownloadFromPath:(NSString *)path
{
    if (self.baseURL){
        [self cancelImageDownloadFromURL:[NSURL URLWithString:path relativeToURL:self.baseURL]];
    }
    else{
        RZImageCacheError(@"No base URL has been set.");
    }
}

- (void)cancelImageDownloadFromPath:(NSString *)path withDelegate:(id<RZImageCacheDelegate>)delegate
{
    if (self.baseURL){
        [self cancelImageDownloadFromURL:[NSURL URLWithString:path relativeToURL:self.baseURL] withDelegate:delegate];
    }
    else{
        RZImageCacheError(@"No base URL has been set.");
    }
}

- (void)cancelImageDownloadFromURL:(NSURL *)url
{
    if (url && [self.downloadingUrls containsObject:url]){
        
        [self.downloadingUrls removeObject:url];
        [self.delegates removeObjectForKey:url];
        
        [self.fileManager cancelDownloadFromURL:url];
        
        // remove all delegates
        [self.delegates removeObjectForKey:url];
        
        [self.decompressionQueue setSuspended:YES];
        [[self.decompressionQueue operations] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[RZImageDecompressionOperation class]]){
                
                RZImageDecompressionOperation *dcmOp = obj;
                if ([[dcmOp webUrl] isEqual:url]){
                    [dcmOp cancel];
                    *stop = YES;
                }
            }
        }];
        
        [self.decompressionQueue setSuspended:NO];
    }

}

- (void)cancelImageDownloadFromURL:(NSURL *)url withDelegate:(id<RZImageCacheDelegate>)delegate
{
    if (url){
        [self removeDelegate:delegate forURL:url];
    }
    else{
        RZImageCacheError(@"Attempt to cancel download from nil URL");
    }
}

#pragma mark - Request helpers

- (BOOL)isDownloadingURL:(NSURL *)url
{
    return [self.downloadingUrls containsObject:url];
}

#pragma mark - Delegate helpers

- (void)addDelegate:(id<RZImageCacheDelegate>)delegate forURL:(NSURL *)url
{
    NSMutableSet *urlDelegates = [self.delegates objectForKey:url];
    if (urlDelegates == nil){
        urlDelegates = [NSMutableSet setWithCapacity:4];
    }
    
    // Don't retain on insert - REMEMBER TO REMOVE!!!
    [urlDelegates addObject:[NSValue valueWithNonretainedObject:delegate]];
    
    [self.delegates setObject:urlDelegates forKey:url];
}

- (void)removeDelegate:(id<RZImageCacheDelegate>)delegate forURL:(NSURL *)url
{
    NSMutableSet *urlDelegates = [self.delegates objectForKey:url];
    
    [urlDelegates removeObject:[NSValue valueWithNonretainedObject:delegate]];
    
    if (urlDelegates == nil || urlDelegates.count == 0){
        [self cancelImageDownloadFromURL:url];
    }
    else{
        [self.delegates setObject:urlDelegates forKey:url];
    }
    
}

- (void)notifyDelegatesOfSuccessForURL:(NSURL *)url withImage:(UIImage *)image fromCache:(BOOL)fromCache
{
    NSMutableArray *delegates = [self.delegates objectForKey:url];
    
    [delegates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id delegate = [obj nonretainedObjectValue];
        if ([delegate respondsToSelector:@selector(imageCacheFinishedLoadingImage:fromURL:wasCached:)]){
            [delegate imageCacheFinishedLoadingImage:image fromURL:url wasCached:fromCache];
        }
    }];
    
    [self.delegates removeObjectForKey:url];
}

- (void)notifyDelegatesOfFailureForURL:(NSURL *)url withError:(NSError *)error
{
    NSMutableArray *delegates = [self.delegates objectForKey:url];
    
    [delegates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id delegate = [obj nonretainedObjectValue];
        if ([delegate respondsToSelector:@selector(imageCacheFailedToLoadImageFromURL:error:)]){
            [delegate imageCacheFailedToLoadImageFromURL:url error:error];
        }
    }];
    
    [self.delegates removeObjectForKey:url];
}

@end
