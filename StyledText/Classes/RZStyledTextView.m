//
//  RZStyledTextView.m
//  coreTextEx
//
//  Created by jkaufman on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RZStyledTextView.h"
#import <CoreText/CoreText.h>


@implementation RZStyledTextView

@synthesize string			= _string;
@synthesize insets			= _insets;
@synthesize displayRange	= _displayRange;

- (id)initWithFrame:(CGRect)aFrame string:(NSAttributedString *)aString location:(NSInteger)aLocation {
	if ((self = [super initWithFrame:aFrame])) {
		_string = [aString retain];
		_location = aLocation;
	}
	return self;
}

// The view's frame is immutable once initialized to prevent truncation, clipping, and other undesired behaviors.
- (void)setFrame:(CGRect)rect {
	// noop
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Draw a white background.
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextFillRect(context, self.bounds);
	
    // Initialize the text matrix to a known value.
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	
	// Set the usual "flipped" Core Text draw matrix
	CGContextTranslateCTM(context, 0, ([self bounds]).size.height );
	CGContextScaleCTM(context, 1.0, -1.0);

	// Create a path of the drawable area.
	CGRect drawableArea = UIEdgeInsetsInsetRect(rect, _insets);
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, drawableArea);

	// Prepare frame.
	NSInteger lengthRemaining = [self.string length] - _location;
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.string);
	CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(_location, lengthRemaining), path, NULL);
	CGPathRelease(path);
	
	// Iterate over lines, processing each before rendering.
	NSArray *lines = (NSArray *)CTFrameGetLines(textFrame);
	CGPoint* origins  = (CGPoint*)calloc([lines count], sizeof(CGPointZero));
	CTFrameGetLineOrigins(textFrame, CFRangeMake(0, [lines count]), origins);

	for (int lineNumber = 0; lineNumber < [lines count]; lineNumber++) {
		CTLineRef line = (CTLineRef)[lines objectAtIndex:lineNumber];
		CGContextSetTextPosition(context, drawableArea.origin.x + origins[lineNumber].x, origins[lineNumber].y);
		
		CFRange cfLineRange = CTLineGetStringRange(line);
		NSRange lineRange = NSMakeRange(cfLineRange.location, cfLineRange.length);
		NSString* lineString = [[self.string string] substringWithRange:lineRange];
		static const unichar softHypen = 0x00AD;
	
		//   If the last character is a non-printing soft hyphen, it is replaced with a hyphen-minus for display.
		// Technique adapted from Frank Zheng, detailed at: http://frankzblog.appspot.com/?p=7001
		unichar lastChar = [lineString characterAtIndex:lineString.length-1];
		if(softHypen == lastChar) {
			NSMutableAttributedString* lineAttrString = [[self.string attributedSubstringFromRange:lineRange] mutableCopy];
			NSRange replaceRange = NSMakeRange(lineRange.length-1, 1);
			[lineAttrString replaceCharactersInRange:replaceRange withString:@"-"];
			CTLineRef hyphenatedLine = CTLineCreateWithAttributedString((CFAttributedStringRef)lineAttrString);
			CTLineRef justifiedLine = CTLineCreateJustifiedLine(hyphenatedLine, 1.0, drawableArea.size.width);
			CTLineDraw(justifiedLine, context);
			
			[lineAttrString release];
		} else {
			CTLineDraw(line, context);
		}
	}
	free(origins);

	// Determine the range   the next frame at the first character not visible in this frame.
	NSInteger displayLength = CTFrameGetVisibleStringRange(textFrame).length;
	_displayRange = NSMakeRange(_location, displayLength);

	CFRelease(textFrame);
}

@end