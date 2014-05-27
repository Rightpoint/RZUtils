//
//  RZLocationService.m
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

#import "RZLocationService.h"

NSString * const RZLocationServiceErrorDomain = @"RZLocationServiceErrorDomain";

#define kRZLDefaultUpdateTimeout        3.0
#define kRZLAcceptableAccuracyMeters    100.0
#define kRZLMaxAge                      5.0

@interface RZLocationService ()

@property (nonatomic, strong) CLLocation* bestEffortAtLocation;
@property (nonatomic, strong) NSMutableArray* successBlocks;
@property (nonatomic, strong) NSMutableArray* errorBlocks;
@property (nonatomic) int updateAtempts;
@property (nonatomic) BOOL fetchLocInProgress;
@property (nonatomic, readwrite, strong) CLLocation *lastLocation;
@property (nonatomic, readwrite, strong) CLPlacemark *lastPlacemark;
@property (nonatomic, strong) NSTimer *timeoutTimer;

@end

@implementation RZLocationService

+ (RZLocationService *)shared
{
    static RZLocationService *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[RZLocationService alloc] init];
    });
    
    return shared;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;

        _geocoder = [[CLGeocoder alloc] init];
        _successBlocks = [NSMutableArray array];
        _errorBlocks = [NSMutableArray array];
        _fetchLocInProgress = NO;
    
        _locationFetchTimeout = kRZLDefaultUpdateTimeout;
        _desiredAccuracyMeters = kRZLAcceptableAccuracyMeters;
    }
    return self;
}

- (void)dealloc
{
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}

- (void)locationWithCompletion:(RZLocationServiceSuccessBlock)successBlock
                               error:(RZLocationServiceErrorBlock)errorBlock
{
    if ([self locationServicesEnabled])
    {
        // if we're already waiting for a fetch and we get called again, just add the blocks.
        [self.successBlocks addObject:[successBlock copy]];
        [self.errorBlocks addObject:[errorBlock copy]];
        
        if (!self.fetchLocInProgress)
        {
            self.updateAtempts = 0;
            self.fetchLocInProgress = YES;
            self.bestEffortAtLocation = nil;
            [self.locationManager startUpdatingLocation];
            
            // Only schedule the timer if we are NOT waiting for authorization
            if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined)
            {
                [self scheduleTimeout];
            }
        }
    }
    else
    {
        NSError *err = [NSError errorWithDomain:RZLocationServiceErrorDomain
                                           code:RZLocationServiceErrorNotEnabled
                                       userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Location services are not enabled.", nil)}];
        errorBlock(err);
    }
}

- (BOOL)locationServicesEnabled
{
    return ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
            && [CLLocationManager locationServicesEnabled];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    // if the status is Authorized and we were waiting for authorization, start the timeout timer. 
    if (status == kCLAuthorizationStatusAuthorized && self.fetchLocInProgress)
    {
        [self scheduleTimeout];
    }
}

- (void)scheduleTimeout
{
    if (!self.timeoutTimer)
    {
        self.timeoutTimer = [NSTimer timerWithTimeInterval:self.locationFetchTimeout
                                                             target:self
                                                           selector:@selector(locationUpdateTimeout)
                                                           userInfo:nil
                                                            repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.timeoutTimer forMode:NSRunLoopCommonModes];
        
    }
}

- (void)resetBlocks
{
    [self.successBlocks removeAllObjects];
    [self.errorBlocks removeAllObjects];
}

#pragma mark - Location Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.updateAtempts++;
    CLLocation* newLocation = [locations lastObject];
        
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > kRZLMaxAge)
    {
        return;
    }
    
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0)
    {
        return;
    }
    
    // test the measurement to see if it is more accurate than the previous measurement
    if (self.bestEffortAtLocation == nil || self.bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy)
    {
        // store the location as the "best effort"
        self.bestEffortAtLocation = newLocation;
        
        // test the measurement to see if it meets the desired accuracy
        //
        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue
        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of
        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
        //
        double acceptable = self.desiredAccuracyMeters;
        if (newLocation.horizontalAccuracy <= acceptable)
        {
            [self.timeoutTimer invalidate];
            self.timeoutTimer = nil;
            [self.locationManager stopUpdatingLocation];
            for (RZLocationServiceSuccessBlock b in self.successBlocks)
            {
                b(newLocation);
            }
            self.lastLocation = newLocation;
            self.fetchLocInProgress = NO;
            [self resetBlocks];
        }
    }
}

- (void)locationUpdateTimeout
{
    if (self.bestEffortAtLocation)
    {
        [self.locationManager stopUpdatingLocation];
        for (RZLocationServiceSuccessBlock b in self.successBlocks)
        {
            b(self.bestEffortAtLocation);
        }
        self.lastLocation = self.bestEffortAtLocation;
        self.fetchLocInProgress = NO;
        [self resetBlocks];
    } else
    {
        NSError* error = [NSError errorWithDomain:RZLocationServiceErrorDomain
                                             code:RZLocationServiceErrorTimeout
                                         userInfo:@{NSLocalizedDescriptionKey : @"Timed out waiting for location."}];
        
        [self locationManager:self.locationManager didFailWithError:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // The location "unknown" error simply means the manager is currently unable to get the location.
    // We can ignore this error for the scenario of getting a single location fix, because we already have a
    // timeout that will stop the location manager to save power.
    if ([error code] != kCLErrorLocationUnknown)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locationUpdateTimeout) object:nil];
        [self.locationManager stopUpdatingLocation];
        for (RZLocationServiceErrorBlock b in self.errorBlocks)
        {
            b(error);
        }
        self.fetchLocInProgress = NO;
        [self resetBlocks];
    }
}

#pragma mark - Geocoding

- (void)placemarkAtCurrentLocationWithCompletion:(RZLocationServiceSuccessBlock)successBlock
                                                 error:(RZLocationServiceErrorBlock)errorBlock
{
    __weak RZLocationService *weakSelf = self;
    [self locationWithCompletion:^(id result) {
        [weakSelf.geocoder reverseGeocodeLocation:result
                            completionHandler:^(NSArray *placemarks, NSError *error) {
                                if (error && errorBlock)
                                {
                                    errorBlock(error);
                                }
                                else
                                {
                                    CLPlacemark *placemark = placemarks.count > 1 ? placemarks[0] : nil;
                                    weakSelf.lastPlacemark = placemark;
                                    
                                    if (successBlock)
                                    {
                                        successBlock(placemark);
                                    }
                                }
                            }];
    } error:^(NSError *error) {
        if (errorBlock)
        {
            errorBlock(error);
        }
    }];
}

@end
