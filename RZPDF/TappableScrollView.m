//
//  TappableScrollView.m
//  RZUtils
//
//  Created by Craig on 9/14/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import "TappableScrollView.h"


@implementation TappableScrollView


- (id)initWithFrame:(CGRect)frame 
{
	return [super initWithFrame:frame];
}

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event 
{	
	// If not dragging, send event to next responder
	if (!self.dragging) 
		[self.nextResponder touchesEnded: touches withEvent:event]; 
	else
		[super touchesEnded: touches withEvent: event];
}


@end
