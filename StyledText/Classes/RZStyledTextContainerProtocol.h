//
//  RZStyledTextContainerProtocol.h
//  RZStyledText
//
//  Created by jkaufman on 3/9/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark -
#pragma mark Enumerated types

/**
 An enumeration of text alignment modes.
 */
typedef enum RZTextAlignment {
	kRZLeftTextAlignment, /**< Position the text flush with the left edge of its container. */
	kRZCenterTextAlignment, /**< Center the text within its container */
	kRZRightTextAlignment,  /**< Position the text flush with the right edge of its container. */
	kRZJustifiedTextAlignment, /**< Keep text flush with both edges, spacing out words and characters if required. */
} RZTextAlignment;

/**
 An enumeration of text wrapping modes.
 */
typedef enum RZTextWrapMode {
	kRZTextWrapModeBehind, /**< Display text underneath exclusion frames, effectively ignoring them. */
	kRZTextWrapModeTopAndBottom, /**< Flow text above and below exclusion frames, leaving regions to the sides empty. */
	kRZTextWrapModeSquare, /**< Flow text around exclusion frames. */
} RZTextWrapMode;

#pragma mark -
#pragma mark Protocol

@protocol RZStyledTextContainerProtocol <NSObject>

#pragma mark Optional

@optional

/**
 How text is horizontally aligned within the view.
 */
@property (nonatomic, assign)	RZTextAlignment		textAlignment;

/**
 The mode used to flow text around obstalces andboundaries.
 */
@property (nonatomic, assign)	RZTextWrapMode		textWrapMode;

#pragma mark Required

/**
 The attributed string to be displayed.
 */
@required
@property (nonatomic, retain)	NSAttributedString	*string;

/**
 The insets within which the the attributed string is rendered.
 */
@property (nonatomic, assign)	UIEdgeInsets		insets;


@property (nonatomic, assign)	NSInteger			location;

/**
 The range of the substring that fits within the shape defined by the exclusion frames and view frame.
 */
@property (readonly)			NSRange				displayRange;

/**
 The minimum bounding box that completely contains the rendered text.
 */
@property (readonly)			CGRect				displayFrame;


@end
