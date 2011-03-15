//
//  RZXMLNode.h
//  RZUtils
//
//  Created by Robert Sesek on 2/25/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

// This represents a DOM node in an XML document.
@interface RZXMLNode : NSObject
{
	RZXMLNode* _parent;
	NSString* _name;
	NSString* _value;
	NSDictionary* _attributes;
	NSMutableArray* _children;
}
@property (nonatomic, readonly, assign) RZXMLNode* parent;
@property (nonatomic, readonly, copy) NSString* name;
@property (nonatomic, readonly, copy) NSString* value;

// Dictionary of <NSString => RZXMLAttribute> mapping for attributes.
@property (nonatomic, readonly, retain) NSDictionary* attributes;

// Array of RZXMLNode children.
@property (nonatomic, readonly) NSArray* children;

// Returns an autorelease instance of RZXMLNode with the given attributes.
+ (RZXMLNode*)nodeWithName:(NSString*)elementName value:(NSString*)elementValue parent:(RZXMLNode*)elementValue children:(NSArray*)elementChildren attributes:(NSDictionary*)elementAttributes;

// This will iterate over a node's children, looking for a node with the
// specified |name|. If there are more than one nodes with the same name, the
// first one it finds will be returned. If there are no matches, returns nil.
- (RZXMLNode*)childNamed:(NSString*)name;

@end
