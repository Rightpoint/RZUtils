//
//  coreTextExViewController.m
//  coreTextEx
//
//  Created by Craig Spitzkoff on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "coreTextExViewController.h"
#import "ColumnsView.h"
#import "OHAttributedLabel.h"
#import "FontViewController.h"
#import "NSString+Hyphenate.h"
#import "NSAttributedString+HTML.h"
#import "RZStyledTextView.h"
#import "RZWrappingTextView.h"

#define kDefaultFontSize 17

@interface coreTextExViewController()

- (void)layoutText;
- (void)layoutRZText;
- (NSAttributedString *)testString:(int)which;

@end


@implementation coreTextExViewController
@synthesize columnsView = _columnsView;
@synthesize scrollView = _scrollView;
@synthesize text = _text;
@synthesize textView = _textView;
//@synthesize popoverController;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];

	// load the text. 
	self.text = [self testString:0];

	//NSRange range = [self.columnsView rangeOfStringFromLocation:0];
	//NSLog(@"Range location:%d length:%d", range.location, range.length);
	
	_pageViews = [[NSMutableArray alloc] initWithCapacity:3];
	
// TEST ColumnsView
//	[self layoutText];
	
// TEST RZStyledTextView
//	[self layoutRZText];
	
// TEST RZWrappingTextView
	NSDictionary *first = (NSDictionary*)CGRectCreateDictionaryRepresentation(CGRectMake(60, 840, 190, 100));
	NSDictionary *second = (NSDictionary*)CGRectCreateDictionaryRepresentation(CGRectMake(350, 400, 10, 10));
	NSDictionary *third = (NSDictionary*)CGRectCreateDictionaryRepresentation(CGRectMake(30, 700, 10, 100));
	NSDictionary *fourth = (NSDictionary*)CGRectCreateDictionaryRepresentation(CGRectMake(500, 400, 100, 100));
	NSSet *exclusionFrames = [NSSet setWithObjects: first, second, third, fourth, nil];
	RZWrappingTextView *test = 
	[[RZWrappingTextView alloc] initWithFrame:self.scrollView.frame 
									   string:self.text
									 location:0
								   edgeInsets:UIEdgeInsetsZero
							  exclusionFrames:exclusionFrames];
	[[self view] addSubview:test];

}

- (NSAttributedString *)testString:(int)which {
	NSAttributedString *aString = nil;
	NSError *error;
	if (which) {
		NSURL *url = [[NSBundle mainBundle] URLForResource:@"styles" withExtension:@"html"];
		NSString* rawString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
		aString = [[NSAttributedString alloc] initWithHTML:[rawString dataUsingEncoding:NSUTF8StringEncoding] options:nil documentAttributes:nil];
	} else {
		NSURL* url = [[NSBundle mainBundle] URLForResource:@"sampleText" withExtension:@"txt"];
		NSString* rawText = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
		
		NSLocale* en = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
		NSString* preparedText = [rawText stringByHyphenatingWithLocale:en];
		aString = [[NSAttributedString alloc] initWithString:preparedText];
	}
	
	return [aString autorelease];
}

- (void) layoutRZText {

	NSUInteger startPosition = 0;
	NSUInteger pageNumber = 0;

	CGRect rect = self.scrollView.bounds;
	rect.origin.y = pageNumber * rect.size.height;

	if (!self.textView) {
		self.textView = [[RZStyledTextView alloc] initWithFrame:rect
														 string:self.text 
													   location:startPosition
													 edgeInsets:UIEdgeInsetsMake(25, 25, 25, 25)];
		[_scrollView addSubview:self.textView];
	}
	
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
		[self.textView setString:[self testString:0]];
	else
		[self.textView setString:[self testString:1]];
}

-(void) layoutText
{
	NSUInteger startPosition = 0;
	NSUInteger pageNumber = 0;
	
	while (startPosition < self.text.length)
	{
		// add a new columns view
		CGRect rect = self.scrollView.bounds;
		rect.origin.y = pageNumber * rect.size.height;
		
		ColumnsView* columnsView = nil;
		 
		if (pageNumber < _pageViews.count) 
		{
			columnsView = [_pageViews objectAtIndex:pageNumber];
			columnsView.frame = rect;
		}
		else 
		{	
			columnsView = [[[ColumnsView alloc] initWithFrame:rect] autorelease];
			[_pageViews addObject:columnsView];
			[_scrollView addSubview:columnsView];
		}

		columnsView.columnCount = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 2 : 3;
		
		columnsView.text = [[self.text mutableCopy] autorelease];
		columnsView.startPosition = startPosition;
		[columnsView adjustPointSize:_selectedPointSizeAdjustment];
		[columnsView setNeedsDisplay];

		NSRange pageRange = [columnsView rangeOfStringFromLocation:startPosition];
		startPosition = pageRange.location + pageRange.length;
		
		pageNumber++;
	}
	
	// if there are pages we are no longer using, remove them
	for (int pageIdx = _pageViews.count - 1; pageIdx >= pageNumber; pageIdx--)
	{
		ColumnsView* columnsVew = [_pageViews objectAtIndex:pageIdx];
		[columnsVew removeFromSuperview];
		[_pageViews removeObjectAtIndex:pageIdx];
	}
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 
											 self.scrollView.frame.size.height * pageNumber);
}

-(IBAction) minusPressed:(id)sender
{
	_selectedPointSizeAdjustment = -1;	
	[self layoutRZText];
}

-(IBAction) plusPressed:(id)sender
{
	_selectedPointSizeAdjustment = 1;	
	[self layoutRZText];
}

-(IBAction) fontPressed:(id)sender
{
//	UIBarButtonItem* button = (UIBarButtonItem*)sender;
//	
//	FontViewController* fontViewController = [[[FontViewController alloc] initWithNibName:@"FontViewController" bundle:nil] autorelease];
//	
//	
//	self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:fontViewController] autorelease];
//	CGSize contentSize = fontViewController.view.frame.size;
//	
//	self.popoverController.popoverContentSize = contentSize;
////	fontViewController.selectedFont = _selectedFont;
//	fontViewController.delegate = self;
//	
//	[self.popoverController presentPopoverFromBarButtonItem:button permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self layoutRZText];
}
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	[_pageViews release];
	[_text release];
//	[_selectedFont release];
	
    [super dealloc];
}

//#pragma mark -
//#pragma mark FontViewControllerDelegate
//-(void) fontSelected:(UIFont*)font
//{
//	[_selectedFont release];
//	_selectedFont = [font retain];
//	
//	[self layoutText];
//}


@end
