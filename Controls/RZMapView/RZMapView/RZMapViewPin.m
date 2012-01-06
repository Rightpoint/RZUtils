//
//  RZMapViewPin.m
//  SolidWorks World 2012
//
//  Created by Joe Goullaud on 1/4/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import "RZMapViewPin.h"

@interface RZMapViewPin ()

@property (retain, nonatomic, readwrite) UIImage *pinImage;
@property (assign, nonatomic, readwrite) RZMapViewPinPointLocation pointLocation;
@property (retain, nonatomic, readwrite) UIImageView *pinImageView;

@property (retain, nonatomic) UIImageView *popoverBackgroundImageView;
@property (retain, nonatomic) UITapGestureRecognizer *pinTappedRecognizer;

@property (assign, getter = isAnimating) BOOL animating;

- (void)configurePinView;
- (void)pinTapped:(UITapGestureRecognizer*)gestureRecognizer;

@end

@implementation RZMapViewPin

@synthesize pinImage = _pinImage;
@synthesize popoverBackgroundImage = _popoverBackgroundImage;
@synthesize popoverView = _popoverView;
@synthesize pinImageView = _pinImageView;
@synthesize location = _location;
@synthesize active = _active;
@synthesize pointLocation = _pointLocation;
@synthesize delegate = _delegate;

@synthesize popoverBackgroundImageView = _popoverBackgroundImageView;
@synthesize pinTappedRecognizer = _pinTappedRecognizer;

@synthesize animating = _animating;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.pointLocation = RZMapViewPinPointLocationBottom;
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pinTapped:)];
        tapGR.numberOfTapsRequired = 1;
        tapGR.numberOfTouchesRequired = 1;
        tapGR.cancelsTouchesInView = NO;
        self.pinTappedRecognizer = tapGR;
        [tapGR release];
    }
    return self;
}

- (void)dealloc
{    
    [_pinImage release];
    [_popoverBackgroundImage release];
    [_popoverView release];
    [_pinImageView release];
    [_location release];
    
    [_popoverBackgroundImageView release];
    [_pinTappedRecognizer release];
    
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.isAnimating)
    {
        [self configurePinView];
    }
}

- (void)setPinImage:(UIImage *)pinImage withPointLocation:(RZMapViewPinPointLocation)pointLocation
{
    self.pointLocation = pointLocation;
    self.pinImage = pinImage;
    
    [self.pinImageView removeFromSuperview];
    self.pinImageView = [[[UIImageView alloc] initWithImage:self.pinImage] autorelease];
    self.pinImageView.userInteractionEnabled = YES;
    [self.pinImageView addGestureRecognizer:self.pinTappedRecognizer];
    [self addSubview:self.pinImageView];
    
    CGPoint currentCenter = self.center;
    [self configurePinView];
    self.center = currentCenter;
}

- (void)setActive:(BOOL)active
{
    [self setActive:active animated:NO];
}

- (void)setActive:(BOOL)active animated:(BOOL)animated
{
    if (active == _active)
    {
        return;
    }
    
    _active = active;
    
    if (active)
    {
        [self addSubview:self.popoverView];
        [self configurePinView];
        
        if (animated)
        {
            CGPoint finalCenter = self.popoverView.center;
            
//            self.popoverView.center = CGPointMake(finalCenter.x, finalCenter.y + (self.popoverView.bounds.size.height / 2.0));
            CGAffineTransform currentTransform = self.popoverView.transform;
            self.popoverView.transform = CGAffineTransformTranslate(CGAffineTransformScale(currentTransform, 0.01, 0.01), 0, self.popoverView.bounds.size.height / 2.0);
            
            [UIView animateWithDuration:0.25 
                                  delay:0 
                                options:UIViewAnimationOptionCurveEaseInOut 
                             animations:^{
//                                self.popoverView.center = finalCenter;
                                self.popoverView.transform = currentTransform;
                            } 
                             completion:nil];
        }
    }
    else if (animated)
    {
        CGAffineTransform currentTransform = self.popoverView.transform;
        CGAffineTransform endTransform = CGAffineTransformTranslate(CGAffineTransformScale(currentTransform, 0.01, 0.01), 0, self.popoverView.bounds.size.height / 2.0);
        
        [UIView animateWithDuration:0.25 
                              delay:0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             self.animating = YES;
                             self.popoverView.transform = endTransform;
                         } 
                         completion:^(BOOL finished) {
                             self.animating = NO;
                             [self.popoverView removeFromSuperview];
                             [self configurePinView];
                             self.popoverView.transform = currentTransform;
                         }];
    }
    else
    {
        [self.popoverView removeFromSuperview];
        [self configurePinView];
    }
}

