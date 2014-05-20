//
//  RZLocationService.h
//  RZExtensions
//
//  Created by Nick Bonatsakis on 11/27/12.

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
