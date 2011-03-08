//
//  RZStyledTextView.m
//
//  Created by jkaufman on 2/25/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "RZStyledTextView.h"
#import <CoreText/CoreText.h>

@interface RZStyledTextView ()

/**
 Force RZStyledTextView object to recalculate its contents and layout the next time they are queried.
 */
- (void)setNeedsReflow;

@end


@implementation RZStyledTextView

@synthesize string			= _string;
@synthesize insets			= _insets;
@synthesize textAlignment	= _textAlignment;
@synthesize displayRange	= _displayRange;
@synthesize textFrame		= _textFrame;

#pragma mark -
#pragma mark Lifecylce

- (id)initWithFrame:(CGRect)aFrame string:(NSAttributedString *)aString location:(NSInteger)aLocation edgeInsets:(UIEdgeInsets)someInsets {
	if ((self = [super initWithFrame:aFrame])) {
		_string = [aString retain];
		_location = aLocation;
		_insets = someInsets;
	}
	return self;
}

- (void)dealloc {
	[_string release];
	if (_textFrame)
		CFRelease(_textFrame);
	[super dealloc];
}

#pragma mark -
#pragma mark Mutators

- (void)setFrame:(CGRect)aFrame {
	[super setFrame:aFrame];
	[self setNeedsReflow];
	[self setNeedsDisplay];
}

- (void)setString:(NSAttributedString *)aString {
	if (aString == self.string)
		return;

	[_string release];
	_string = [aString retain];
	[self setNeedsReflow];
	[self setNeedsDisplay];	
}

- (void)setLocation:(NSInteger)aLocation {
	if (aLocation == _location)
		return;

	_location = aLocation;
	[self setNeedsReflow];
	[self setNeedsDisplay];
}

- (void)setInsets:(UIEdgeInsets)someInsets {
	if (UIEdgeInsetsEqualToEdgeInsets(someInsets, _insets))
		return;

	_insets = someInsets;
	[self setNeedsReflow];
	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark Accessors

- (CTFrameRef)textFrame {
	if (!_textFrame) {
		// Create a path of the text area.
		CGRect textArea = self.displayFrame;
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathAddRect(path, NULL, textArea);
		
		// Prepare frame.
		NSInteger lengthRemaining = [self.string length] - _location;
		CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.string);
		_textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(_location, lengthRemaining), path, NULL);
		CGPathRelease(path);

		CFRelease(framesetter);
	}
	
	return _textFrame;
}

- (CGRect)displayFrame {
	return UIEdgeInsetsInsetRect(self.bounds, _insets);
}

- (NSRange)displayRange {
	NSInteger displayLength = CTFrameGetVisibleStringRange(self.textFrame).length;
	return NSMakeRange(_location, displayLength);
}

#pragma mark -
#pragma mark Display

- (void)setNeedsReflow {
	// Clear all cached values and objects used to determine layout.  They will be recreated on-demand.
	if (_textFrame) {
		CFRelease(_textFrame);
		_textFrame = nil;
	}
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
	
	// Iterate over lines, processing each before rendering.
	NSArray *lines = (NSArray *)CTFrameGetLines(self.textFrame);
	CGPoint* origins  = (CGPoint*)calloc([lines count], sizeof(CGPointZero));
	CTFrameGetLineOrigins(self.textFrame, CFRangeMake(0, [lines count]), origins);

	for (int lineNumber = 0; lineNumber < [lines count]; lineNumber++) {
		CTLineRef line = (CTLineRef)[lines objectAtIndex:lineNumber];
		CTLineRef formattedLine = nil;
		
		CFRange cfLineRange = CTLineGetStringRange(line);
		NSRange lineRange = NSMakeRange(cfLineRange.location, cfLineRange.length);
		NSString* lineString = [[self.string string] substringWithRange:lineRange];
		
		// If the last character is a non-printing soft hyphen, it is replaced with a hyphen-minus for display.
		// Technique adapted from Frank Zheng, detailed at: http://frankzblog.appspot.com/?p=7001
		static const unichar softHypen = 0x00AD;
		unichar lastChar = [lineString characterAtIndex:lineString.length-1];
		if(softHypen == lastChar) {
			NSMutableAttributedString* lineAttrString = [[self.string attributedSubstringFromRange:lineRange] mutableCopy];
			NSRange replaceRange = NSMakeRange(lineRange.length-1, 1);
			[lineAttrString replaceCharactersInRange:replaceRange withString:@"-"];
			CTLineRef hyphenatedLine = CTLineCreateWithAttributedString((CFAttributedStringRef)lineAttrString);			
			formattedLine = CFRetain(hyphenatedLine);
			
			// Cleanup
			[lineAttrString release];
			CFRelease(hyphenatedLine);
		} else {
			formattedLine = CFRetain(line);
		}
		
		// Align line in frame.
		CGFloat alignmentOffset = 0;
		switch (self.textAlignment) {
			case kRZLeftTextAlignment:
			case kRZCenterTextAlignment:
			case kRZRightTextAlignment: {
				alignmentOffset = CTLineGetPenOffsetForFlush(formattedLine, 
															 self.textAlignment * 0.5,
															 self.displayFrame.size.width);
				break;
			}
			case kRZJustifiedTextAlignment: {
				CTLineRef justifiedLine = CTLineCreateJustifiedLine(formattedLine,
																	1.0,							// Fully justified.
																	self.displayFrame.size.width);
				CFRelease(formattedLine);
				formattedLine = CFRetain(justifiedLine);
				CFRelease(justifiedLine);
				break;
			}
		}

		CGContextSetTextPosition(context, 
								 self.displayFrame.origin.x + origins[lineNumber].x + alignmentOffset, 
								 origins[lineNumber].y);

		CTLineDraw(formattedLine, context);
		CFRelease(formattedLine);
	}
	free(origins);
}

@end