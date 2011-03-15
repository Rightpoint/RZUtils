//
//  RZXMLAttribute.m
//  RZUtils
//
//  Created by Robert Sesek on 4/30/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import "RZXMLAttribute.h"


@implementation RZXMLAttribute

- (id)init
{
	if (self = [super init]) {
		[_children release];
		_children = nil;
	}
	return self;
}

- (NSDictionary*)attributes
{
	return nil;
}

- (void)setAttributes:(NSDictionary*)a
{
}

- (NSString*)stringValue
{
	return _value;
}

- (NSInteger)intValue
{
	return [_value intValue];
}

- (BOOL)boolValue
{
	return [_value boolValue];
}

- (float)floatValue
{
	return [_value floatValue];
}

- (double)doubleValue
{
	return [_value doubleValue];
}

@end
