//
//  RZGridIndexPath.h
//  RZGridView
//
//  Created by Joe Goullaud on 10/3/11.
//  Copyright 2011 Angry Fish Studios. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RZGridIndexPath : NSObject {
    
}

+ (RZGridIndexPath*)indexPathForColumn:(NSInteger)column andRow:(NSInteger)row inSection:(NSInteger)section;

@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger column;

- (id)initWithColumn:(NSInteger)column andRow:(NSInteger)row inSection:(NSInteger)section;

@end
