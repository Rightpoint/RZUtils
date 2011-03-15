//
//  WeatherLocation.h
//  RZUtils
//
//  Created by Craig Spitzkoff on 2/24/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RZXMLNode;

// WeatherLocation is the location a weather observation is taken or the
// location for which an observation at another location is applicable. 
@interface WeatherLocation : NSObject
{
	NSString* _fullName;
	NSString* _city;
	NSString* _state;
	NSString* _stateName;
	NSString* _country;
	NSString* _countryISO3166;
	NSString* _zip;

	double _latitude;
	double _longitude;
	double _elevation;
}

@property (nonatomic, retain) NSString* fullName;
@property (nonatomic, retain) NSString* city;
@property (nonatomic, retain) NSString* state;
@property (nonatomic, retain) NSString* stateName;
@property (nonatomic, retain) NSString* country;
@property (nonatomic, retain) NSString* countryISO3166;
@property (nonatomic, retain) NSString* zip;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) double elevation;

- (id)initWithParent:(RZXMLNode*)info;

@end
