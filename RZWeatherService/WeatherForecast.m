//
//  WeatherForecast.m
//  RZUtils
//
//  Created by Craig Spitzkoff on 2/24/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import "WeatherForecast.h"

#import "RZXMLNode.h"
#import "RZXMLParser.h"
#import "WeatherForecastDay.h"

@implementation WeatherForecast

@synthesize days = _days;

- (id)initWithXML:(NSData*)xmlData
{
	if (self = [super init])
	{
		RZXMLParser* parser = [[[RZXMLParser alloc] initWithData:xmlData] autorelease];
		[parser parse];
		
		NSArray* children = parser.root.children;
		if ([children count] > 0) 
		{
			_days = [NSMutableArray new];
			
			NSArray* forecast = [parser.root childNamed:@"simpleforecast"].children;
			for (RZXMLNode* day in forecast)
				[_days addObject:[[[WeatherForecastDay alloc] initWithNode:day] autorelease]];
		}
	}
	return self;
}

- (void)dealloc
{
	[_days release];
	[super dealloc];
}

@end
