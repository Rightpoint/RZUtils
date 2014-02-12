//
//  NSDate+RZExtensions.h
//
//  Created by Nicholas Bonatsakis on 7/3/13.

//  Copyright (c) 2013 RaizLabs. 
//

#import <Foundation/Foundation.h>

@interface NSDate (RZExtensions)

// Start of current day without time (midnight)
// By default uses GMT midnight
+ (NSDate *)rz_startOfCurrentDay;

// If locally is YES, will use local time zone midnight
+ (NSDate *)rz_startOfCurrentDayLocally:(BOOL)locally;

// Normalize this NSDate to the start of the day (00:00:00)
// By default uses GMT midnight
- (NSDate *)rz_dateByRemovingTime;

// If locally is YES, will use local time zone midnight
- (NSDate *)rz_dateByRemovingTimeLocally:(BOOL)locally;

// add (or subtract) number of days
- (NSDate *)rz_dateByAddingDays:(NSInteger)days;

// YES if date represents the same day.
// Uses GMT date boundary by default
- (BOOL)rz_isSameDayAsDate:(NSDate *)date;

// If locally is NO, will use GMT date boundary, otherwise uses local time zone
- (BOOL)rz_isSameDayAsDate:(NSDate *)date locally:(BOOL)locally;

// Returns days of difference from other date
- (NSInteger)rz_dayOffsetFromDate:(NSDate *)date;

// Yes if date is inbetween the start and end date but not equal to
- (BOOL)rz_isDateInRangeStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

// Yes if date is inbetween or equal to either the start or the end date.
- (BOOL)rz_isDateInRangeOrEqualToStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

@end

//! RZDateRange is a utility class to represent a continuous range of dates
/*!
    No range checking is performed - if start date precedes end date, behavior is undefined.
 */
@interface RZDateRange : NSObject <NSCopying>

typedef NS_ENUM(NSUInteger, RZDateRangeInclusivity)
{
    kRZDateRangeIncludeStartEnd = 0,
    kRZDateRangeExcludeStart,
    kRZDateRangeExcludeEnd,
    kRZDateRangeExcludeStartEnd
};

+ (instancetype)dateRangeWithStartDate:(NSDate*)startDate endDate:(NSDate *)endDate;

@property (nonatomic, copy) NSDate *startDate;
@property (nonatomic, copy) NSDate *endDate;

// Defaults to kRZDateRangeIncludeStartEnd
- (BOOL)includesDate:(NSDate *)date;
- (BOOL)includesDate:(NSDate *)date withInclusivity:(RZDateRangeInclusivity)inclusivity;

- (BOOL)isEqualToRange:(RZDateRange *)range;

@end
