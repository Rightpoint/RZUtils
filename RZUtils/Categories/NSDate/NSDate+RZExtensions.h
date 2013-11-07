//
//  NSDate+RZExtensions.h
//
//  Created by Nicholas Bonatsakis on 7/3/13.
//  Copyright (c) 2013 RaizLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (RZExtensions)

// Start of current day without time (midnight)
// By default uses GMT midnight
+ (NSDate *)rz_currentDayNoTime;

// If locally is YES, will use local time zone midnight
+ (NSDate *)rz_currentDayNoTimeLocally:(BOOL)locally;

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

@end
