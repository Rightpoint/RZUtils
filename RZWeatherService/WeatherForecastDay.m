//
//  WeatherForecastDay.m
//  RZUtils
//
//  Created by Robert Sesek on 2/25/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import "WeatherForecastDay.h"

#import "RZXMLParser.h"

@implementation WeatherForecastDay

@synthesize date = _date;
@synthesize highF = _highF;
@synthesize highC = _highC;
@synthesize lowF = _lowF;
@synthesize lowC = _lowC;
@synthesize chanceOfPrecipitation = _chanceOfPrecipitation;
@synthesize conditions = _conditions;
@synthesize icon = _icon;
@synthesize skyIcon = _skyIcon;

- (id)initWithNode:(RZXMLNode*)node
{
	if (self = [super init])
	{
		RZXMLNode* date = [node childNamed:@"date"];
		self.date = [NSDate dateWithTimeIntervalSince1970:[[date childNamed:@"epoch"].value intValue]];
		
		RZXMLNode* high = [node childNamed:@"high"];
		self.highF = [[high childNamed:@"fahrenheit"].value intValue];
		self.highC = [[high childNamed:@"celsius"].value intValue];
		
		RZXMLNode* low = [node childNamed:@"low"];
		self.lowF = [[low childNamed:@"fahrenheit"].value intValue];
		self.lowC = [[low childNamed:@"celsius"].value intValue];
		
		self.chanceOfPrecipitation = [[node childNamed:@"pop"].value intValue];  // I love how this is documented.
		
		self.conditions = [node childNamed:@"conditions"].value;
		
		self.icon = [node childNamed:@"icon"].value;
		self.skyIcon = [node childNamed:@"skyicon"].value;
	}
	return self;
}

- (void)dealloc
{
	self.date = nil;
	self.conditions = nil;
	self.icon = nil;
	self.skyIcon = nil;
	[super dealloc];
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"Forecast for %@: Low: %dºC, High: %dºC, PoP: %d%%. %@.",
		_date, _lowC, _highC, _chanceOfPrecipitation, _conditions];
}

@end
