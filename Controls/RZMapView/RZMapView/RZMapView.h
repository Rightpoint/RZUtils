//
//  RZMapView.h
//
//  Created by Joe Goullaud on 12/19/11.
//  Copyright (c) 2011 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZMapViewLocation.h"
#import "RZMapViewPin.h"

@class RZMapView;

@protocol RZMapViewDelegate <NSObject, UIScrollViewDelegate>

@optional
- (void)mapView:(RZMapView*)mapView regionTapped:(RZMapViewLocation*)region;
- (void)mapView:(RZMapView*)mapView pinTapped:(RZMapViewPin*)pin;

- (UIView*)mapView:(RZMapView*)mapView popoverViewForPin:(RZMapViewPin*)pin;
- (void)mapView:(RZMapView *)mapView pinAddAnimationDidFinish:(RZMapViewPin *)pin;

@end

@interface RZMapView : UIScrollView <RZMapViewPinDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (retain, nonatomic) UIImage *mapImage;
@property (retain, nonatomic, readonly) NSSet *mapRegions;
@property (retain, nonatomic, readonly) NSSet *mapPins;
@property (retain, nonatomic) RZMapViewPin *activePin;
@property (assign, nonatomic) id<RZMapViewDelegate> delegate;

- (void)setActivePin:(RZMapViewPin *)activePin animated:(BOOL)animated;

- (void)addMapRegions:(NSSet*)objects;
- (void)addMapRegion:(RZMapViewLocation*)region;
- (void)removeMapRegions:(NSSet*)objects;
- (void)removeMapRegion:(RZMapViewLocation*)region;

- (void)addMapPins:(NSSet*)objects;
- (void)addMapPins:(NSSet*)objects animated:(BOOL)animated;
- (void)addMapPin:(RZMapViewPin*)pin;
- (void)addMapPin:(RZMapViewPin*)pin animated:(BOOL)animated;
- (void)removeMapPins:(NSSet*)objects;
- (void)removeMapPin:(RZMapViewPin*)pin;

@end
