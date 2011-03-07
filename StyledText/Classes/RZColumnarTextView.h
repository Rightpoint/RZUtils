//
//  RZColumnarTextView.h
//
//  Created by jkaufman on 3/7/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RZColumnarTextView : UIView {
	/**
	 The attributed string to be displayed.
	 */
	NSAttributedString *_string;
	
	/**
	 The number of columns to be displayed.
	 */
	NSInteger _columnCount;
	
	/**
	 The frame insets within which the the columns are laid out.
	 */
	UIEdgeInsets _insets;
	
	/**
	 The starting index of the substring to be displayed.
	 */
	NSInteger _location;
	
	/**
	 A collection of rectangles in which no text should be drawn.
	 */
	NSSet *_exclusionFrames;
	
	/**
	 The range of the substring that fits within the shape defined by the computed columns, exclusion frames, and view.
	 */
	NSRange _displayRange;
	
	/**
	 The minimum bounding box that completely contains the rendered text.
	 */
	CGRect _displayRect;
	
}

@property (nonatomic, retain)	NSAttributedString	*string;
@property (nonatomic, assign)	NSInteger			columnCount;
@property (nonatomic, retain)	NSSet				*exclusionFrames;
@property (readonly)			NSRange				displayRange;
@property (readonly)			CGRect				displayRect;


- (id)initWithFrame:(CGRect)aFrame
		columnCount:(NSInteger)aCount
			 string:(NSAttributedString *)aString
		   location:(NSInteger)aLocation
		 edgeInsets:(UIEdgeInsets)someInsets
	exclusionFrames:(NSSet *)someExclusionFrames;

@end
