//
//  RZStyledTextView.h
//  coreTextEx
//
//  Created by jkaufman on 2/25/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RZStyledTextView : UIView {
	NSAttributedString	*_string;
	UIEdgeInsets		_insets;
	NSInteger			_location;
	NSRange				_displayRange;
}

@property (readonly)	NSAttributedString	*string;
@property (readonly)	UIEdgeInsets		insets;
@property (readonly)	NSRange				displayRange;

- (id)initWithFrame:(CGRect)frame
			 string:(NSAttributedString *)aString
		   location:(NSInteger)aLocation 
		 edgeInsets:(UIEdgeInsets)someInsets;

@end
