//
//  BouncyDialog.m
//  RZUtils
//
//  Created by Robert Sesek on 7/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BouncyDialog.h"

const CGFloat kTransitionDuration = 0.3;

@interface BouncyDialog (Private)
- (void)animatePart1;
- (void)animatePart2;
@end

@implementation BouncyDialog
@synthesize contentView;
@synthesize showTitleBar;
@synthesize titleBarText;

- (id)initWithContentView:(UIView*)aContentView
{
	if (self = [super initWithFrame:CGRectMake(0, 0, 320, 460)])
	{
		self.contentView = aContentView;
	}
	return self;
}

- (void)dealloc
{
	[contentView release];
	[super dealloc];
}

- (void)show
{
	// Constants.
	const NSInteger kBorderWidth = 7;
	const NSInteger kTitleBarHeight = 25;
	const NSInteger kCloseButtonSize = 15;
	UIColor* borderColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:0.75];
	
	UIWindow* win = [UIApplication sharedApplication].keyWindow;
	CGRect wFrame = win.frame;
	
	// We want to occupy the entire window to create modal-ness. We will be
	// transparent for the region unoccupied by |contentView|.
	self.frame = wFrame;
	self.backgroundColor = [UIColor clearColor];
	self.alpha = 1.0;
	self.opaque = NO;
	
	// Center the |contentView| in the window.
	CGRect cFrame = contentView.frame;
	CGSize cSize = contentView.frame.size;
	cFrame.origin = CGPointMake(kBorderWidth, kBorderWidth + (showTitleBar ? kTitleBarHeight : 0));
	cFrame.size.height -= (showTitleBar ? kTitleBarHeight : 0);
	contentView.frame = cFrame;
	
	// Create a border for the dialog.
	CGRect bFrame;
	bFrame.size = cSize;
	bFrame.origin.x = ((wFrame.size.width - cFrame.size.width) / 2) - kBorderWidth;
	bFrame.origin.y = ((wFrame.size.height - cFrame.size.height) / 2) - kBorderWidth;
	bFrame.size.width += 2 * kBorderWidth;
	bFrame.size.height += 2 * kBorderWidth;
	UIView* border = [[UIView alloc] initWithFrame:bFrame];
	border.backgroundColor = borderColor;
	
	// If we are using a title bar, create it.
	if (showTitleBar)
	{
		UILabel* title = [[UILabel alloc]
			initWithFrame:CGRectMake(
				cFrame.origin.x,
				cFrame.origin.y - kTitleBarHeight - kBorderWidth,
				cSize.width,
				kTitleBarHeight + kBorderWidth
			)
		];
		title.text = titleBarText;
		title.opaque = NO;
		title.backgroundColor = [UIColor clearColor];
		title.textColor = [UIColor whiteColor];
		title.font = [UIFont boldSystemFontOfSize:18.0];
		title.adjustsFontSizeToFitWidth = YES;
		[border addSubview:title];
		[title release];
		
		UIButton* closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.titleLabel.font = title.font;
		[closeButton setTitle:@"x" forState:UIControlStateNormal];
		[closeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
		[closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
		closeButton.frame = CGRectMake(
			cSize.width - kCloseButtonSize,
			cFrame.origin.y - kTitleBarHeight - kBorderWidth - 2, // Pixel fudging for lowercase 'x'.
			kCloseButtonSize,
			kTitleBarHeight + kBorderWidth
		);
		[border addSubview:closeButton];
	}
	
	// Add the content on top of the border. Stacking matters.
	[border addSubview:contentView];
	[self addSubview:border];
	
	// Begin transformations. Shamelessly stolen from Facebook. What this does
	// is grow and then shrink twice using the identity matrix transform.
	self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration / 1.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animatePart1)];
	self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
	[UIView commitAnimations];	
	
	[win addSubview:self];
}

- (void)hide
{
	[self removeFromSuperview];
}

#pragma mark Private

- (void)animatePart1
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration / 2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animatePart2)];
	self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
	[UIView commitAnimations];	
}

- (void)animatePart2
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration / 2];
	self.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}

@end
