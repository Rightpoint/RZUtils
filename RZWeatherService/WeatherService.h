//
//  WeatherService.h
//  RZUtils
//
//  Created by Craig Spitzkoff on 2/24/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RZUtils/PostData.h>

@class WeatherObservation;
@class WeatherForecast;
@class WeatherService;
@protocol WeatherServiceDelegate;

// The WeatherService is a simple interface to request weather data for either
// current conditions or a forecast.
@interface WeatherService : NSObject <PostDataDelegate>
{
	id <WeatherServiceDelegate> _delegate;
}

- (id)initWithDelegate:(id <WeatherServiceDelegate>) delegate;

// Request the forcast for a zip code, or city, state or (lat,long) pair.
- (void)requestForcast:(NSString*)query;

// Request the current weather for a zip code, or city,state or Lat,Lon
- (void)requestCurrentWeather:(NSString*)query;

@end

////////////////////////////////////////////////////////////////////////////////

@protocol WeatherServiceDelegate <NSObject>

// Provider of Forecast API format (eg. http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=%@ )
- (NSString*) forecastApiFormat;

// Provider of current conditions API format (eg. http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=%@ )
- (NSString*) currentConditionsApiFormat;

@optional

// Callback for |-requestCurrentWeather:|.
- (void)weatherService:(WeatherService*)service receivedCurrentWeather:(WeatherObservation*)observation;

// Callback for |-requestForecast:|.
- (void)weatherService:(WeatherService*)service receivedForcast:(WeatherForecast*)forecast; 

@end