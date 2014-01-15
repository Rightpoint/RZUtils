//
//  RZImageDecompressionOperation.m
//
//  Created by Nick Donaldson on 2/27/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "RZImageDecompressionOperation.h"
#import "UIImage+RZResize.h"

@interface RZImageDecompressionOperation ()

@property (nonatomic, readwrite, strong) NSURL* webUrl;
@property (nonatomic, readwrite, strong) NSURL* fileUrl;
@property (nonatomic, readwrite, strong) UIImage* image;

@property (nonatomic, copy) RZImageDecompressionCompletion completion;

@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) BOOL executing;

@property (nonatomic, assign) CGSize newSize;
@property (nonatomic, assign) BOOL preserveAspect;

- (void)decompressImage;

@end

@implementation RZImageDecompressionOperation

- (id)initWithFileURL:(NSURL*)fileUrl webUrl:(NSURL*)webUrl completion:(RZImageDecompressionCompletion)completion
{
    return [self initWithFileURL:fileUrl webUrl:webUrl resizeToSize:CGSizeZero preserveAspectRatio:YES completion:completion];
}

- (id)initWithFileURL:(NSURL *)fileUrl webUrl:(NSURL *)webUrl resizeToSize:(CGSize)anySize preserveAspectRatio:(BOOL)preserveAspect completion:(RZImageDecompressionCompletion)completion
{
    self = [super init];
    if (self){
        self.webUrl = webUrl;
        self.fileUrl = fileUrl;
        self.newSize = anySize;
        self.preserveAspect = preserveAspect;
        self.completion = completion;
    }
    return self;
}

#pragma mark - NSOperation

-(void)start{
    
    if (self.isCancelled){
        
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        
        return;
    }
    
    [NSThread detachNewThreadSelector:@selector(decompressImage) toTarget:self withObject:nil];
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting{
    return _executing;
}

- (BOOL)isFinished{
    return _finished;
}

#pragma mark - Decompression

// Image decompression code sourced from
// https://gist.github.com/mystcolor/1257111

- (void)decompressImage
{
    @autoreleasepool {
        
        [self willChangeValueForKey:@"isExecuting"];
        _executing = YES;
        [self didChangeValueForKey:@"isExecuting"];
        
        @autoreleasepool {
            
            NSData *imgData = [NSData dataWithContentsOfURL:self.fileUrl];
            UIImage *compressedImage = [UIImage imageWithData:imgData];
            
            CGImageRef imageRef = compressedImage.CGImage;
            
            // System only supports RGB, set explicitly and prevent context error
            // if the downloaded image is not the supported format
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

            BOOL resizing = (self.newSize.width > 0 && self.newSize.height > 0);
            CGSize imageSize;
            if(resizing)
            {
                imageSize = self.newSize;
            }
            else
            {
                imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
            }

            // Scale for retina devices
            CGFloat scale = [[UIScreen mainScreen] scale];
            imageSize.width *= scale;
            imageSize.height *= scale;
            
            CGContextRef context = CGBitmapContextCreate(NULL,
                                                         imageSize.width,
                                                         imageSize.height,
                                                         8,
                                                         // width * 4 will be enough because are in ARGB format, don't read from the image
                                                         imageSize.width * 4,
                                                         colorSpace,
                                                         // kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little
                                                         // makes system don't need to do extra conversion when displayed.
                                                         kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
            CGColorSpaceRelease(colorSpace);
            
            if (context) {
                CGRect rect;
                if(resizing)
                {
                    CGSize size = [UIImage sizeForImage:compressedImage scaledToSize:imageSize preserveAspectRation:self.preserveAspect];
                    rect = (CGRect){CGPointZero, size.width, size.height};
                }
                else
                {
                    rect = (CGRect){CGPointZero, imageSize.width, imageSize.height};
                }

                CGContextDrawImage(context, rect, imageRef);
                CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
                CGContextRelease(context);
                
                self.image = [[UIImage alloc] initWithCGImage:decompressedImageRef];
                
                CGImageRelease(decompressedImageRef);
            }
        }
        
        [self willChangeValueForKey:@"isExecuting"];
        _executing = NO;
        [self didChangeValueForKey:@"isExecuting"];
        
        if (self.completion){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completion(self.image);
            });
        }
        
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
    }
}

@end
