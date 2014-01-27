//
//  UIView+RZBorders.m
//  Raizlabs
//
//  Created by Nick Donaldson on 10/30/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "UIView+RZBorders.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

static char kRZBorderViewKey;

@interface RZBorderedImageView : UIImageView

+ (NSMutableDictionary *)maskingImageCache;
+ (NSMutableDictionary *)coloredBorderImageCache;

- (void)setBorderMask:(RZViewBorderMask)mask width:(CGFloat)width color:(UIColor *)color;

// Returns a new or cached masking image that can be used to fill a rect area to produce a bordered effect.
- (UIImage *)maskingImageForMask:(RZViewBorderMask)mask width:(CGFloat)width;

// Returns a clear, stretchable image with the specified borders, width, and color
- (UIImage *)coloredBorderImageWithMask:(RZViewBorderMask)mask width:(CGFloat)width color:(UIColor *)color;

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
        imgView = [[RZBorderedImageView alloc] initWithFrame:self.bounds];
        imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [imgView setBorderMask:mask width:borderWidth color:color];
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
            
            borderImage = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(imgSize.height * 0.5, imgSize.width * 0.5, imgSize.height * 0.5, imgSize.width * 0.5)
                                                                                      resizingMode:UIImageResizingModeStretch];
            if (borderImage)
            {
                [[[self class] coloredBorderImageCache] setObject:borderImage forKey:cacheKey];
            }

            UIGraphicsEndImageContext();
        }

    }

    return borderImage;
}

@end
