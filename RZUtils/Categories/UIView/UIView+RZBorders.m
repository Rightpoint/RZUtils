//
//  UIView+RZBorders.m
//  Raizlabs
//
//  Created by Nick Donaldson on 10/30/13.

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

#import "UIView+RZBorders.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

static char kRZBorderViewKey;

@interface RZBorderedImageView : UIImageView

+ (NSMutableDictionary *)maskingImageCache;
+ (NSMutableDictionary *)coloredBorderImageCache;

- (void)setBorderMask:(RZViewBorderMask)mask width:(CGFloat)width color:(UIColor *)color;
- (void)setBorderCornerRadius:(CGFloat)radius width:(CGFloat)width color:(UIColor *)color;

// Returns a new or cached masking image that can be used to fill a rect area to produce a bordered effect.
- (UIImage *)maskingImageForMask:(RZViewBorderMask)mask width:(CGFloat)width;

// Returns a new or cached masking image that can be used to fill a rect area to produce a pill effect.
- (UIImage *)maskingImageForCornerRadius:(CGFloat)radius width:(CGFloat)width;

// Returns a clear, stretchable image with the specified borders, width, and color
- (UIImage *)coloredBorderImageWithMask:(RZViewBorderMask)mask width:(CGFloat)width color:(UIColor *)color;

// Returns a clear, stretchable image with the specified corner radius, width, and color
- (UIImage *)coloredBorderImageWithCornerRadius:(CGFloat)radius width:(CGFloat)width color:(UIColor *)color;

@end

// ---------------------------------------

@implementation UIView (RZBorders)

- (RZBorderedImageView *)rz_borderImgView
{
    return objc_getAssociatedObject(self, &kRZBorderViewKey);
}

- (void)rz_addBordersWithMask:(RZViewBorderMask)mask width:(CGFloat)borderWidth color:(UIColor *)color
{
    RZBorderedImageView *imgView = objc_getAssociatedObject(self, &kRZBorderViewKey);
    if (imgView == nil)
    {
        CGRect frame = {.origin = CGPointZero, .size = self.bounds.size};
        imgView = [[RZBorderedImageView alloc] initWithFrame:frame];
        imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [imgView setBorderMask:mask width:borderWidth color:color];
        [self addSubview:imgView];
        objc_setAssociatedObject(self, &kRZBorderViewKey, imgView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    imgView.backgroundColor = [UIColor clearColor];
    imgView.opaque = NO;
}

- (void)rz_addBordersWithCornerRadius:(CGFloat)radius width:(CGFloat)borderWidth color:(UIColor *)color
{
    RZBorderedImageView *imgView = objc_getAssociatedObject(self, &kRZBorderViewKey);
    if (imgView == nil)
    {
        imgView = [[RZBorderedImageView alloc] initWithFrame:self.bounds];
        imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [imgView setBorderCornerRadius:radius width:borderWidth color:color];
        [self addSubview:imgView];
        objc_setAssociatedObject(self, &kRZBorderViewKey, imgView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    imgView.backgroundColor = [UIColor clearColor];
    imgView.opaque = NO;
}

- (void)rz_removeBorders
{
    RZBorderedImageView *imgView = objc_getAssociatedObject(self, &kRZBorderViewKey);
    if (imgView)
    {
        [imgView removeFromSuperview];
        objc_setAssociatedObject(self, &kRZBorderViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end

// ---------------------------------------

@implementation RZBorderedImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.userInteractionEnabled = NO;
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // always keep me at the front
    self.frame = self.superview.bounds;
    [self.superview bringSubviewToFront:self];
}

#pragma mark - Public

- (void)setBorderMask:(RZViewBorderMask)mask width:(CGFloat)width color:(UIColor *)color
{
    self.image = [self coloredBorderImageWithMask:mask width:width color:color];
}

- (void)setBorderCornerRadius:(CGFloat)radius width:(CGFloat)width color:(UIColor *)color
{
    self.image = [self coloredBorderImageWithCornerRadius:radius width:width color:color];
}

#pragma mark - Caches

+ (NSMutableDictionary *)maskingImageCache
{
    static NSMutableDictionary *s_maskCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_maskCache = [NSMutableDictionary dictionary];
    });
    return s_maskCache;
}

+ (NSMutableDictionary *)coloredBorderImageCache
{
    static NSMutableDictionary * s_cbiCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        s_cbiCache = [NSMutableDictionary dictionary];
        
        // Automatically clear the cache in low-memory situations. Should be a rare occurrence.
        // This notification observation will be valid for the application lifetime - no need to ever remove the observer.
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            [[[RZBorderedImageView class] maskingImageCache] removeAllObjects];
            [[[RZBorderedImageView class] coloredBorderImageCache] removeAllObjects];
        }];
        
    });
    return s_cbiCache;
}

