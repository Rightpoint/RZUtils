//
//  STLoadingBlackView.m
//  ThumbSurveys
//
//  Created by Sebastian Trujillo on 3/26/09.
//  Copyright 2009 Studiocom. All rights reserved.
//

#import "RZHUD.h"
#import <QuartzCore/QuartzCore.h>

static RZHUD *s_loadingView = nil;

@implementation RZHUD

@synthesize background;
@synthesize text;
@synthesize _label;
@synthesize _spinner;
@synthesize _state;
@synthesize fadeOutAnimationDuration;

- (id)initWithText:(NSString *)newText 
{
    if (self = [super initWithFrame:CGRectMake(0, 0, 320, 460)]) {
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		self.fadeOutAnimationDuration = 0.2;
        self.background = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"STLoadingBlack.png"]] autorelease];
		background.frame = CGRectMake(80, 160, 160, 160);
		
		self._spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
		_spinner.center = CGPointMake(160, 240);
		[_spinner startAnimating];
		
		if(newText == nil)
			self.text = NSLocalizedString(@"Loading", nil);
		else
			self.text = newText;
		self._label = [[[UILabel alloc] initWithFrame:CGRectMake(90, 280, 140, 21)] autorelease];
		_label.textColor = [UIColor whiteColor];
		_label.backgroundColor = [UIColor clearColor];
		_label.font = [UIFont boldSystemFontOfSize:17];
		_label.textAlignment = UITextAlignmentCenter;
		_label.text = text;
		_label.adjustsFontSizeToFitWidth = YES;
		
		[self addSubview:background];
		[self addSubview:_spinner];
		[self addSubview:_label];
    }
    return self;
}


- (void)dealloc {
	[background release];
	[text release];
	[_label release];
	[_spinner release];
    [super dealloc];
}


#pragma mark -
#pragma mark Public methods


- (void)fadeIn {
	_state = STLoadingViewStateFadeIn;
	[self setNeedsDisplay];
}


- (void)fadeOut {
	_state = STLoadingViewStateFadeOut;
	[self setNeedsDisplay];
}


#pragma mark -
#pragma mark Draw methods

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	
    switch (_state) {
		case STLoadingViewStateFadeIn:
			[self _fadeIn:ctx];
			break;
		case STLoadingViewStateFadeOut:
			[self _fadeOut:ctx];
			break;
	}
}


- (void)_fadeIn:(CGContextRef)ctx {	
	float animationDuration = 0.2;
	
	CABasicAnimation *reduction = [CABasicAnimation animationWithKeyPath:@"transform"];
	CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
	CABasicAnimation *translation = [CABasicAnimation animationWithKeyPath:@"position"];
	CAAnimationGroup *fadeAnimation = [CAAnimationGroup animation];
	CAAnimationGroup *labelAnimation = [CAAnimationGroup animation];
	
	reduction.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.2, 0.2, 1)];
	reduction.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
	opacity.fromValue = [NSNumber numberWithFloat:0.3];
	opacity.toValue = [NSNumber numberWithFloat:1];
	translation.fromValue = [NSValue valueWithCGPoint:CGPointMake(160, 240)];
	translation.toValue = [NSValue valueWithCGPoint:CGPointMake(160, 290.5)];
	
	fadeAnimation.animations = [NSArray arrayWithObjects: reduction, opacity, nil];
	labelAnimation.animations = [NSArray arrayWithObjects: reduction, opacity, translation, nil];
	fadeAnimation.duration = animationDuration;
	labelAnimation.duration = animationDuration;
	
	[background.layer addAnimation:fadeAnimation forKey:@"STLBackgroundAnimation"];
	[_spinner.layer addAnimation:fadeAnimation forKey:@"STLSpinnerAnimation"];
	[_label.layer addAnimation:labelAnimation forKey:@"STLLabelAnimation"];
}


- (void)_fadeOut:(CGContextRef)ctx {	
	CABasicAnimation *reduction = [CABasicAnimation animationWithKeyPath:@"transform"];
	CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
	CABasicAnimation *translation = [CABasicAnimation animationWithKeyPath:@"position"];
	CAAnimationGroup *fadeAnimation = [CAAnimationGroup animation];
	CAAnimationGroup *labelAnimation = [CAAnimationGroup animation];
	
	reduction.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
	reduction.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2.5, 2.5, 1)];
	opacity.fromValue = [NSNumber numberWithFloat:1];
	opacity.toValue = [NSNumber numberWithFloat:0.3];
	translation.fromValue = [NSValue valueWithCGPoint:CGPointMake(160, 290.5)];
	translation.toValue = [NSValue valueWithCGPoint:CGPointMake(160, 390)];
	
	fadeAnimation.animations = [NSArray arrayWithObjects: reduction, opacity, nil];
	labelAnimation.animations = [NSArray arrayWithObjects: reduction, opacity, translation, nil];
	fadeAnimation.duration = fadeOutAnimationDuration;
	labelAnimation.duration = fadeOutAnimationDuration;
	
	[background.layer addAnimation:fadeAnimation forKey:@"STLBackgroundAnimation"];
	[_spinner.layer addAnimation:fadeAnimation forKey:@"STLSpinnerAnimation"];
	[_label.layer addAnimation:labelAnimation forKey:@"STLLabelAnimation"];
	
	[self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:fadeOutAnimationDuration-0.02];
}

+ (void)showLoadingWithMessage:(NSString *)msg inWindow:(UIWindow*)win
{
	if(nil == s_loadingView)
	{
		s_loadingView = [[RZHUD alloc] initWithText:msg];
		//[[[UIApplication sharedApplication] keyWindow] addSubview:s_loadingView];
		if (win == nil) {
			win = [[UIApplication sharedApplication] keyWindow];
		}
		[win performSelectorOnMainThread:@selector(addSubview:) withObject:s_loadingView waitUntilDone:YES];
	}
	else
	{
		[s_loadingView._label performSelectorOnMainThread:@selector(setText:) withObject:msg waitUntilDone:YES];
		//s_loadingView._label.text = msg;
	}
	
	//[s_loadingView fadeIn];
	[s_loadingView performSelectorOnMainThread:@selector(fadeIn) withObject:nil waitUntilDone:YES];
}

+ (float)hideLoading
{
	[s_loadingView performSelectorOnMainThread:@selector(fadeOut) withObject:nil waitUntilDone:YES];
	float duration = s_loadingView.fadeOutAnimationDuration;
	[s_loadingView autorelease];
	s_loadingView = nil;
	return duration;
}

+ (void)showLoading 
{
 	[RZHUD showLoadingWithMessage:@"Loading" inWindow:nil];
}

+ (void)showLoadingInWindow:(UIWindow*)win
{
 	[RZHUD showLoadingWithMessage:@"Loading" inWindow:win];
}

+ (void)showLoadingWithMessage:(NSString *)msg
{
	[RZHUD showLoadingWithMessage:msg inWindow:nil];
}

@end
