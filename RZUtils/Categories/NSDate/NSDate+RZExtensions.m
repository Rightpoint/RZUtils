//
//  NSDate+RZExtensions.m
//
//  Created by Nicholas Bonatsakis on 7/3/13.
//  Copyright (c) 2013 RaizLabs. All rights reserved.
//

#import "NSDate+RZExtensions.h"

static NSCalendar *s_cachedAutoCurrentCalendar = nil;

static NSCalendar * RZCachedCurrentCalendar()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_cachedAutoCurrentCalendar = [NSCalendar autoupdatingCurrentCalendar];
    });
    
    return s_cachedAutoCurrentCalendar;
}

@implementation NSDate (RZExtensions)

- (NSDate *)rz_dateByRemovingTime
{
    NSCalendar *cal = RZCachedCurrentCalendar();
    NSDateComponents *components = [cal components:(NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self];

    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    return [cal dateFromComponents:components];
}

- (NSDate *)rz_dateByAddingDays:(NSInteger)days
{
    return [self dateByAddingTimeInterval:(60*60*24*days)];
}

- (BOOL)rz_isSameDayAsDate:(NSDate *)date
{
    return [self rz_isSameDayAsDate:date locally:NO];
}

- (BOOL)rz_isSameDayAsDate:(NSDate *)date locally:(BOOL)locally
{
    NSCalendar* calendar = [RZCachedCurrentCalendar() copy];
    
    if (!locally)
    {
        [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:self];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date];
    
    return (comp1.day == comp2.day) && (comp1.month == comp2.month) && (comp1.year == comp2.year);
}

- (NSInteger)rz_dayOffsetFromDate:(NSDate *)date
{
    NSTimeInterval difference = [[self rz_dateByRemovingTime] timeIntervalSinceDate:[date rz_dateByRemovingTime]];
    return round(difference/(3600*24));
}

@end