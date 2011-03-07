//
//  NSAttributedString+RZStyledText.m
//
//  Created by jkaufman on 3/2/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "NSAttributedString+RZStyledText.h"


@implementation NSAttributedString (RZStyledText)

- (NSAttributedString *)attributedStringWithVisibleHyphen {
	// If the last character is a non-printing soft hyphen, it is replaced with a hyphen-minus for display.
	// Technique adapted from Frank Zheng, detailed at: http://frankzblog.appspot.com/?p=7001
	static const unichar softHypen = 0x00AD;
	unichar lastChar = [self.string characterAtIndex:self.string.length-1];
	if(softHypen == lastChar) {
		NSMutableAttributedString* lineAttrString = [self mutableCopy];
		NSRange replaceRange = NSMakeRange(self.string.length-1, 1);
		[lineAttrString replaceCharactersInRange:replaceRange withString:@"-"];
		return [[lineAttrString copy] autorelease];
	} else {
		return self;
	}
}


- (NSAttributedString *)attributedStringWithPointSizeAdjustment:(NSInteger)points {
	NSMutableAttributedString *tmpString = [[self mutableCopy] autorelease];
	[tmpString enumerateAttribute:(NSString *)kCTFontAttributeName
						  inRange:NSMakeRange(0, [tmpString length])
						  options:0
					   usingBlock:^(id value, NSRange range, BOOL *stop) {
						   CTFontRef font = (CTFontRef)CFAttributedStringGetAttribute((CFAttributedStringRef)tmpString, 
																					  range.location,
																					  kCTFontAttributeName, 
																					  NULL);
						   if (font) {
							   CTFontRef modifiedFont = 
								CTFontCreateCopyWithAttributes(font,
															   CTFontGetSize((CTFontRef)font) + points, 
															   NULL, 
															   NULL);
							   [tmpString addAttribute:(id)kCTFontAttributeName value:(id)modifiedFont range:range];
							   CFRelease(modifiedFont);
						   }
					   }];
	return [[tmpString copy] autorelease];
}

@end
