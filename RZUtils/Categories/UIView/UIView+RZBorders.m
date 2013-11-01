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

@interface RZBorderLayer : CALayer

@property (nonatomic, assign) RZViewBorderMask rz_borderMask;
@property (nonatomic, assign) CGFloat rz_borderWidth;
@property (nonatomic, assign) CGColorRef rz_borderColorRef;

@end

@interface RZBorderedHostView ()

@property (nonatomic, readonly) RZBorderLayer *borderLayer;

@end


// ---------------------------------------

@implementation UIView (RZBorders)

- (void)rz_addBordersWithMask:(RZViewBorderMask)mask width:(CGFloat)borderWidth color:(UIColor *)color
{
    RZBorderedHostView *hostView = objc_getAssociatedObject(self, &kRZBorderViewKey);
    if (hostView == nil)
    {
        hostView = [[RZBorderedHostView alloc] initWithFrame:self.bounds];
        hostView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:hostView atIndex:0];
        objc_setAssociatedObject(self, &kRZBorderViewKey, hostView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    hostView.backgroundColor = [UIColor clearColor];
    hostView.opaque = NO;
    hostView.borderLayer.rz_borderMask = mask;
    hostView.borderLayer.rz_borderWidth = borderWidth;
    hostView.borderLayer.rz_borderColorRef = [color CGColor];
}

- (void)rz_removeBorders
{
    RZBorderedHostView *hostView = objc_getAssociatedObject(self, &kRZBorderViewKey);
    if (hostView)
    {
        [hostView removeFromSuperview];
        objc_setAssociatedObject(self, &kRZBorderViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end

// ---------------------------------------

@implementation RZBorderedHostView

+ (Class)layerClass
{
    return [RZBorderLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
    }
    return self;
}

- (RZBorderLayer*)borderLayer
{
    return (RZBorderLayer*)self.layer;
}

- (void)setRz_borderMask:(RZViewBorderMask)rz_borderMask
{
    _rz_borderMask = rz_borderMask;
    self.borderLayer.rz_borderMask = rz_borderMask;
}

- (void)setRz_borderColor:(UIColor *)rz_borderColor
{
    _rz_borderColor = rz_borderColor;
    self.borderLayer.rz_borderColorRef = [rz_borderColor CGColor];
}

- (void)setRz_borderWidth:(CGFloat)rz_borderWidth
{
    _rz_borderWidth = rz_borderWidth;
    self.borderLayer.rz_borderWidth = rz_borderWidth;
}

@end

@implementation RZBorderLayer

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    static NSArray *displayKeys = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        displayKeys = @[NSStringFromSelector(@selector(rz_borderMask)),
                        NSStringFromSelector(@selector(rz_borderWidth)),
                        NSStringFromSelector(@selector(rz_borderColorRef))];
    });
    
    return [super needsDisplayForKey:key] || [displayKeys containsObject:key];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.contentsScale = [[UIScreen mainScreen] scale];
        self.needsDisplayOnBoundsChange = YES;
        self.rz_borderColorRef = [[UIColor blackColor] CGColor];
    }
    return self;
}

- (void)setRz_borderColorRef:(CGColorRef)rz_borderColorRef
{
    if (_rz_borderColorRef)
    {
        CGColorRelease(_rz_borderColorRef);
    }
    
    _rz_borderColorRef = rz_borderColorRef;
    
    if (rz_borderColorRef)
    {
        CGColorRetain(rz_borderColorRef);
    }
}

- (void)drawInContext:(CGContextRef)ctx
{
    if (self.rz_borderColorRef && self.rz_borderMask != 0 && self.rz_borderWidth > 0)
    {
        CGContextSetStrokeColorWithColor(ctx, self.rz_borderColorRef);
        CGContextSetLineWidth(ctx, self.rz_borderWidth);
        
        CGPoint segArray[8];
        NSUInteger segCount = 0;
        
        CGFloat midWidth = self.rz_borderWidth * 0.5;
        
        if (self.rz_borderMask & RZViewBorderLeft)
        {
            CGPoint start = CGPointMake(midWidth, 0);
            CGPoint end   = CGPointMake(midWidth, self.bounds.size.height);
            segArray[segCount++] = start;
            segArray[segCount++] = end;
        }
        
        if (self.rz_borderMask & RZViewBorderBottom)
        {
            CGPoint start = CGPointMake(0, self.bounds.size.height - midWidth);
            CGPoint end   = CGPointMake(self.bounds.size.width, self.bounds.size.height - midWidth);
            segArray[segCount++] = start;
            segArray[segCount++] = end;
        }
        
        if (self.rz_borderMask & RZViewBorderRight)
        {
            CGPoint start = CGPointMake(self.bounds.size.width - midWidth, self.bounds.size.height);
            CGPoint end   = CGPointMake(self.bounds.size.width - midWidth, 0);
            segArray[segCount++] = start;
            segArray[segCount++] = end;
        }
        
        if (self.rz_borderMask & RZViewBorderTop)
        {
            CGPoint start = CGPointMake(self.bounds.size.width, midWidth);
            CGPoint end   = CGPointMake(0, midWidth);
            segArray[segCount++] = start;
            segArray[segCount++] = end;
        }
        
        CGContextStrokeLineSegments(ctx, segArray, segCount);
    }
}

@end