//
//  WeatherObservation.m
//  RZUtils
//
//  Created by Craig Spitzkoff on 2/24/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import "WeatherObservation.h"
#import "WeatherLocation.h"
#import "RZXMLParser.h"
#import "RZXMLNode.h"

@implementation WeatherObservation

@synthesize displayLocation			= _displayLocation;
@synthesize observationLocation		= _observationLocation;
@synthesize stationID				= _stationID; 
@synthesize observationTime			= _observationTime;
@synthesize localTime				= _localTime;
@synthesize weather					= _weather;
@synthesize tempF					= _tempF;
@synthesize tempC					= _tempC;
@synthesize relativeHumidity		= _relativeHumdity; 
@synthesize windString				= _windString; 
@synthesize windDirection			= _windDirection;
@synthesize windDegrees				= _windDegrees;
@synthesize windMPH					= _windMPH;
@synthesize windGustMPH				= _windGustMPH;
@synthesize pressureString			= _pressureString;
@synthesize pressureMB				= _pressureMB;
@synthesize pressureIN				= _pressureIN;
@synthesize dewpointString			= _dewpointString;
@synthesize dewpointF				= _dewpointF;
@synthesize dewpointC				= _dewpointC;
@synthesize heatIndexString			= _heatIndexString;
@synthesize heatIndexF				= _heatIndexF;
@synthesize heatIndexC				= _heatIndexC;
@synthesize windchillString			= _windchillString;
@synthesize windchillF				= _windchillF;
@synthesize windchillC				= _windchillC;
@synthesize visibilityMI			= _visibilityMI;
@synthesize visibilityKM			= _visibilityKM;
@synthesize icon					= _icon;


- (void)dealloc
{
	self.displayLocation		= nil;
	self.observationLocation	= nil;
	self.displayLocation		= nil;
	self.observationLocation	= nil;
	self.stationID				= nil; 
	self.observationTime		= nil;
	self.localTime				= nil;
	self.weather				= nil;
	self.windString				= nil; 
	self.windDirection			= nil;
	self.pressureString			= nil;
	self.dewpointString			= nil;
	self.heatIndexString		= nil;
	self.windchillString		= nil;
	self.icon					= nil;   
	
	[super dealloc];
}

- (id)initWithXML:(NSData*)xmlData
{
	if (self = [super init])
	{
		RZXMLParser* parser = [[[RZXMLParser alloc] initWithData:xmlData] autorelease];
		[parser parse];
		
		RZXMLNode* observation = [parser root];
		
		NSArray* children = parser.root.children;
		if ([children count] > 0) 
		{
			self.dewpointC = [[observation childNamed:@"dewpoint_c"].value intValue];
			self.dewpointF = [[observation childNamed:@"dewpoint_f"].value intValue];
			self.dewpointString = [observation childNamed:@"dewpoint_string"].value;
			
			self.displayLocation = [[[WeatherLocation alloc] initWithParent:[observation childNamed:@"display_location"]] autorelease];
			self.observationLocation = [[[WeatherLocation alloc] initWithParent:[observation childNamed:@"observation_location"]] autorelease];
			
			self.heatIndexC = [[observation childNamed:@"heat_index_c"].value intValue];

			self.heatIndexF = [[observation childNamed:@"heat_index_f"].value intValue];
			self.heatIndexString = [observation childNamed:@"heat_index_string"].value;
			self.icon = [observation childNamed:@"icon"].value;
			self.localTime = [NSDate dateWithTimeIntervalSince1970:[[observation childNamed:@"local_epoch"].value intValue]];
			self.observationTime = [NSDate dateWithTimeIntervalSince1970:[[observation childNamed:@"observation_epoch"].value intValue]];
			self.pressureIN = [[observation childNamed:@"pressure_in"].value intValue];
			self.pressureMB = [[observation childNamed:@"pressure_mb"].value intValue];
			self.pressureString = [observation childNamed:@"pressure_string"].value;
			self.relativeHumidity = [[[observation childNamed:@"pressure_string"].value stringByReplacingOccurrencesOfString:@"%" withString:@""] intValue];
			self.stationID = [observation childNamed:@"station_id"].value;
			self.tempC = [[observation childNamed:@"temp_c"].value intValue];
			self.tempF = [[observation childNamed:@"temp_f"].value intValue];
			self.visibilityKM = [[observation childNamed:@"visibility_km"].value floatValue];
			self.visibilityMI = [[observation childNamed:@"visibility_mi"].value floatValue];
			self.weather = [observation childNamed:@"weather"].value;
			self.windDegrees = 	[[observation childNamed:@"wind_degrees"].value intValue];
			self.windDirection = [observation childNamed:@"wind_dir"].value;
			self.windGustMPH = [[observation childNamed:@"wind_gust_mph"].value intValue];
			self.windMPH = [[observation childNamed:@"wind_mph"].value intValue];
			self.windString = [observation childNamed:@"wind_string"].value;
			self.windchillC = [[observation childNamed:@"windchill_c"].value intValue];
			self.windchillF = [[observation childNamed:@"windchill_f"].value intValue];
			self.windchillString = [observation childNamed:@"wind_string"].value;
		}
	}
	return self;
}

@end
