//
//  RZHud.m
//  Raizlabs
//
//  Created by Nick Donaldson on 5/21/12.
//  Copyright (c) 2012 Raizlabs. 
//

#import "RZHud.h"
#import "RZHudBoxView.h"

#import <objc/runtime.h>

#define kDefaultFlipTime            0.25
#define kDefaultSizeTime            0.15
#define kDefaultOverlayTime         0.25
#define kPopupMultiplier            1.2

#define kDefaultPNGImageViewFrame   CGRectMake(0, 0, 30, 30)

@interface RZHud ()

@property (assign, nonatomic) RZHudStyle hudStyle;
@property (strong, nonatomic) UIView *hudContainerView;
@property (strong, nonatomic) UIView *shadowView;
@property (strong, nonatomic) RZHudBoxView *hudBoxView;
@property (strong, nonatomic) UIActivityIndicatorView *spinnerView;
@property (copy, nonatomic)   HUDDismissBlock dismissBlock;

@property (assign, nonatomic) BOOL fullyPresented;
@property (assign, nonatomic) BOOL pendingDismissal;

- (void)setupHudView;
- (void)addHudToOverlay;

@end

@implementation RZHud

@synthesize labelText = _labelText;

#pragma mark - Init and Presentation

- (id)init
{
    return [self initWithStyle:RZHudStyleBoxLoading];
}

- (id)initWithStyle:(RZHudStyle)style
{
    
    if (self = [super initWithFrame:CGRectMake(0, 0, 768, 1024)]){
        
        self.hudStyle = style;
        
        // Avoid using properties here to not disrupt UIAppearance
        _hudColor = [UIColor colorWithWhite:0 alpha:0.9];
        _overlayColor = [UIColor clearColor];
        _spinnerColor = [UIColor whiteColor];
        _borderWidth = 0;
        _shadowAlpha = 0.15;
        _cornerRadius = 16.0;
        _labelColor = [UIColor whiteColor];
        _labelFont = [UIFont systemFontOfSize:17];
        _blocksTouches = YES;
        
        // clear for now, could add a gradient or something here
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.userInteractionEnabled = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // default to fade presentation style
        _presentationStyle = RZHudAnimationMaskFade;
        
    }
    return self;
}

- (void)presentInView:(UIView *)view {
    [self presentInView:view afterDelay:0.0];
}

- (void)presentInView:(UIView *)view afterDelay:(NSTimeInterval)delay
{
    if (self.superview) return;
    
    // setup container for hud
    [self setupHudView];
    
    self.fullyPresented = NO;
    
    self.frame = view.bounds;
    [view addSubview:self];
    
    double delayInSeconds = delay == 0.0 ? 0.01 : delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self addHudToOverlay];
    });
}

