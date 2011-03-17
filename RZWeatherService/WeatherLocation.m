//
//  WeatherLocation.m
//  RZUtils
//
//  Created by Craig Spitzkoff on 2/24/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import "WeatherLocation.h"

#import "RZXMLNode.h"
#import "RZXMLParser.h"

@implementation WeatherLocation

@synthesize fullName		= _fullName;
@synthesize city			= _city;
@synthesize state			= _state;
@synthesize stateName		= _stateName;
@synthesize country			= _country;
@synthesize countryISO3166	= _countryISO3166;
@synthesize zip				= _zip;
@synthesize latitude		= _latitude;
@synthesize longitude		= _longitude;
@synthesize elevation		= _elevation;

- (id)initWithParent:(RZXMLNode*)info
{
	if (self = [super init])
	{
		self.fullName = [info childNamed:@"full"].value;
		self.city = [info childNamed:@"city"].value;
		self.state = [info childNamed:@"state"].value;
		self.stateName = [info childNamed:@"state_name"].value;
		self.country = [info childNamed:@"country"].value;
		self.countryISO3166 = [info childNamed:@"country_iso3166"].value;
		self.zip = [info childNamed:@"zip"].value;
		self.latitude = [[info childNamed:@"latitude"].value doubleValue];
		self.longitude = [[info childNamed:@"latitude"].value doubleValue];
		self.elevation = [[info childNamed:@"elevation"].value doubleValue];
	}
	return self;
}

- (void)dealloc
{
	self.fullName		= nil;
	self.city			= nil;
	self.state			= nil;
	self.stateName		= nil;
	self.country		= nil;
	self.countryISO3166 = nil;
	self.zip			= nil;
	
	[super dealloc];
}

@end
