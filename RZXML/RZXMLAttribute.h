//
//  RZXMLAttribute.h
//  RZUtils
//
//  Created by Robert Sesek on 4/30/10.
//  Copyright 2010 Blue Static. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <RZUtils/RZXMLNode.h>

// An Attribute is attached to a tag. It does not respond to the |attributes|
// or |children| properties.
@interface RZXMLAttribute : RZXMLNode
{
}

- (NSString*)stringValue;
- (NSInteger)intValue;
- (BOOL)boolValue;
- (float)floatValue;
- (double)doubleValue;

@end
