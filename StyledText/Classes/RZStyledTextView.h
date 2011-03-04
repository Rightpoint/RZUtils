//
//  RZStyledTextView.h
//
//  Created by jkaufman on 2/25/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

/*!
 @class RZStyledTextView
 @abstract An RZStyledTextView object displays a range of an NSAttributedString.
 @discussion An RZStyledTextView object displays a range of an NSAttributedString, with support for layout settings
 and runtime soft-hyphenation.
 */
@interface RZStyledTextView : UIView {
	/**
	 The attributed string to be displayed.
	 */
	NSAttributedString	*_string;
	
	/**
	 The insets within which the the attributed string is rendered.
	 */
	UIEdgeInsets _insets;
	
	/**
	 The starting index of the substring to be displayed.
	 */
	NSInteger _location;
	
	/**
	 The calculated substring range that can be displayed without clipping.
	 */
	NSRange	_displayRange;
	
	/**
	 The configued CoreText frame used to perform text layout calculations.
	 */
	CTFrameRef _textFrame;
}

// Settable properites.
@property (nonatomic, retain)	NSAttributedString	*string;
@property (nonatomic, assign)	UIEdgeInsets		insets;

// Derived properties
@property (readonly)	CTFrameRef			textFrame;
@property (readonly)	NSRange				displayRange;
@property (readonly)	CGRect				displayFrame;

/**
 Initialize a new RZStyledTextView object
 @param aFrame The view frame.
 @param aString The attributed string to be displayed.
 @param aLocation The starting index of the substring to be displayed.
 @param someInsets The insets within which the attributed string is rendered.
 @returns A newly initialized object.
 */
- (id)initWithFrame:(CGRect)aFrame
			 string:(NSAttributedString *)aString
		   location:(NSInteger)aLocation 
		 edgeInsets:(UIEdgeInsets)someInsets;

@end
