//
//  RZLocationService.h
//  RZUtils
//
//  Created by Nick Bonatsakis on 11/27/12.
//  Copyright (c) 2013 Raizlabs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^RZLocationServiceSuccessBlock)(id result);
typedef void(^RZLocationServiceErrorBlock)(NSError* error);

@interface RZLocationService : NSObject <CLLocationManagerDelegate>

/**
 *  The underlying locationManager.
 */
@property (nonatomic, readonly) CLLocationManager* locationManager;

/**
 *  The underlying geocoder
 */
@property (nonatomic, readonly) CLGeocoder* geocoder;

/**
 *  The last fetched location.
 */
@property (nonatomic, readonly, strong) CLLocation *lastLocation;

/**
 *  The last fetched placemark.
 */
@property (nonatomic, readonly, strong) CLPlacemark *lastPlacemark;

+ (RZLocationService *)shared;

/**
 *  Fetches the current location.
 *
 *  @param successBlock Invoked on success with a CLLocation object.
 *  @param errorBlock   Invoked on failure with an NSError object.
 */
- (void)locationWithCompletion:(RZLocationServiceSuccessBlock)successBlock
                               error:(RZLocationServiceErrorBlock)errorBlock;

/**
 *  Fetches the nearest placemark for the current location.
 *
 *  @param successBlock Invoked on success with the nearest CLPlacemark object.
 *  @param errorBlock   Invoked on failure.
 */
- (void)placemarkAtCurrentLocationWithCompletion:(RZLocationServiceSuccessBlock)successBlock
                               error:(RZLocationServiceErrorBlock)errorBlock;

@end
