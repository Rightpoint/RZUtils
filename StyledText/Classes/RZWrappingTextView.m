//
//  RZTextLayout.m
//
//  Created by jkaufman on 2/28/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "RZWrappingTextView.h"
#import <CoreText/CoreText.h>
#import "NSAttributedString+RZStyledText.h"
#import "Macros.h"

@implementation RZWrappingTextView

CGFloat const kDefaultLeading = 0.5;

@synthesize string = _string;
@synthesize exclusionFrames = _exclusionFrames;
@synthesize displayRange = _displayRange;
@synthesize displayRect = _displayRect;

- (id)initWithFrame:(CGRect)aFrame
			 string:(NSAttributedString *)aString
		   location:(NSInteger)aLocation 
		 edgeInsets:(UIEdgeInsets)someInsets
	exclusionFrames:(NSSet *)someExclusionFrames {

	if (self = [super initWithFrame:aFrame]) {
		_string = [aString retain];
		_location = aLocation;
		_insets = someInsets;
		_exclusionFrames = [someExclusionFrames retain];
	}
	
	return self;
}

- (void)dealloc {
	[_string release];
	[_exclusionFrames release];
	
	[super dealloc];
}

// As a first step, we simply fill rect with text, breaking at suggested points.
- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Draw a white background.
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextFillRect(context, self.bounds);
	
    // Initialize the text matrix to a known value.
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	
	// Set the usual "flipped" Core Text draw matrix
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGRect drawableRect = UIEdgeInsetsInsetRect(self.bounds, _insets);

	/*
		Sweep rect, drawing one line at a time, checking for obstacles. If one encountered,
		call CTLineGetStringIndexForPosition, create a substring, and then find a suggested breaking
		point. Grab the new substring, replace any dangling soft-hyphens with a visible hyphen-minu
		and display, taking note the line's UIFont's lineHeight. and continue horizontally until a 
		boundary encountered, at which time the text position should be bumped down by the measured
		height
	 
		NOTE: Current implementation ignores exclusion zones.
	 */

	// Create a typesetter using the complete attributed string.
 	CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((CFAttributedStringRef)self.string);

	// Create a line containing the entire string.
	CTLineRef currentLine = CTTypesetterCreateLine(typesetter, CFRangeMake(0, self.string.length));

	CGPoint currentAnchor = CGPointMake(0, drawableRect.size.height - drawableRect.origin.y);
	CFIndex currentStart = 0;
	BOOL charactersRemain = YES;
	while (charactersRemain){
		
		// Check if rendered line would exceed bounds.	
		CGRect renderedBounds = CTLineGetImageBounds(currentLine, context);

		if (renderedBounds.size.width > rect.size.width) {
			
			
			
			// Find character count of largest gramatically intact substring that fits within the given width.
			CFIndex count = CTTypesetterSuggestLineBreak(typesetter, currentStart, drawableRect.size.width);
			
			// The substring that can be displayed in the available horizontal space.
			NSAttributedString *substring = [[self.string attributedSubstringFromRange:NSMakeRange(currentStart, count)] attributedStringWithVisibleHyphen];
			
			CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)substring);
			CGRect lineRect = CTLineGetImageBounds(line, context);
			CGContextSetTextPosition(context, currentAnchor.x, currentAnchor.y - lineRect.size.height);
			CTLineDraw(line, context);

			// Update text location. Note that we could be rendering with irregular leading / line spacing. TODO: don't
			currentAnchor.x = 0; // Sweeping down and right without regard for obstacles, right now.
			currentAnchor.y -= lineRect.size.height + (kDefaultLeading * lineRect.size.height);

			// Update the substring range
			currentStart += count;
			charactersRemain = (currentStart <= self.string.length - 1);
		}

	}	
}

@end
