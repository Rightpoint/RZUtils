//
//  RZMapView.h
//
//  Created by Joe Goullaud on 12/19/11.
//  Copyright (c) 2011 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZMapViewLocation.h"

@protocol RZMapViewDelegate;

@interface RZMapView : UIScrollView <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (retain, nonatomic) UIImage *mapImage;
@property (retain, nonatomic, readonly) NSSet *mapRegions;
@property (assign, nonatomic) id<RZMapViewDelegate> delegate;

- (void)addMapRegions:(NSSet*)objects;
- (void)addMapRegion:(RZMapViewLocation*)region;
- (void)removeMapRegions:(NSSet*)objects;
- (void)removeMapRegion:(RZMapViewLocation*)region;

@end

@protocol RZMapViewDelegate <NSObject, UIScrollViewDelegate>

- (void)mapView:(RZMapView*)mapView regionTapped:(RZMapViewLocation*)region;

@end