#pragma mark - Bitmap generation

- (UIImage *)maskingImageForMask:(RZViewBorderMask)mask width:(CGFloat)width
{
    // must round the width to nearest pixel for current screen scale
    CGFloat scale = [[UIScreen mainScreen] scale];
    width = round(width * scale) / scale;
    
    NSString *cacheKey = [NSString stringWithFormat:@"%lu_%.2f", (unsigned long)mask, width];
    UIImage *maskImage = [[[self class] maskingImageCache] objectForKey:cacheKey];
    if (maskImage == nil)
    {
        CGFloat imgDim = ceilf(width * 3);
        CGSize imgSize = CGSizeMake(imgDim, imgDim);

        UIGraphicsBeginImageContextWithOptions(imgSize, NO, [[UIScreen mainScreen] scale]);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();

        CGRect fullRect = (CGRect){CGPointZero, imgSize};
        CGContextClearRect(ctx, fullRect);
        
        CGColorRef maskImageColorRef = [[UIColor whiteColor] CGColor];
        
        CGContextSetStrokeColorWithColor(ctx, maskImageColorRef);
        CGContextSetLineWidth(ctx, width);

        CGPoint segArray[8];
        NSUInteger segCount = 0;

        CGFloat midWidth = width * 0.5;

        if (mask & RZViewBorderLeft)
        {
            CGPoint start = CGPointMake(midWidth, 0);
            CGPoint end   = CGPointMake(midWidth, imgDim);
            segArray[segCount++] = start;
            segArray[segCount++] = end;
        }

        if (mask & RZViewBorderTop)
        {
            CGPoint start = CGPointMake(0, imgDim - midWidth);
            CGPoint end   = CGPointMake(imgDim, imgDim - midWidth);
            segArray[segCount++] = start;
            segArray[segCount++] = end;
        }

        if (mask & RZViewBorderRight)
        {
            CGPoint start = CGPointMake(imgDim - midWidth, imgDim);
            CGPoint end   = CGPointMake(imgDim - midWidth, 0);
            segArray[segCount++] = start;
            segArray[segCount++] = end;
        }

        if (mask & RZViewBorderBottom)
        {
            CGPoint start = CGPointMake(imgDim, midWidth);
            CGPoint end   = CGPointMake(0, midWidth);
            segArray[segCount++] = start;
            segArray[segCount++] = end;
        }
        
        CGContextStrokeLineSegments(ctx, segArray, segCount);

        maskImage = UIGraphicsGetImageFromCurrentImageContext();

        if (maskImage)
        {
            [[[self class] maskingImageCache] setObject:maskImage forKey:cacheKey];
        }

        UIGraphicsEndImageContext();
    }
    
    return maskImage;
}

