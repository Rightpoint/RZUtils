//
//  NSDate+RZExtensions.h
//
//  Created by Nicholas Bonatsakis on 7/3/13.
//  Copyright (c) 2013 RaizLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (RZExtensions)

// Normalize this NSDate to the start of the day (00:00:00)
- (NSDate *)rz_dateByRemovingTime;

// add (or subtract) number of days
- (NSDate *)rz_dateByAddingDays:(NSInteger)days;

// YES if date represents the same day
- (BOOL)rz_isSameDayAsDate:(NSDate*)date;

@end
