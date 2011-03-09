//
//  RZCoverViewCell.m
//  IssueControl
//
//  Created by Joe Goullaud on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RZCoverViewCell.h"
#import "RZCoverView.h"

@implementation RZCoverViewCell

@synthesize style = _style;
@synthesize reuseIdentifier = _reuseIdentifier;
@synthesize image = _image;

- (id)initWithStyle:(RZCoverViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
	if (self = [super init]) {
		_style = style;
		self.reuseIdentifier = reuseIdentifier;
	}
	
	return self;
}

- (void)updateImage:(UIImage*)image animated:(BOOL)animated
{
	self.image = image;
	
	UIImageView* cover = [[UIImageView alloc] initWithImage:image];
	
	cover.contentMode = UIViewContentModeScaleAspectFit;
	cover.autoresizingMask = UIViewAutoresizingFlexibleWidth || UIViewAutoresizingFlexibleHeight || UIViewAutoresizingFlexibleLeftMargin || UIViewAutoresizingFlexibleRightMargin;
	
	if (RZCoverViewStyleShelf == _style || RZCoverViewStyleShelfReflected == _style)
	{
		cover.autoresizingMask = cover.autoresizingMask || UIViewAutoresizingFlexibleTopMargin;
	}
	
	CGRect coverFrame = cover.frame;
	coverFrame.size.width = self.bounds.size.width;
	coverFrame.size.height = self.bounds.size.height;
	cover.frame = coverFrame;
	
	cover.tag = 1;
	
	UIImageView* currentCoverView = nil;
	
	for (UIView* subview in self.subviews)
	{
		if (1 == subview.tag)
		{
			currentCoverView = (UIImageView*)subview;
			break;
		}
	}
	
	if (animated)
	{
		cover.alpha = 0.0;
		
		[UIView beginAnimations:[NSString stringWithFormat:@"TweenCovers%d", self.tag] context:currentCoverView];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDelay:1.0];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationDelegate:self];
		//[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self cache:YES];
		
		currentCoverView.alpha = 0.0;
		cover.alpha = 1.0;
		
		[UIView commitAnimations];
	}
	else
	{
		[currentCoverView removeFromSuperview];
	}
	
	[self addSubview:cover];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if ([animationID hasPrefix:@"TweenCovers"]) {
		UIImageView* oldCover = (UIImageView*)context;
		[oldCover removeFromSuperview];
	}
}

- (void)dealloc {
	[_reuseIdentifier release];
	[_image release];
	
    [super dealloc];
}


@end
