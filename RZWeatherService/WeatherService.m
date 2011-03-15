//
//  WeatherService.m
//  RZUtils
//
//  Created by Craig Spitzkoff on 2/24/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import "WeatherService.h"

#import "WeatherForecast.h"
#import "WeatherObservation.h"

@implementation WeatherService

- (id)initWithDelegate:(id <WeatherServiceDelegate>)delegate
{
	if (self = [super init])
	{
		_delegate = delegate;
	}
	return self;
}

#pragma mark API methods

- (void)requestForcast:(NSString*)query
{
	PostData* postData = [[[PostData alloc] initWithDelegate:self] autorelease];
	postData.api = [_delegate forecastApiFormat];
	
	NSString* strURL = [NSString stringWithFormat:[_delegate forecastApiFormat], query];
	NSURL* url = [NSURL URLWithString:strURL];
	
	[postData getDataFromURL:url];
}


- (void)requestCurrentWeather:(NSString*)query
{
	PostData* postData = [[[PostData alloc] initWithDelegate:self] autorelease];
	postData.api = [_delegate currentConditionsApiFormat];
	
	NSString* strURL = [NSString stringWithFormat:[_delegate currentConditionsApiFormat], query];
	NSURL* url = [NSURL URLWithString:strURL];
	
	[postData getDataFromURL:url];
}

#pragma mark PostDataDelegate

// data was received from the post data request. 
- (void)postData:(PostData*)postData receivedData:(NSData*)data
{
	if ([postData.api isEqualToString:[_delegate currentConditionsApiFormat]])
	{
		if ([_delegate respondsToSelector:@selector(weatherService:receivedCurrentWeather:)])
		{
			WeatherObservation* observation = [[[WeatherObservation alloc] initWithXML:data] autorelease];
			[_delegate weatherService:self receivedCurrentWeather:observation];
		}
	}
	else if ([postData.api isEqualToString:[_delegate forecastApiFormat]])
	{
		if ([_delegate respondsToSelector:@selector(weatherService:receivedForcast:)])
		{
			WeatherForecast* forecast = [[[WeatherForecast alloc] initWithXML:data] autorelease];
			[_delegate weatherService:self receivedForcast:forecast];
		}
	}
}

// there was an error connecting to the specified URL. 
- (void)postData:(PostData*)postData error:(NSString*)error
{
	if ([postData.api isEqualToString:[_delegate currentConditionsApiFormat]])
	{
		[_delegate weatherService:self receivedCurrentWeather:nil];
	}
	else if ([postData.api isEqualToString:[_delegate forecastApiFormat]])
	{
		[_delegate weatherService:self receivedForcast:nil];
	}
}

@end