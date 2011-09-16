//
//  RZXMLParser.h
//  RZUtils
//
//  Created by Robert Sesek on 2/25/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <RZXMLNode.h>

// This subclass of NSXMLParser creates a DOM tree from an XML document. After
// calling |-parse|, you can access the root of the tree through the |root|
// property.
@interface RZXMLParser : NSXMLParser <NSXMLParserDelegate>
{
	RZXMLNode* _root;
	
	RZXMLNode* _currentNode;
	NSMutableString* _currentValue;
}

@property (readonly) RZXMLNode* root;

@end
