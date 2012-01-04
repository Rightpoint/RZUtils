//
//  RZMapViewLocation.m
//
//  Created by Joe Goullaud on 12/19/11.
//  Copyright (c) 2011 Raizlabs. All rights reserved.
//

#import "RZMapViewLocation.h"


@interface RZMapViewLocation ()

@end

@implementation RZMapViewLocation

@synthesize locationName = _locationName;
@synthesize locationId = _locationId;
@synthesize rect = _rect;
@synthesize delegate = _delegate;

+ (RZMapViewLocation*)mapViewLocationWithRect:(CGRect)rect name:(NSString*)name locationId:(NSString*)locationId delegate:(id<RZMapViewLocationDelegate>)delegate
{
    RZMapViewLocation *location = [[[RZMapViewLocation alloc] initWithRect:rect name:name locationId:locationId] autorelease];
    location.delegate = delegate;
    return location;
}

+ (RZMapViewLocation*)mapViewLocationWithX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height name:(NSString*)name locationId:(NSString*)locationId delegate:(id<RZMapViewLocationDelegate>)delegate
{
    return [RZMapViewLocation mapViewLocationWithRect:CGRectMake(x, y, width, height) name:name locationId:locationId delegate:delegate];
}

- (id)initWithRect:(CGRect)rect name:(NSString*)name locationId:(NSString*)locationId
{
    if ((self = [super initWithFrame:rect]))
    {
        self.rect = rect;
        self.locationName = name;
        self.locationId = locationId;
    }
    
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    
    [_locationName release];
    [_locationId release];
    
    [super dealloc];
}

- (CGFloat)x
{
    return self.rect.origin.x;
}

- (CGFloat)y
{
    return self.rect.origin.y;
}

- (CGFloat)width
{
    return self.rect.size.width;
}

- (CGFloat)height
{
    return self.rect.size.height;
}

@end
