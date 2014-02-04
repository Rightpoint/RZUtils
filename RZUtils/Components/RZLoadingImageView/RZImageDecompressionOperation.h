//
//  RZImageDecompressionOperation.h
//
//  Created by Nick Donaldson on 2/27/13.
//  Copyright (c) 2013 Raizlabs. 
//

#import <Foundation/Foundation.h>

typedef void (^RZImageDecompressionCompletion)(UIImage* image);

@interface RZImageDecompressionOperation : NSOperation

@property (nonatomic, readonly, strong) NSURL* webUrl;
@property (nonatomic, readonly, strong) NSURL* fileUrl;
@property (nonatomic, readonly, strong) UIImage* image;

- (id)initWithFileURL:(NSURL*)fileUrl webUrl:(NSURL*)webUrl completion:(RZImageDecompressionCompletion)completion;
- (id)initWithFileURL:(NSURL *)fileUrl webUrl:(NSURL *)webUrl resizeToSize:(CGSize)anySize preserveAspectRatio:(BOOL)preserveAspect completion:(RZImageDecompressionCompletion)completion;

@end
