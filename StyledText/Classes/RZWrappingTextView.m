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

#define DEBUG_BOUNDS 1

@interface RZWrappingTextView ()
- (void)perfomLayout;

@property (readwrite, nonatomic, assign) BOOL needsReflow;

@end


@implementation RZWrappingTextView

@synthesize string = _string;
@synthesize exclusionFrames = _exclusionFrames;
@synthesize textWrapMode = _textWrapMode;
@synthesize displayRange = _displayRange;
@synthesize displayRect = _displayRect;
@synthesize needsReflow = _needsReflow;

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
		_displayRect = UIEdgeInsetsInsetRect(self.bounds, _insets);
	}

	return self;
}

- (void)dealloc {
	[_string release];
	[_exclusionFrames release];
	
	[super dealloc];
}

- (void)setFrame:(CGRect)aFrame {
	// Save frame, update display rect, and perform layout.
	[super setFrame:aFrame];
	_displayRect = UIEdgeInsetsInsetRect(aFrame, _insets);
	self.needsReflow = YES; // Reflow will be performed upon display.
	[self setNeedsDisplay];
}

- (void)setString:(NSAttributedString *)aString {
	[_string release];
	_string = [aString retain];
	self.needsReflow = YES;
}

- (void)setExclusionFrames:(NSSet *)someExclusionFrames {
	[_exclusionFrames release];
	_exclusionFrames = [someExclusionFrames retain];
	self.needsReflow = YES;
}

- (void)setTextWrapMode:(RZTextWrapMode)aWrappingMode {
	_textWrapMode = aWrappingMode;
	self.needsReflow = YES;
}

- (NSRange)displayRange {
	if (_needsReflow)
		[self perfomLayout];
	return _displayRange;
}

// setNeedsReflow and computeLayout represent a chack, but will be left unless Instruments reveals a problem.
- (void)setNeedsReflow:(BOOL)shouldReflow {
	_needsReflow = shouldReflow;
}

- (void)perfomLayout {
	[self drawRect:CGRectZero];
}

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

	// Create a typesetter using the complete attributed string.
 	CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((CFAttributedStringRef)self.string);

	CGPoint currentAnchor = CGPointMake(0, _displayRect.size.height - _displayRect.origin.y);
	CFIndex currentStart = 0;
	while (1) {
		// Bail if entire string was drawn.
		NSInteger remainingChars = self.string.length - currentStart;
		if (remainingChars <= 0)
			break;

		NSAttributedString *substring = [self.string attributedSubstringFromRange:
										 NSMakeRange(currentStart, remainingChars)];	
		CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)substring);
		
		// Get metrics for line.
		CGFloat ascent, descent, leading;
		CGFloat width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
		CGFloat height = ascent + descent + leading;
		CGRect lineRect = CGRectMake(currentAnchor.x,
									 currentAnchor.y - height - descent, // Descent is redundant. Remove and fix.
									 width,
									 height);
#ifdef DEBUG_BOUNDS
		CGContextSaveGState(context);
		CGContextSetStrokeColor(context, CGColorGetComponents([[UIColor greenColor] CGColor]));
		CGContextStrokeRectWithWidth(context, lineRect, 0.5);
		CGContextRestoreGState(context);
#endif
		
		// Bail if text would extend outside vertical bounds.
		if (CGRectGetMinY(lineRect) < CGRectGetMinY(_displayRect))
			break;
		
		// Find text boundaries.
		CGFloat hCollision = CGRectGetMaxX(_displayRect);
		CGRect obstacle = CGRectNull;

		// If wrapping is set to "behind," obstacles are ignored.
		if (self.textWrapMode != kRZTextWrapModeBehind) {
			// Find collisions.
			for(NSDictionary *frameRep in _exclusionFrames) {
				CGRect eFrame;
				if(!CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)frameRep, &eFrame))
					continue;

#ifdef DEBUG_BOUNDS
				CGContextSaveGState(context);
				CGContextSetStrokeColor(context, CGColorGetComponents([[UIColor redColor] CGColor]));
				CGContextStrokeRectWithWidth(context, eFrame, 2);
				CGContextSetFillColor(context, CGColorGetComponents([[UIColor whiteColor] CGColor]));
				CGContextFillRect(context, eFrame);
				CGContextRestoreGState(context);
#endif
				
				// Candidate obstacle does block horizontal segment.
				if (CGRectIntersectsRect(lineRect, eFrame)) {
					CGFloat edge = CGRectGetMinX(eFrame);

					// Obstacle is the closest text boundary encountered so far.
					if (edge < hCollision) {
						hCollision = edge;
						obstacle = eFrame;
						break;
					}
				}
			}
		}
		
		// If wrapping mode is set to "top and bottom," we don't attempt to wrap the obstacle and instead continue our
		// drawing below it.
		if (self.textWrapMode == kRZTextWrapModeTopAndBottom && !CGRectIsNull(obstacle)) {
			currentAnchor.y = CGRectGetMinY(obstacle);
			currentAnchor.x = _displayRect.origin.x;
			continue; // Bail on laying out the line.
		}
		
		// Find character count of largest gramatically intact substring that fits within the given width.
		NSInteger countThatFits = CTTypesetterSuggestLineBreakWithOffset(typesetter, 
																		 currentStart,
																		 hCollision - currentAnchor.x,
																		 0);
	
		NSInteger wordBoundary = [substring.string rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location;
		NSInteger wordLength = wordBoundary == NSNotFound ? 0 : [[substring.string substringToIndex:wordBoundary] length];
		
		// If the suggested substring includes at least the entire next word, render the text.
		if (wordLength < countThatFits) {
			
			// The substring that can be displayed in the available horizontal space.
			substring = [[self.string attributedSubstringFromRange:NSMakeRange(currentStart, countThatFits)]
						 attributedStringWithVisibleHyphen];
	
			// Draw the substring.
			CTLineRef formattedLine = CTLineCreateWithAttributedString((CFAttributedStringRef)substring);
			CGContextSetTextPosition(context, currentAnchor.x, currentAnchor.y - height);
			CTLineDraw(formattedLine, context);

			// Update the substring range.
			currentStart += countThatFits;
			_displayRange = NSMakeRange(_location, currentStart - _location);
		}
		
		// Update anchors for next text segment.
		if (!CGRectIsNull(obstacle)) {
			// Obstacle encountered, so slide text frame over.
			currentAnchor.x = CGRectGetMaxX(obstacle);
			obstacle = CGRectNull; // Analyzer flags this correctly, but it's not a problem.
		} else {
			// Collision was right edge; push to next line.
			currentAnchor.x = _displayRect.origin.x;
			currentAnchor.y -= height;
		}

		// Flag that layout was completed.
		self.needsReflow = NO;
	}	
}

@end
