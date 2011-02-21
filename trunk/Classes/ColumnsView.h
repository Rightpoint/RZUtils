//
//  ColumnsView.h
//  coreTextEx
//
//  Created by Craig Spitzkoff on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ColumnsView : UIView 
{
	NSMutableAttributedString* _text; 
	
	NSUInteger _columnCount;
	
	NSUInteger _startPosition;
}

@property (nonatomic, retain) NSMutableAttributedString* text;
@property (nonatomic, assign) NSUInteger startPosition;
@property (nonatomic, assign) NSUInteger columnCount;

- (NSRange)rangeOfStringFromLocation:(NSUInteger)location;
- (void)adjustPointSize:(NSInteger)points;

@end