- (UIView*)popoverView
{
    if (nil == _popoverView)
    {
        // TODO - Create Better Default popoverView
        self.popoverView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 25)] autorelease];
        _popoverView.backgroundColor = [UIColor greenColor];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:_popoverView.bounds];
        titleLabel.text = (self.location) ? self.location.locationName : @"No Name";
        titleLabel.textAlignment = UITextAlignmentCenter;
        [_popoverView addSubview:titleLabel];
        [titleLabel release];
    }
    
    return _popoverView;
}

- (void)configurePinView
{
    CGFloat newWidth = (self.active) ? MAX(self.pinImageView.bounds.size.width, self.popoverView.bounds.size.width) : self.pinImageView.bounds.size.width;
    CGFloat newHeight = self.pinImageView.bounds.size.height + (self.active ? self.popoverView.bounds.size.height : 0.0);
    
//    if (RZMapViewPinPointLocationTop != self.pointLocation &&
//        RZMapViewPinPointLocationCenter != self.pointLocation &&
//        RZMapViewPinPointLocationBottom != self.pointLocation)
//    {
//        newWidth *= 2.0;
//    }
//    
//    if (RZMapViewPinPointLocationLeft != self.pointLocation &&
//        RZMapViewPinPointLocationCenter != self.pointLocation &&
//        RZMapViewPinPointLocationRight != self.pointLocation)
//    {
//        newHeight *= 2.0;
//    }
    
    CGFloat imageViewX = 0.0;
    CGFloat imageViewY = (self.active) ? -(self.popoverView.bounds.size.height / 2.0) : 0.0;
    
    if (RZMapViewPinPointLocationLeft == self.pointLocation ||
        RZMapViewPinPointLocationTopLeft == self.pointLocation ||
        RZMapViewPinPointLocationBottomLeft == self.pointLocation)
    {
        imageViewX += self.pinImageView.bounds.size.width / 2.0;
    }
    else if (RZMapViewPinPointLocationRight == self.pointLocation ||
             RZMapViewPinPointLocationTopRight == self.pointLocation ||
             RZMapViewPinPointLocationBottomRight == self.pointLocation)
    {
        imageViewX -= self.pinImageView.bounds.size.width / 2.0;
    }
    
    if (RZMapViewPinPointLocationTop == self.pointLocation ||
        RZMapViewPinPointLocationTopLeft == self.pointLocation ||
        RZMapViewPinPointLocationTopRight == self.pointLocation)
    {
        imageViewY += self.pinImageView.bounds.size.height / 2.0;
    }
    else if (RZMapViewPinPointLocationBottom == self.pointLocation ||
             RZMapViewPinPointLocationBottomLeft == self.pointLocation ||
             RZMapViewPinPointLocationBottomRight == self.pointLocation)
    {
        imageViewY -= self.pinImageView.bounds.size.height / 2.0;
    }
    
    self.bounds = CGRectMake(0, 0, newWidth, newHeight);
    self.pinImageView.center = CGPointMake(self.bounds.size.width / 2.0, (self.active ? self.popoverView.bounds.size.height : 0.0) + (self.pinImageView.bounds.size.height / 2.0));
    self.popoverView.center = CGPointMake(self.bounds.size.width / 2.0, self.popoverView.bounds.size.height / 2.0);
    
    CGAffineTransform currentTransform = self.transform;
    currentTransform.tx = 0;
    currentTransform.ty = 0;
    self.transform = CGAffineTransformTranslate(currentTransform, imageViewX, imageViewY);
}

- (void)pinTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pinViewTapped:)])
    {
        [self.delegate pinViewTapped:self];
    }
}

@end