- (UIImage *)maskingImageForCornerRadius:(CGFloat)radius width:(CGFloat)width
{
    // must round the width to nearest pixel for current screen scale
    CGFloat scale = [[UIScreen mainScreen] scale];
    width = round(width * scale) / scale;
    
    NSString *cacheKey = [NSString stringWithFormat:@"%.2f_%.2f", radius, width];
    UIImage *maskImage = [[[self class] maskingImageCache] objectForKey:cacheKey];
    if (maskImage == nil)
    {
        CGFloat imgDim = ceilf((width * 3) + (radius * 2));
        CGSize imgSize = CGSizeMake(imgDim, imgDim);
        
        UIGraphicsBeginImageContextWithOptions(imgSize, NO, 0);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGRect fullRect = (CGRect){CGPointZero, imgSize};
        CGContextClearRect(ctx, fullRect);
        
        CGColorRef maskImageColorRef = [[UIColor whiteColor] CGColor];
        
        CGContextSetStrokeColorWithColor(ctx, maskImageColorRef);
        CGContextSetLineWidth(ctx, width);
        
        CGRect roundedRectFrame = CGRectInset(fullRect, width / 2, width / 2);
        CGPathRef roundedRectPath = CGPathCreateWithRoundedRect(roundedRectFrame, radius, radius, NULL);
        CGContextAddPath(ctx, roundedRectPath);
        CGContextStrokePath(ctx);
        CGPathRelease(roundedRectPath);
        
        maskImage = UIGraphicsGetImageFromCurrentImageContext();
        
        if (maskImage)
        {
            [[[self class] maskingImageCache] setObject:maskImage forKey:cacheKey];
        }
        
        UIGraphicsEndImageContext();
    }
    
    return maskImage;
}


- (UIImage *)coloredBorderImageWithMask:(RZViewBorderMask)mask width:(CGFloat)width color:(UIColor *)color
{
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    NSString *cacheKey = [NSString stringWithFormat:@"%lu_%.2f-%lu_%lu_%lu_%lu",
                    (unsigned long)mask,
                    width,
                    (unsigned long)(r * 255),
                    (unsigned long)(g * 255),
                    (unsigned long)(b * 255),
                    (unsigned long)(a * 255)];

    UIImage *borderImage = [[[self class] coloredBorderImageCache] objectForKey:cacheKey];
    if (borderImage == nil)
    {
        UIImage *maskImage = [self maskingImageForMask:mask width:width];
        borderImage = [self borderImageWithMaskImage:maskImage color:color];
        
        if (borderImage)
        {
            [[[self class] coloredBorderImageCache] setObject:borderImage forKey:cacheKey];
        }
    }

    return borderImage;
}

- (UIImage *)coloredBorderImageWithCornerRadius:(CGFloat)radius width:(CGFloat)width color:(UIColor *)color
{
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    NSString *cacheKey = [NSString stringWithFormat:@"%.2f_%.2f-%lu_%lu_%lu_%lu",
                          radius,
                          width,
                          (unsigned long)(r * 255),
                          (unsigned long)(g * 255),
                          (unsigned long)(b * 255),
                          (unsigned long)(a * 255)];
    
    UIImage *borderImage = [[[self class] coloredBorderImageCache] objectForKey:cacheKey];
    if (borderImage == nil)
    {
        UIImage *maskImage = [self maskingImageForCornerRadius:radius width:width];
        borderImage = [self borderImageWithMaskImage:maskImage color:color];
        
        if (borderImage)
        {
            [[[self class] coloredBorderImageCache] setObject:borderImage forKey:cacheKey];
        }
    }
    
    return borderImage;
}

- (UIImage *)borderImageWithMaskImage:(UIImage *)maskImage color:(UIColor *)color
{
    UIImage *borderImage = nil;
    
    if (maskImage)
    {
        CGSize imgSize = maskImage.size;
        
        UIGraphicsBeginImageContextWithOptions(imgSize, NO, [[UIScreen mainScreen] scale]);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGRect fullRect = (CGRect){CGPointZero, imgSize};
        
        // draw color border
        CGContextSetFillColorWithColor(ctx, [color CGColor]);
        CGContextFillRect(ctx, fullRect);
        
        // mask it out
        CGContextSetBlendMode(ctx, kCGBlendModeDestinationIn);
        CGContextDrawImage(ctx, fullRect, [maskImage CGImage]);
        
        UIEdgeInsets stretchInsets = UIEdgeInsetsMake(floor(imgSize.height * 0.5), floor(imgSize.width * 0.5), floor(imgSize.height * 0.5), floor(imgSize.width * 0.5));
        
        borderImage = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:stretchInsets
                                                                                  resizingMode:UIImageResizingModeStretch];
        UIGraphicsEndImageContext();
    }
    
    return borderImage;
}

@end