- (void)dismiss{
    [self dismissAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated{
    
    BOOL animateDismissal = animated;
    
    // might not need to animate hud out if grace period did not expire
    if (!self.superview){
        animateDismissal = NO;
    }
    
    // if we can't remove the hud, just perform the block
    if (!animateDismissal){
        [self removeFromSuperview];
        if (self.dismissBlock){
            self.dismissBlock();
            self.dismissBlock = nil;
        }
        return;
    }
    
    if (!self.fullyPresented){
        self.pendingDismissal = YES;
        return;
    }

    BOOL shouldFade = (self.presentationStyle & RZHudAnimationMaskFade) == RZHudAnimationMaskFade;
    BOOL shouldZoom = (self.presentationStyle & RZHudAnimationMaskZoom) == RZHudAnimationMaskZoom;
    
    [UIView animateWithDuration:kDefaultOverlayTime
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.backgroundColor = [UIColor clearColor];
                         if (shouldFade)
                         {
                             self.hudBoxView.alpha = 0.0;
                         }
                         if (shouldZoom)
                         {
                             self.hudBoxView.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
                         }
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         if (shouldZoom)
                         {
                             self.hudBoxView.transform = CGAffineTransformIdentity;
                         }
                         
                         if(self.imageViewAnimationArray != nil && [self.customView isKindOfClass:[UIImageView class]])
                         {
                             [(UIImageView *)self.customView stopAnimating];
                         }
                         
                         if (self.dismissBlock){
                             self.dismissBlock();
                             self.dismissBlock = nil;
                         }
                     }
     ];
}

- (void)dismissWithCompletionBlock:(HUDDismissBlock)block{
    [self dismissWithCompletionBlock:block animated:YES];
}

- (void)dismissWithCompletionBlock:(HUDDismissBlock)block animated:(BOOL)animated{
    self.dismissBlock = block;
    [self dismissAnimated:animated];
}

#pragma mark - Private

- (void)setupHudView
{
    if (self.superview) return;
    
    if (self.hudStyle == RZHudStyleBoxLoading || self.hudStyle == RZHudStyleBoxInfo)
    {
        RZHudBoxStyle subStyle = self.hudStyle == RZHudStyleBoxLoading ? RZHudBoxStyleLoading : RZHudBoxStyleInfo;
        self.hudBoxView = [[RZHudBoxView alloc] initWithStyle:subStyle color:self.hudColor cornerRadius:self.cornerRadius];
        self.hudBoxView.borderColor = self.borderColor;
        self.hudBoxView.borderWidth = self.borderWidth;
        self.hudBoxView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.hudBoxView.labelText = self.labelText;
        self.hudBoxView.labelColor = self.labelColor;
        self.hudBoxView.labelFont = self.labelFont;
        self.hudBoxView.spinnerColor = self.spinnerColor;
        self.hudBoxView.customView = self.customView;
        self.hudBoxView.shadowAlpha = self.shadowAlpha;
    }
}


- (void)addHudToOverlay{
    
    if (self.pendingDismissal){
        [self removeFromSuperview];
        if (self.dismissBlock){
            self.dismissBlock();
            self.dismissBlock = nil;
        }
        return;
    }
    
    // make sure the frame is an integral rect, centered
    UIView *hudView = nil;
    if (self.hudStyle == RZHudStyleBoxLoading || self.hudStyle == RZHudStyleBoxInfo)
        hudView = self.hudBoxView;
    
    hudView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    hudView.frame = CGRectIntegral(hudView.frame);
    
    BOOL shouldFade = (self.presentationStyle & RZHudAnimationMaskFade) == RZHudAnimationMaskFade;
    BOOL shouldZoom = (self.presentationStyle & RZHudAnimationMaskZoom) == RZHudAnimationMaskZoom;
    
    if (self.hudStyle != RZHudStyleOverlay)
    {
        if (shouldFade)
        {
            hudView.alpha = 0.0;
        }
        if (shouldZoom)
        {
            hudView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        }
        [self addSubview:hudView];
    }
    
    [UIView animateWithDuration:kDefaultOverlayTime
                     animations:^{
                         if (shouldFade)
                         {
                             hudView.alpha = 1.0;
                         }
                         if (shouldZoom)
                         {
                             hudView.transform = CGAffineTransformIdentity;
                         }
                         self.backgroundColor = self.overlayColor;
                     }
                     completion:^(BOOL finished) {
                         if (self.hudStyle == RZHudStyleBoxLoading || self.hudStyle == RZHudStyleBoxInfo){
                             self.fullyPresented = YES;
                             if (self.pendingDismissal){
                                 [self dismiss];
                             }
                         }
                         else{
                             self.fullyPresented = YES;
                             if (self.pendingDismissal){
                                 [self dismiss];
                             }
                         }

                     }
     ];

}

#pragma mark - Properties

- (void)setBlocksTouches:(BOOL)blocksTouches
{
    _blocksTouches = blocksTouches;
    self.userInteractionEnabled = blocksTouches;
}

- (void)setHudStyle:(RZHudStyle)hudStyle
{
    if (self.superview){
        NSLog(@"Cannot set HUD style after HUD is presented!");
        return;
    }
    
    _hudStyle = hudStyle;
}

- (void)setCustomView:(UIView *)customView
{
    _customView = customView;
    self.hudBoxView.customView = customView;
}

- (void)setImageViewAnimationArray:(NSArray *)imageViewAnimationArray
{
    _imageViewAnimationArray = imageViewAnimationArray;
    
    UIImageView *customView = [[UIImageView alloc] init];
    customView.animationImages = imageViewAnimationArray;
    customView.animationDuration = self.imageViewAnimationDuration;
    customView.contentMode = UIViewContentModeScaleAspectFit;
    customView.frame = kDefaultPNGImageViewFrame;
    
    [customView startAnimating];
    
    [self setCustomView:customView];
}

- (void)setImageViewAnimationDuration:(CGFloat)imageViewAnimationDuration
{
    _imageViewAnimationDuration = imageViewAnimationDuration;
    
    if(self.imageViewAnimationArray != nil)
    {
        if([self.customView isKindOfClass:[UIImageView class]] && [(UIImageView *)self.customView animationImages].count > 0)
        {
            [(UIImageView *)self.customView stopAnimating];
            [(UIImageView *)self.customView setAnimationDuration:imageViewAnimationDuration];
            [(UIImageView *)self.customView startAnimating];
        }
    }
}

- (NSString*)labelText
{
    if (_labelText == nil){
        return @"Loading…";
    }
    return _labelText;
}

- (void)setLabelText:(NSString *)labelText
{
    _labelText = labelText;
    
    // use property here to use default if argument is nil
    self.hudBoxView.labelText = self.labelText;
}

// Most of the below overrides are for UIAppearance to work properly

- (void)setHudColor:(UIColor *)hudColor
{
    switch (self.hudStyle) {
        case RZHudStyleBoxInfo:
        case RZHudStyleBoxLoading:
            self.hudBoxView.color = hudColor;
            break;
            
        default:
            break;
    }
    
    _hudColor = hudColor;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    switch (self.hudStyle) {
            
        case RZHudStyleBoxInfo:
        case RZHudStyleBoxLoading:
            self.hudBoxView.borderColor = borderColor;
            break;
        default:
            break;
    }
    
    _borderColor = borderColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    switch (self.hudStyle) {
            
        case RZHudStyleBoxInfo:
        case RZHudStyleBoxLoading:
            self.hudBoxView.borderWidth = borderWidth;
            break;
            
        default:
            break;
    }
    
    _borderWidth = borderWidth;
}

- (void)setLabelFont:(UIFont *)labelFont
{
    _labelFont = labelFont;
    self.hudBoxView.labelFont = labelFont;
}

- (void)setLabelColor:(UIColor *)labelColor
{
    _labelColor = labelColor;
    self.hudBoxView.labelColor = labelColor;
}

- (void)setShadowAlpha:(CGFloat)shadowAlpha
{
    _shadowAlpha = shadowAlpha;
    self.hudBoxView.shadowAlpha = shadowAlpha;
    // no need to set on circle view, it will be animated to target
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    self.hudBoxView.cornerRadius = cornerRadius;
}

@end


static char * const kRZHudAssociationKey = "RZHudKey";

@implementation UIViewController (RZHud)

-(void)setHud:(RZHud *)hud
{
    objc_setAssociatedObject(self, kRZHudAssociationKey, hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(RZHud*)hud
{
    return objc_getAssociatedObject(self, kRZHudAssociationKey);
}

-(void) showHUD{
    [self showHUDWithMessage:nil inView:self.view];
}

-(void) showHUDOnRoot{
    [self showHUDOnRootWithMessage:nil];
}

-(void) showHUDWithMessage:(NSString *)message{
    [self showHUDWithMessage:message inView:self.view];
}

- (void) showHUDOnRootWithMessage:(NSString*)message
{
    UIView *rootView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
    
    [self showHUDWithMessage:message inView:rootView];
}

-(void) showHUDWithMessage:(NSString*)message inView:(UIView*)view
{
    if (![self respondsToSelector:@selector(setHud:)]) return;
    
    [self hideHUD];
    
    self.hud = [[RZHud alloc] initWithStyle:RZHudStyleBoxLoading];
    if (message != nil){
        self.hud.labelText = message;
    }
    [self.hud presentInView:view];
}

-(void) showInfoHUDOnRootWithMessage:(NSString*)message customView:(UIView*)customView
{
    UIView *rootView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
    
    [self showInfoHUDWithMessage:message customView:customView inView:rootView];
}

-(void) showInfoHUDWithMessage:(NSString *)message customView:(UIView *)customView inView:(UIView *)view
{
    if (![self respondsToSelector:@selector(setHud:)]) return;
    
    [self hideHUD];
    
    self.hud = [[RZHud alloc] initWithStyle:RZHudStyleBoxInfo];
    if (message != nil){
        self.hud.labelText = message;
    }
    self.hud.customView = customView;
    [self.hud presentInView:view];
}


-(void) showOverlayOnlyHUDOnRoot:(BOOL)root
{
    if (![self respondsToSelector:@selector(setHud:)]) return;
    [self hideHUD];
    UIView *hudParent = root ? [[[UIApplication sharedApplication] keyWindow] rootViewController].view : self.view;
    self.hud = [[RZHud alloc] initWithStyle:RZHudStyleOverlay];
    [self.hud presentInView:hudParent];
}

-(void) hideHUDWithCompletionBlock:(void (^)())block{
    
    if (![self respondsToSelector:@selector(setHud:)] || self.hud == nil){
        if (block){
            block();
        }
        return;
    }
    
    [self.hud dismissWithCompletionBlock:block];
    self.hud = nil;
}

-(void) hideHUD
{
    if (![self respondsToSelector:@selector(setHud:)]) return;
    
    [self.hud dismiss];
    self.hud = nil;
}

@end
