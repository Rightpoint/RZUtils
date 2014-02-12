//
//  NSDate+RZExtensions.m
//
//  Created by Nicholas Bonatsakis on 7/3/13.

//  Copyright (c) 2013 RaizLabs. 
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

+ (NSDate *)rz_startOfCurrentDay
{
    return [NSDate rz_startOfCurrentDayLocally:NO];
}

+ (NSDate *)rz_startOfCurrentDayLocally:(BOOL)locally
{
    return [[NSDate date] rz_dateByRemovingTimeLocally:locally];
}

- (NSDate *)rz_dateByRemovingTime
{
    return [self rz_dateByRemovingTimeLocally:NO];
}

- (NSDate *)rz_dateByRemovingTimeLocally:(BOOL)locally
{
    NSCalendar *cal = [RZCachedCurrentCalendar() copy];
    
    if (!locally)
    {
        [cal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    
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

- (BOOL)rz_isDateInRangeStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    return ([self compare:startDate] == NSOrderedDescending) && ([self compare:endDate] == NSOrderedAscending);
}

- (BOOL)rz_isDateInRangeOrEqualToStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    NSComparisonResult startCompare = [self compare:startDate];
    NSComparisonResult endCompare = [self compare:endDate];
    return (startCompare == NSOrderedDescending || startCompare == NSOrderedSame) && (endCompare == NSOrderedAscending || endCompare == NSOrderedSame);
}

@end

@implementation RZDateRange

+ (instancetype)dateRangeWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    RZDateRange *r = [RZDateRange new];
    r.startDate = startDate;
    r.endDate = endDate;
    return r;
}

- (BOOL)includesDate:(NSDate *)date
{
    return [self includesDate:date withInclusivity:kRZDateRangeIncludeStartEnd];
}

- (BOOL)includesDate:(NSDate *)date withInclusivity:(RZDateRangeInclusivity)inclusivity
{
    if (self.startDate == nil || self.endDate == nil) return NO;
    
    NSComparisonResult startComp = [date compare:self.startDate];
    NSComparisonResult endComp   = [date compare:self.endDate];
    
    BOOL inRange = NO;
    switch (inclusivity) {
        case kRZDateRangeIncludeStartEnd:
            inRange = (startComp != NSOrderedAscending) && (endComp != NSOrderedDescending);
            break;
            
        case kRZDateRangeExcludeStart:
            inRange = (startComp == NSOrderedDescending) && (endComp != NSOrderedDescending);
            break;
            
        case kRZDateRangeExcludeEnd:
            inRange = (startComp != NSOrderedAscending) && (endComp == NSOrderedAscending);
            break;
            
        case kRZDateRangeExcludeStartEnd:
            inRange = (startComp == NSOrderedDescending) && (endComp == NSOrderedAscending);
            break;
            
        default:
            break;
    }
    
    return inRange;
}

/*** copyWithZone: and equality/hash methods auto-implemented by AppCode ***/

- (id)copyWithZone:(NSZone *)zone {
    RZDateRange *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy.startDate = self.startDate;
        copy.endDate = self.endDate;
    }

    return copy;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToRange:other];
}

- (BOOL)isEqualToRange:(RZDateRange *)range {
    if (self == range)
        return YES;
    if (range == nil)
        return NO;
    if (self.startDate != range.startDate && ![self.startDate isEqualToDate:range.startDate])
        return NO;
    if (self.endDate != range.endDate && ![self.endDate isEqualToDate:range.endDate])
        return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.startDate hash];
    hash = hash * 31u + [self.endDate hash];
    return hash;
}


@end
