//
//  WeatherForecastDay.h
//  RZUtils
//
//  Created by Robert Sesek on 2/25/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RZXMLNode;

// This class represents a single day of a forecast.
@interface WeatherForecastDay : NSObject
{
	NSDate* _date;
	NSInteger _highF;
	NSInteger _highC;
	NSInteger _lowF;
	NSInteger _lowC;
	NSInteger _chanceOfPrecipitation;  // A percentage ranging from 0 to 100.
	NSString* _conditions;  // A description of the conditions.
	NSString* _icon;
	NSString* _skyIcon;
}
@property (nonatomic, retain) NSDate* date;
@property (nonatomic) NSInteger highF;
@property (nonatomic) NSInteger highC;
@property (nonatomic) NSInteger lowF;
@property (nonatomic) NSInteger lowC;
@property (nonatomic) NSInteger chanceOfPrecipitation;
@property (nonatomic, retain) NSString* conditions;
@property (nonatomic, retain) NSString* icon;
@property (nonatomic, retain) NSString* skyIcon;

- (id)initWithNode:(RZXMLNode*)node;

@end
