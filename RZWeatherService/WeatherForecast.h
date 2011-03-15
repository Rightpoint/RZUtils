//
//  WeatherForecast.h
//  RZUtils
//
//  Created by Craig Spitzkoff on 2/24/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WeatherForecast : NSObject
{
	// An array of WeatherForecastDay objects.
	NSMutableArray* _days;
}

@property (nonatomic, readonly) NSArray* days;

- (id)initWithXML:(NSData*)xmlData;

@end
