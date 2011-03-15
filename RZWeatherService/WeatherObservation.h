//
//  WeatherObservation.h
//  RZUtils
//
//  Created by Craig Spitzkoff on 2/24/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WeatherLocation;

// WeatherObservation represents the observation of the weather at a single
// point in time. Information is provided about where and when the observation
// was taken.
@interface WeatherObservation : NSObject
{
	WeatherLocation* _displayLocation;
	WeatherLocation* _observationLocation;
	
	NSString*	_stationID; 
	NSDate*		_observationTime;
	NSDate*		_localTime;
	NSString*	_weather;
	NSInteger	_tempF;
	NSInteger	_tempC;
	NSInteger	_relativeHumdity; // percentage. 86 means 86% or 0.86 
	NSString*	_windString; 
	NSString*	_windDirection;
	NSInteger	_windDegrees;
	NSInteger	_windMPH;
	NSInteger	_windGustMPH;
	NSString*	_pressureString;
	NSInteger	_pressureMB;
	NSInteger	_pressureIN;
	NSString*	_dewpointString;
	NSInteger	_dewpointF;
	NSInteger	_dewpointC;
	NSString*	_heatIndexString;
	NSInteger	_heatIndexF;
	NSInteger	_heatIndexC;
	NSString*	_windchillString;
	NSInteger	_windchillF;
	NSInteger	_windchillC;
	float		_visibilityMI;
	float		_visibilityKM;
	NSString*	_icon;
	
}

@property (nonatomic, retain) WeatherLocation*	displayLocation;
@property (nonatomic, retain) WeatherLocation*	observationLocation;
@property (nonatomic, retain) NSString*			stationID; 
@property (nonatomic, retain) NSDate*			observationTime;
@property (nonatomic, retain) NSDate*			localTime;
@property (nonatomic, retain) NSString*			weather;
@property (nonatomic) NSInteger					tempF;
@property (nonatomic) NSInteger					tempC;
@property (nonatomic) NSInteger					relativeHumidity; 
@property (nonatomic, retain) NSString*			windString; 
@property (nonatomic, retain) NSString*			windDirection;
@property (nonatomic) NSInteger					windDegrees;
@property (nonatomic) NSInteger					windMPH;
@property (nonatomic) NSInteger					windGustMPH;
@property (nonatomic, retain) NSString*			pressureString;
@property (nonatomic) NSInteger					pressureMB;
@property (nonatomic) NSInteger					pressureIN;
@property (nonatomic, retain) NSString*			dewpointString;
@property (nonatomic) NSInteger					dewpointF;
@property (nonatomic) NSInteger					dewpointC;
@property (nonatomic, retain) NSString*			heatIndexString;
@property (nonatomic) NSInteger					heatIndexF;
@property (nonatomic) NSInteger					heatIndexC;
@property (nonatomic, retain) NSString*			windchillString;
@property (nonatomic) NSInteger					windchillF;
@property (nonatomic) NSInteger					windchillC;
@property (nonatomic) float						visibilityMI;
@property (nonatomic) float						visibilityKM;
@property (nonatomic, retain) NSString*			icon;

- (id)initWithXML:(NSData*)xmlData;

@end
