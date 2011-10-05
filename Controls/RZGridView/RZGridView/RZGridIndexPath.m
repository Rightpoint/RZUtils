//
//  RZGridIndexPath.m
//  RZGridView
//
//  Created by Joe Goullaud on 10/3/11.
//  Copyright 2011 Angry Fish Studios. All rights reserved.
//

#import "RZGridIndexPath.h"


@implementation RZGridIndexPath

@synthesize section = _section;
@synthesize row = _row;
@synthesize column = _column;

- (id)initWithColumn:(NSInteger)column andRow:(NSInteger)row inSection:(NSInteger)section
{
    if ((self = [super init]))
    {
        self.column = column;
        self.row = row;
        self.section = section;
    }
    
    return self;
}

+ (RZGridIndexPath*)indexPathForColumn:(NSInteger)column andRow:(NSInteger)row inSection:(NSInteger)section
{
    return [[[RZGridIndexPath alloc] initWithColumn:column andRow:row inSection:section] autorelease];
}

@end
