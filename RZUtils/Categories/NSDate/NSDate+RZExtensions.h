//
//  NSDate+RZExtensions.h
//
//  Created by Nicholas Bonatsakis on 7/3/13.
//  Copyright (c) 2013 RaizLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (RZExtensions)

// Create a new date for today that is the start of the day (00:00:00)
+ (NSDate *)rz_dateWithoutTime;

// Normalize this NSDate to the start of the day (00:00:00)
- (NSDate *)rz_dateByRemovingTime;

// add (or subtract) number of days
- (NSDate *)rz_dateByAddingDays:(NSInteger)days;

// YES if date represents the same day
- (BOOL)rz_isSameDayAsDate:(NSDate *)date;

// Returns days of difference from other date
- (NSInteger)rz_dayOffsetFromDate:(NSDate *)date;

// Yes if date is inbetween the start and end date but not equal to
- (BOOL)rz_isDateInRangeStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

// Yes if date is inbetween or equal to either the start or the end date.
- (BOOL)rz_isDateInRangeOrEqualToStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

@end
