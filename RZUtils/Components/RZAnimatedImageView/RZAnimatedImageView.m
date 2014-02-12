//
//  RZAnimatedImageView.m
//  Raizlabs
//
//  Created by Nick Donaldson on 1/6/14.

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
}

#pragma mark - Animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.completion)
    {
        self.completion(flag);
    }
}

@end
