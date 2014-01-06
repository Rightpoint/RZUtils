//
//  RZAnimatedImageView.m
//  Raizlabs
//
//  Created by Nick Donaldson on 1/6/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZAnimatedImageView.h"
#import <QuartzCore/QuartzCore.h>

#define kRZAnimatedImageViewAnimKey         @"RZImageFrameAnimation"
#define kRZAnimatedImageDefaultFrameTime    (1.f/30.f)

@interface RZAnimatedImageView ()

@property (nonatomic, weak) CALayer *imageLayer;
@property (nonatomic, copy) RZAnimatedImageViewCompletion completion;

@end

@implementation RZAnimatedImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.clipsToBounds = YES;
        self.userInteractionEnabled = NO;
        
        CALayer *imageLayer = [CALayer layer];
        imageLayer.frame = self.bounds;
        imageLayer.backgroundColor = [[UIColor clearColor] CGColor];
        imageLayer.contentsGravity = kCAGravityResize;
        imageLayer.contentsScale = self.contentScaleFactor;
        [self.layer addSublayer:imageLayer];
        self.imageLayer = imageLayer;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageLayer.frame = self.bounds;
}

- (CGSize)intrinsicContentSize
{
    if (self.animationImages.count)
    {
        return [[self.animationImages firstObject] size];
    }
    
    return [super intrinsicContentSize];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if (self.superview == nil)
    {
        [self stopAnimating];
    }
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    if (self.window == nil)
    {
        [self stopAnimating];
    }
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    [super setContentScaleFactor:contentMode];
    NSString *gravity = nil;
    switch (contentMode) {

        case UIViewContentModeBottom:
            gravity = kCAGravityBottom;
            break;
            
        case UIViewContentModeBottomLeft:
            gravity = kCAGravityBottomLeft;
            break;
            
        case UIViewContentModeBottomRight:
            gravity = kCAGravityBottomRight;
            break;
            
        case UIViewContentModeCenter:
            gravity = kCAGravityCenter;
            break;
            
        case UIViewContentModeLeft:
            gravity = kCAGravityLeft;
            break;
            
        case UIViewContentModeRedraw:
        case UIViewContentModeScaleToFill:
            gravity = kCAGravityResize;
            break;
            
        case UIViewContentModeRight:
            gravity = kCAGravityRight;
            break;
            
        case UIViewContentModeScaleAspectFill:
            gravity = kCAGravityResizeAspectFill;
            break;
            
        case UIViewContentModeScaleAspectFit:
            gravity = kCAGravityResizeAspect;
            break;
            
        case UIViewContentModeTop:
            gravity = kCAGravityTop;
            break;
            
        case UIViewContentModeTopLeft:
            gravity = kCAGravityTopLeft;
            break;
            
        case UIViewContentModeTopRight:
            gravity = kCAGravityTopRight;
            break;
            
        default:
            break;
    }
    
    self.imageLayer.contentsGravity = gravity;
}

- (void)setAnimationImages:(NSArray *)animationImages
{
    _animationImages = animationImages;
    self.imageLayer.contents = (__bridge id)[[animationImages firstObject] CGImage];
}

- (void)startAnimatingWithRepeatCount:(NSUInteger)repeatCount completion:(RZAnimatedImageViewCompletion)completion
{
    if (self.animationImages.count > 0)
    {
        self.completion = completion;
        
        NSMutableArray *cgImages = [NSMutableArray array];
        [self.animationImages enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
            [cgImages addObject:(__bridge id)[image CGImage]];
        }];
        
        
        CAKeyframeAnimation *frameAnim = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
        frameAnim.duration = (self.animationDuration <= 0) ? self.animationImages.count * kRZAnimatedImageDefaultFrameTime : self.animationDuration;
        frameAnim.values = cgImages;
        frameAnim.repeatCount = (float)repeatCount;
        frameAnim.delegate = self;        
        [self.imageLayer addAnimation:frameAnim forKey:kRZAnimatedImageViewAnimKey];
    }
}

- (void)stopAnimating
{
    [self.imageLayer removeAnimationForKey:kRZAnimatedImageViewAnimKey];
    self.completion = nil;
}

#pragma mark - Animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.completion)
    {
        self.completion(flag);
        self.completion = nil;
    }
}

@end
