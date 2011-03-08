//
//  RZStyledTextView.h
//
//  Created by jkaufman on 2/25/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

typedef enum RZTextAlignment {
	kRZLeftTextAlignment,
	kRZCenterTextAlignment,
	kRZRightTextAlignment,
	kRZJustifiedTextAlignment,
} RZTextAlignment;

/**
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
	 How text is horizontally aligned within the view.
	 */
	RZTextAlignment _textAlignment;
	
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

@property (nonatomic, retain)	NSAttributedString	*string;
@property (nonatomic, assign)	UIEdgeInsets		insets;
@property (nonatomic, assign)	RZTextAlignment		textAlignment;
@property (readonly)			CTFrameRef			textFrame;
@property (readonly)			NSRange				displayRange;
@property (readonly)			CGRect				displayFrame;

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
