//
//  RZStyledTextContainer.h
//
//  Created by jkaufman on 3/9/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZStyledTextContainerProtocol.h"

/**
 @class RZStyledTextCotainer
 @abstract An RZStyledTextContainer object is a minimal implementation of the RZStyledTextContainer protocol.
 @discussion An RZStyledTextContainer object is a minimal implementation of the RZStyledTextContainer protocol.
 Subclasses must implement layout, rendering, etc.
 */
@interface RZStyledTextContainer : UIView <RZStyledTextContainerProtocol> {
	/**
	 The attributed string to be displayed.
	 */
	NSAttributedString *_string;
	
	/**
	 The insets within which the the attributed string is rendered.
	 */
	UIEdgeInsets _insets;
	
	/**
	 The starting index of the substring to be displayed.
	 */
	NSInteger _location;
	
	
	/**
	 The range of the substring that fits within the shape defined by the exclusion frames and view frame.
	 */
	NSRange _displayRange;
	
	/**
	 The minimum bounding box that completely contains the rendered text.
	 */
	CGRect _displayFrame;
	
    /**
     Whether or not to hyphenate the text
     */
    BOOL _hyphenate;
    
}


#pragma mark RZStyledTextContainerProtocol

// Required
@property (nonatomic, retain)	NSAttributedString	*string;
@property (nonatomic, assign)	NSInteger			location;
@property (nonatomic, assign)	UIEdgeInsets		insets;
@property (readonly)			NSRange				displayRange;
@property (readonly)			CGRect				displayFrame;
@property (nonatomic, assign)   BOOL                hyphenate;

@end
