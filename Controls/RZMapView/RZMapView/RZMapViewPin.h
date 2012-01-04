//
//  RZMapViewPin.h
//  SolidWorks World 2012
//
//  Created by Joe Goullaud on 1/4/12.
//  Copyright (c) 2012 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZMapViewLocation.h"

typedef enum {
    RZMapViewPinPointLocationTopLeft,
    RZMapViewPinPointLocationTop,
    RZMapViewPinPointLocationTopRight,
    RZMapViewPinPointLocationLeft,
    RZMapViewPinPointLocationCenter,
    RZMapViewPinPointLocationRight,
    RZMapViewPinPointLocationBottomLeft,
    RZMapViewPinPointLocationBottom,                                            // Default Pin Point Location
    RZMapViewPinPointLocationBottomRight
} RZMapViewPinPointLocation;

@interface RZMapViewPin : UIView

@property (retain, nonatomic, readonly) UIImage *pinImage;
@property (retain, nonatomic) UIImage *popoverBackgroundImage;
@property (retain, nonatomic) UIView *popoverView;
@property (retain, nonatomic) RZMapViewLocation *location;
@property (assign, nonatomic, getter = isActive) BOOL active;
@property (assign, nonatomic, readonly) RZMapViewPinPointLocation pointLocation;

- (void)setPinImage:(UIImage *)pinImage withPointLocation:(RZMapViewPinPointLocation)pointLocation;
- (void)setActive:(BOOL)active animated:(BOOL)animated;

@end
