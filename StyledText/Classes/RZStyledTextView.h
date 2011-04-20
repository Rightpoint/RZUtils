//
//  RZStyledTextView.h
//
//  Created by jkaufman on 2/25/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "RZStyledTextContainer.h"

/**
 @class RZStyledTextView
 @abstract An RZStyledTextView object displays a range of an NSAttributedString.
 @discussion An RZStyledTextView object displays a range of an NSAttributedString, with support for layout settings
 and runtime soft-hyphenation.
 */
@interface RZStyledTextView : RZStyledTextContainer {
	
	/**
	 How text is horizontally aligned within the view.
	 */
	RZTextAlignment _textAlignment;
	
	/**
	 The configued CoreText frame used to perform text layout calculations.
	 */
	CTFrameRef _textFrame;
    
}

#pragma mark RZStyledTextContainerProtocol

// Optional
@property (nonatomic, assign)	RZTextAlignment		textAlignment;

#pragma mark RZStyledTextView
@property (readonly)			CTFrameRef			textFrame;

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
 