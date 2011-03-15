//
//  RZXMLInternal.h
//  RZUtils
//
//  Created by Robert Sesek on 2/25/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

/******************************************************************************\
 * !! WARNING !!
 * This is a PRIVATE header and is not to be used outside of RZUtils RZXML
 * implementations. Kittens will die if you violate this rule.
\******************************************************************************/

#import "RZXMLNode.h"

@interface RZXMLNode ()
@property (nonatomic, assign) RZXMLNode* parent;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* value;
@property (nonatomic, retain) NSDictionary* attributes;
- (NSMutableArray*)mutableChildren;
@end
