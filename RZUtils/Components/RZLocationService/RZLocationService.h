//
//  RZLocationService.h
//  RZUtils
//
//  Created by Nick Bonatsakis on 11/27/12.
//  Copyright (c) 2013 Raizlabs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

OBJC_EXTERN NSString * const RZLocationServiceErrorDomain;

typedef NS_ENUM(NSInteger, RZLocationServiceErrorCode)
{
    RZLocationServiceErrorTimeout    = 1,
    RZLocationServiceErrorNotEnabled = 2
};


typedef void(^RZLocationServiceSuccessBlock)(id result);
typedef void(^RZLocationServiceErrorBlock)(NSError* error);

/**
 *  This class exposes location services as block-based interfaces. It also provides the following benefits over using raw location fetching:
 *
 *   - Filters out stale locations on fetch and waits for a location with an acceptable accuracy, falling back on the "best effort" location.
 *   - On location fetch, if not authorized for location, operations are suspended while the user is prompted for permission.
 *   - Caches most recent location and placemarks
 *   - Combines location + placemark fetch into one handy interface.
 *   - Based on Apple's own location services sample code.
 *
 *  NOTE: All methods are assumed to be called from the main thread. 
 */
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

/**
 *  The amount of time alloted before a location fetch operation fails. When a failure
 *  occurs, the "best effort" location is returned, or an error if no location has been found.
 */
@property (nonatomic, assign) NSTimeInterval locationFetchTimeout;

/**
 *  The desired accuracy in meters. This should be a "real" value, do not use kCLLocationAccuracyBest or other constants. 
 */
@property (nonatomic, assign) double desiredAccuracyMeters;

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
