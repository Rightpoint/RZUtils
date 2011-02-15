//
//  ColumnsView.m
//  coreTextEx
//
//  Created by Craig Spitzkoff on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ColumnsView.h"
#import <CoreText/CoreText.h>

@implementation ColumnsView
@synthesize text = _text;
@synthesize startPosition = _startPosition;
@synthesize columnCount = _columnCount;

- (id)initWithFrame:(CGRect)frame 
{    
    self = [super initWithFrame:frame];
    if (self) 
	{
		_columnCount = 2;
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) 
	{
		_columnCount = 2;
    }
    return self;	
}
- (CFArrayRef)createColumns 
{
    int column;
    CGRect* columnRects = (CGRect*)calloc(_columnCount, sizeof(*columnRects));
	
    // Start by setting the first column to cover the entire view.
    columnRects[0] = self.bounds;
    // Divide the columns equally across the frame's width.
    CGFloat columnWidth = self.bounds.size.width / _columnCount;
    for (column = 0; column < _columnCount - 1; column++) {
        CGRectDivide(columnRects[column], &columnRects[column],
                     &columnRects[column + 1], columnWidth, CGRectMinXEdge);
    }
	
    // Inset all columns by a few pixels of margin.
    for (column = 0; column < _columnCount; column++) {
        columnRects[column] = CGRectInset(columnRects[column], 10.0, 10.0);
    }
	
	// Create an array of layout paths, one for each column.
    CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault,
												   _columnCount, &kCFTypeArrayCallBacks);
    for (column = 0; column < _columnCount; column++) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, columnRects[column]);
        CFArrayInsertValueAtIndex(array, column, path);
        CFRelease(path);
    }
    free(columnRects);
    return array;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect 
{
	CGContextRef context = UIGraphicsGetCurrentContext();

	// Draw a white background.
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextFillRect(context, self.bounds);
	
    // Initialize the text matrix to a known value.
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	
	// Set the usual "flipped" Core Text draw matrix
	CGContextTranslateCTM(context, 0, ([self bounds]).size.height );
	CGContextScaleCTM(context, 1.0, -1.0);
    
	
    CTFramesetterRef framesetter =
	CTFramesetterCreateWithAttributedString((CFAttributedStringRef) self.text);
    CFArrayRef columnPaths = [self createColumns];
	
    CFIndex pathCount = CFArrayGetCount(columnPaths);
    CFIndex startIndex = _startPosition;
    int column;
    for (column = 0; column < pathCount; column++) {
        CGPathRef path = (CGPathRef)CFArrayGetValueAtIndex(columnPaths, column);
		
        // Create a frame for this column.
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
													CFRangeMake(startIndex, 0), path, NULL);
		

		// Handle display of soft hyphenation.
		// Technique adopted from Frank Zheng, detailed at: http://frankzblog.appspot.com/?p=7001
		NSArray *lines = (NSArray *)CTFrameGetLines(frame);
		CGFloat textOffset = 0;
		for (int lineNumber = 0; lineNumber < [lines count]; lineNumber++) {
			CTLineRef line = (CTLineRef)[lines objectAtIndex:lineNumber];
			CGFloat ascent, descent, leading = 0;
			double width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
			double height = ascent + descent + leading;
			textOffset += height;
			CGContextSetTextPosition(context, 0, textOffset);
			
			CFRange cfLineRange = CTLineGetStringRange(line);
			NSRange lineRange = NSMakeRange(cfLineRange.location, cfLineRange.length);
			NSString* lineString = [[_text string] substringWithRange:lineRange];
			static const unichar softHypen = 0x00AD;
			unichar lastChar = [lineString characterAtIndex:lineString.length-1];
			if(softHypen == lastChar) {
				NSMutableAttributedString* lineAttrString = [[_text attributedSubstringFromRange:lineRange] mutableCopy];
				NSRange replaceRange = NSMakeRange(lineRange.length-1, 1);
				[lineAttrString replaceCharactersInRange:replaceRange withString:@"-"];
				
				CTLineRef hyphenatedLine = CTLineCreateWithAttributedString((CFAttributedStringRef)lineAttrString);
				CTLineRef justifiedLine = CTLineCreateJustifiedLine(hyphenatedLine, 1.0, width);
				CTLineDraw(justifiedLine, context);
			} else {
				CTLineDraw(line, context);
			}
		}
		
        // Start the next frame at the first character not visible in this frame.
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        startIndex += frameRange.length;
		
        CFRelease(frame);
    }
    CFRelease(columnPaths);
	
}

-(NSRange) rangeOfStringFromLocation:(NSUInteger)location
{
	CTFramesetterRef framesetter =
	CTFramesetterCreateWithAttributedString((CFAttributedStringRef) self.text);
    CFArrayRef columnPaths = [self createColumns];
	
    CFIndex pathCount = CFArrayGetCount(columnPaths);
    CFIndex startIndex = location;
	
	NSRange range;
	range.location = location;
	
    int column;
    for (column = 0; column < pathCount; column++) {
        CGPathRef path = (CGPathRef)CFArrayGetValueAtIndex(columnPaths, column);
		
        // Create a frame for this column and draw it.
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
													CFRangeMake(startIndex, 0), path, NULL);
        
        // Start the next frame at the first character not visible in this frame.
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        startIndex += frameRange.length;
		
        CFRelease(frame);
		
		range.length = startIndex - range.location;
    }
    CFRelease(columnPaths);
	
	return range;
}

- (void)dealloc {
    [super dealloc];
}


@end
