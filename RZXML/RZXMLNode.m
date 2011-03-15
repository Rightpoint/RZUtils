//
//  RZXMLNode.m
//  RZUtils
//
//  Created by Robert Sesek on 2/25/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import "RZXMLNode.h"

#import "RZXMLInternal.h"
#import "RZXMLAttribute.h"

@implementation RZXMLNode

@synthesize parent = _parent;
@synthesize name = _name;
@synthesize value = _value;
@synthesize attributes = _attributes;
@synthesize children = _children;

+ (RZXMLNode*)nodeWithName:(NSString*)elementName
					 value:(NSString*)elementValue
					parent:(RZXMLNode*)elementParent
				  children:(NSArray*)elementChildren
				attributes:(NSDictionary*)elementAttributes {
	
	RZXMLNode* node = [RZXMLNode new];
	node.name = elementName;	
	node.parent = elementParent;
	[[node mutableChildren] addObjectsFromArray:elementChildren];
	NSMutableDictionary* nodeAttributes = [NSMutableDictionary dictionaryWithCapacity:[elementAttributes count]];
	for (NSString* key in elementAttributes) {
		RZXMLAttribute* attr = [RZXMLAttribute new];
		attr.name  = key;
		attr.value = [elementAttributes objectForKey:key];
		[nodeAttributes setObject:attr forKey:key];
		[attr release];
	}
	node.attributes = nodeAttributes;
	return [node autorelease];
}

- (id)init
{
	if (self = [super init])
	{
		_children = [NSMutableArray new];
	}
	return self;
}

- (void)dealloc
{
	[_name release];
	[_value release];
	[_children release];
	[super dealloc];
}

- (NSMutableArray*)mutableChildren
{
	return _children;
}

- (RZXMLNode*)childNamed:(NSString*)name
{
	for (RZXMLNode* child in _children)
		if ([child.name isEqualToString:name])
			return child;
	return nil;
}

@end
