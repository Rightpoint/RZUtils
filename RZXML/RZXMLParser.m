//
//  RZXMLParser.m
//  RZUtils
//
//  Created by Robert Sesek on 2/25/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import "RZXMLParser.h"

#import "RZXMLAttribute.h"
#import "RZXMLInternal.h"
#import "RZXMLNode.h"

@implementation RZXMLParser

@synthesize root = _root;

- (id)initWithContentsOfURL:(NSURL*)url
{
	if (self = [super initWithContentsOfURL:url])
	{
		self.delegate = self;
	}
	return self;
}

- (id)initWithData:(NSData*)data
{
	if (self = [super initWithData:data])
	{
		self.delegate = self;
	}
	return self;
}

- (void)dealloc
{
	[_root release];
	[_currentValue release];
	
	[super dealloc];
}

#pragma mark NSXMLParserDelegate

- (void) parser:(NSXMLParser*)parser
didStartElement:(NSString*)elementName
   namespaceURI:(NSString*)namespaceURI
  qualifiedName:(NSString*)qName
	 attributes:(NSDictionary*)attributeDict
{	
	RZXMLNode* node =  [[RZXMLNode nodeWithName:elementName 
										 value:nil 
										parent:nil 
									  children:nil 
									attributes:attributeDict] retain];	
	// If there is no current node, we found the root.
	if (!_currentNode)
	{
		_root = node;
		_currentNode = _root;
	}
	else 
	{
		node.parent = _currentNode;
		[[_currentNode mutableChildren] addObject:node];
		_currentNode = node;
		[node release];  // Parent takes ownership.
 	}
}

- (void)parser:(NSXMLParser*)parser
 didEndElement:(NSString*)elementName
  namespaceURI:(NSString*)namespaceURI
 qualifiedName:(NSString*)qName
{
	if (_currentValue)
	{
		NSString* trimmedString = [_currentValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		_currentNode.value = trimmedString;
		[_currentValue release];
		_currentValue = nil;
	}
		
	if (_currentNode.parent)
		_currentNode = _currentNode.parent;
}


- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string
{
	if (!_currentValue)
		_currentValue = [[NSMutableString alloc] initWithString:string];
	else
		[_currentValue appendString:string];
}

@end
