//
//  ForwardGeocoder.h
//  RZUtils
//
//  Created by jkaufman on 1/26/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "PostData.h"

@class ForwardGeocoder;

@protocol ForwardGeocoderDelegate

@optional

// request google Maps API key for inclusion in query
- (NSString *)googleMapsAPIKey;

// alert delegate of completion with result
- (void)forwardGeocoder:(ForwardGeocoder *)geocoder didFinishSuccessfully:(BOOL)success;

@end


@interface ForwardGeocoder : NSObject <PostDataDelegate> {
	
	// Many more values exist, but these are sufficient for most uses.
	// Going forward, it would be nice to have a generic "get me all
	// geodata from string" class that returns objects structured for
	// MapPoint, Google Maps, or MapKit
	
	id			_delegate;						// Delegate responsible for providing Google API key	
	NSString	*_unformattedAddress;			// Address used to query Google Maps

	PostData	*_dataPoster;					// PostData instance used to handle query
	NSString	*_formattedAddress;				// Address result in form, "Locality, Administrative Area, Country"	
	NSString	*_administrativeAreaName;		// State
	NSString	*_localityName;					// City
	NSString	*_countryName;					// Country
	CLLocation	*_coordinate;					// Point coordinate
}

@property (readwrite, assign)	id			delegate;
@property (nonatomic, readonly)	NSString	*formattedAddress;
@property (nonatomic, readonly)	NSString	*administrativeAreaName;
@property (nonatomic, readonly)	NSString	*localityName;
@property (nonatomic, readonly)	NSString	*countryName;
@property (nonatomic, readonly)	CLLocation	*coordinate;


- (id)initWithString:(NSString *)address delegate:(id)aDelegate;

@end
