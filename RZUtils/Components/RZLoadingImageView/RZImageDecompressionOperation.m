//
//  RZImageDecompressionOperation.m
//
//  Created by Nick Donaldson on 2/27/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "RZImageDecompressionOperation.h"

@interface RZImageDecompressionOperation ()

@property (nonatomic, readwrite, strong) NSURL* webUrl;
@property (nonatomic, readwrite, strong) NSURL* fileUrl;
@property (nonatomic, readwrite, strong) UIImage* image;

@property (nonatomic, copy) RZImageDecompressionCompletion completion;

@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) BOOL executing;

- (void)decompressImage;

@end

@implementation RZImageDecompressionOperation

- (id)initWithFileURL:(NSURL *)fileUrl webUrl:(NSURL *)webUrl completion:(RZImageDecompressionCompletion)completion
{
    self = [super init];
    if (self){
        self.webUrl = webUrl;
        self.fileUrl = fileUrl;
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
            
            CGContextRef context = CGBitmapContextCreate(NULL,
                                                         CGImageGetWidth(imageRef),
                                                         CGImageGetHeight(imageRef),
                                                         8,
                                                         // width * 4 will be enough because are in ARGB format, don't read from the image
                                                         CGImageGetWidth(imageRef) * 4,
                                                         colorSpace,
                                                         // kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little
                                                         // makes system don't need to do extra conversion when displayed.
                                                         kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
            CGColorSpaceRelease(colorSpace);
            
            if (context) {
                CGRect rect = (CGRect){CGPointZero, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)};
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
