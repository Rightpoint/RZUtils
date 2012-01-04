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

@property (retain, nonatomic) UIImageView *pinImageView;
@property (retain, nonatomic) UIImageView *popoverBackgroundImageView;

@end

@implementation RZMapViewPin

@synthesize pinImage = _pinImage;
@synthesize popoverBackgroundImage = _popoverBackgroundImage;
@synthesize popoverView = _popoverView;
@synthesize location = _location;
@synthesize active = _active;
@synthesize pointLocation = _pointLocation;

@synthesize pinImageView = _pinImageView;
@synthesize popoverBackgroundImageView = _popoverBackgroundImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = NO;
        self.pointLocation = RZMapViewPinPointLocationBottom;
        
    }
    return self;
}

- (void)dealloc
{
    [_pinImage release];
    [_popoverBackgroundImage release];
    [_popoverView release];
    [_location release];
    
    [_pinImageView release];
    [_popoverBackgroundImageView release];
    
    [super dealloc];
}

- (void)setPinImage:(UIImage *)pinImage withPointLocation:(RZMapViewPinPointLocation)pointLocation
{
    self.pointLocation = pointLocation;
    self.pinImage = pinImage;
    
    [self.pinImageView removeFromSuperview];
    self.pinImageView = [[[UIImageView alloc] initWithImage:self.pinImage] autorelease];
    
    CGPoint currentCenter = self.center;
    
    CGFloat newWidth = self.pinImageView.bounds.size.width;
    CGFloat newHeight = self.pinImageView.bounds.size.height;
    
    if (RZMapViewPinPointLocationTop != pointLocation &&
        RZMapViewPinPointLocationCenter != pointLocation &&
        RZMapViewPinPointLocationBottom != pointLocation)
    {
        newWidth *= 2.0;
    }
    
    if (RZMapViewPinPointLocationLeft != pointLocation &&
        RZMapViewPinPointLocationCenter != pointLocation &&
        RZMapViewPinPointLocationRight != pointLocation)
    {
        newHeight *= 2.0;
    }
    
    CGFloat imageViewX = 0.0;
    CGFloat imageViewY = 0.0;
    
    if (RZMapViewPinPointLocationRight == pointLocation ||
        RZMapViewPinPointLocationTopRight == pointLocation ||
        RZMapViewPinPointLocationBottomRight == pointLocation)
    {
        imageViewX = self.pinImageView.bounds.size.width;
    }
    
    if (RZMapViewPinPointLocationTop == pointLocation ||
        RZMapViewPinPointLocationTopLeft == pointLocation ||
        RZMapViewPinPointLocationTopRight == pointLocation)
    {
        imageViewY = self.pinImageView.bounds.size.height;
    }
    
    self.bounds = CGRectMake(0, 0, newWidth, newHeight);
    self.pinImageView.frame = (CGRect){imageViewX, imageViewY, self.pinImageView.bounds.size};
    [self addSubview:self.pinImageView];
    
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
    
    if (active)
    {
        [self addSubview:self.popoverView];
        self.popoverView.center = CGPointMake(self.pinImageView.center.x, self.pinImageView.center.y - (self.pinImageView.bounds.size.height / 2.0) - (self.popoverView.bounds.size.height / 2.0));
        
        if (animated)
        {
            CGPoint finalCenter = self.popoverView.center;
            
            self.popoverView.center = CGPointMake(finalCenter.x, finalCenter.y + (self.popoverView.bounds.size.height / 2.0));
            self.popoverView.transform = CGAffineTransformMakeScale(0.01, 0.01);
            
            [UIView animateWithDuration:0.25 
                                  delay:0 
                                options:UIViewAnimationOptionCurveEaseInOut 
                             animations:^{
                                self.popoverView.center = finalCenter;
                                self.popoverView.transform = CGAffineTransformIdentity;
                            } 
                             completion:nil];
        }
    }
    else if (animated)
    {
        CGPoint endCenter = CGPointMake(self.popoverView.center.x, self.popoverView.center.y + (self.popoverView.bounds.size.height / 2.0));
        
        [UIView animateWithDuration:0.25 
                              delay:0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             self.popoverView.center = endCenter;
                             self.popoverView.transform = CGAffineTransformMakeScale(0.01, 0.01);
                         } 
                         completion:^(BOOL finished) {
                             [self.popoverView removeFromSuperview];
                         }];
    }
    else
    {
        [self.popoverView removeFromSuperview];
    }
    
    _active = active;
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

@end
