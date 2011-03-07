//
//  RZColumnarTextView.m
//
//  Created by jkaufman on 3/7/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "RZColumnarTextView.h"


@implementation RZColumnarTextView

@synthesize string = _string;
@synthesize columnCount = _columnCount;
@synthesize exclusionFrames = _exclusionFrames;
@synthesize displayRange = _displayRange;
@synthesize displayRect = _displayRect;

- (id)initWithFrame:(CGRect)aFrame
		columnCount:(NSInteger)aCount
			 string:(NSAttributedString *)aString
		   location:(NSInteger)aLocation
		 edgeInsets:(UIEdgeInsets)someInsets
	exclusionFrames:(NSSet *)someExclusionFrames {
	
	if ((self = [super initWithFrame:aFrame])) {
		_columnCount = aCount;
		_string = [aString retain];
		_location = aLocation;
		_insets = someInsets;
		_exclusionFrames = [someExclusionFrames retain];
	}
	return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)loadView {
	
}

@end
