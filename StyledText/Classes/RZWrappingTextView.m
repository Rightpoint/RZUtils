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

	// Create a typesetter using the complete attributed string.
 	CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((CFAttributedStringRef)self.string);


	CGPoint currentAnchor = CGPointMake(0, drawableRect.size.height - drawableRect.origin.y);
	CFIndex currentStart = 0;
	while (1) {
		// Bail if entire string was drawn.
		NSInteger remainingChars = self.string.length - currentStart;
		if (remainingChars <= 0)
			break;

		NSAttributedString *substring = [self.string attributedSubstringFromRange:NSMakeRange(currentStart, remainingChars)];	
		CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)substring);
		
		// Get metrics for line.
		CGFloat ascent, descent, leading;
		CGFloat width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
		CGFloat height = ascent + descent;		

		// Find collision.
		CGRect lineRect = CGRectMake(currentAnchor.x, currentAnchor.y, width, height);
		CGFloat hCollision = CGRectGetMaxX(drawableRect);
		CGRect obstacle;
		for(NSDictionary *frameRep in _exclusionFrames) {
			CGRect eFrame;
			if(!CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)frameRep, &eFrame))
				continue;
			
			// Obstacle blocks horizontal segment.
			if (CGRectIntersectsRect(lineRect, eFrame)) {
				CGFloat edge = CGRectGetMinX(eFrame);
				CGContextSaveGState(context);
				CGContextSetFillColorWithColor(context, [[UIColor greenColor] CGColor]);
				CGContextSetBlendMode(context, kCGBlendModeMultiply);
				CGContextFillRect(context, eFrame);
				CGContextRestoreGState(context);
				CGContextSaveGState(context);
				CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
				CGContextSetBlendMode(context, kCGBlendModeScreen);
				CGContextFillRect(context, eFrame);
				CGContextRestoreGState(context);
				if (edge < hCollision) {
					hCollision = edge;
					obstacle = eFrame;
					break;
				}
			}
		}
		
		// Find character count of largest gramatically intact substring that fits within the given width.
		NSInteger countThatFits = CTTypesetterSuggestLineBreak(typesetter, currentStart, hCollision);
		
		// The substring that can be displayed in the available horizontal space.
		substring = [[self.string attributedSubstringFromRange:NSMakeRange(currentStart, countThatFits)] attributedStringWithVisibleHyphen];	
		CTLineRef formattedLine = CTLineCreateWithAttributedString((CFAttributedStringRef)substring);
		
		CGContextSetTextPosition(context, currentAnchor.x, currentAnchor.y - height - leading);
		CTLineDraw(formattedLine, context);

		// Update anchors for next text segment.
		if (!CGRectIsNull(obstacle)) {
			// Obstacle encountered, so slide text frame over.
			currentAnchor.x = CGRectGetMaxX(obstacle);
			obstacle = CGRectNull;
		} else {
			// Collision was right edge; push to next line.
			currentAnchor.x = drawableRect.origin.x;
			currentAnchor.y -= (height + leading);
		}

		// Update the substring range
		currentStart += countThatFits;
	}	
}

@end
