//
//  RZTextLayout.h
//
//  Created by jkaufman on 2/28/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RZStyledTextContainer.h"

/**
 @class RZWrappingTextView
 @abstract An RZWrappingTextView object displays a range of an NSAttributedString within an irregular shape,
 breaking and wrapping text to fit the geometry.
 @discussion An RZStyledTextView object displays a range of an NSAttributedString, with support for layout settings
 and runtime hyphenation.
 */
@interface RZWrappingTextView : RZStyledTextContainer {
	/**
	 A collection of rectangles in which no text should be drawn.
	 */
	NSSet *_exclusionFrames;
	
	/**
	 The mode used to flow text around obstalces andboundaries.
	 */
	RZTextWrapMode _textWrapMode;
	
	/**
	 Dirty bit used to indicate that attributes have changed, but that re-layout has not completed.
	 */
	BOOL _needsReflow;
}

#pragma mark RZStyledTextContainerProtocol

// Optional
@property (nonatomic, assign)			RZTextWrapMode		textWrapMode;

#pragma mark RZWrappingTextView

@property (nonatomic, retain)			NSSet				*exclusionFrames;
@property (readonly, nonatomic, assign)	BOOL				needsReflow;

/**
 Initialize a new RZWrappingTextView object
 @param aFrame The view frame.
 @param aString The attributed string to be displayed.
 @param aLocation The starting index of the substring to be displayed.
 @param someInsets The insets within which the attributed string is rendered.
 @param someExclusionFrames A collection of rectangles in which no text should be drawn.  Expects CGRect objects using
 CGRectCreateDictionaryRepresentation
 @returns A newly initialized object.
 */
- (id)initWithFrame:(CGRect)aFrame
			 string:(NSAttributedString *)aString
		   location:(NSInteger)aLocation 
		 edgeInsets:(UIEdgeInsets)someInsets
	exclusionFrames:(NSSet *)someExclusionFrames;

@end