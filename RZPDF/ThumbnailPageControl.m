//
//  ThumbnailPageControl.m
//  RZUtils
//
//  Created by jkaufman on 9/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ThumbnailPageControl.h"
#import "PDFPageView.h"

@interface ThumbnailPageControl ()
- (CGRect)rectForPage:(int)index;
- (CGRect)rectForSelection:(int)index;
@end


@implementation ThumbnailPageControl

@synthesize selectedPage = _selectedPage;
@synthesize delegate = _delegate;

#define kInset 10.0f
#define kThumbDefaultPadding 3.0f
#define kThumbWidth 20.0f
#define kThumbHeight 20.0f
#define kSelectionOutset kThumbWidth / 2

- (void)dealloc 
{
 	[_pageSubviews release];
	[_backgroundImageView release];
	
	CGPDFDocumentRelease(_documentRef);
	_documentRef = nil;
	[super dealloc];
}

- (id)initWithFrame:(CGRect)aFrame document:(CGPDFDocumentRef)document {
	if (!(self = [super initWithFrame:aFrame]))
		return nil;
	
	_backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, aFrame.size.width, aFrame.size.height)];
	_backgroundImageView.opaque = NO;
	_backgroundImageView.backgroundColor = [UIColor clearColor];
	UIImage* image = [[UIImage imageNamed:@"pdf_browser_thumbnail_bar_background.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
	_backgroundImageView.image = image;
	
	[self addSubview:_backgroundImageView];
	
	// Prepare for layout.
	_documentRef = CGPDFDocumentRetain(document);
	_pageCount = CGPDFDocumentGetNumberOfPages(_documentRef);
	_selectedPage = 1;

	self.opaque = NO;
	self.userInteractionEnabled = YES;
	
	// Calculate page display count and spacing.
	_displayRect = CGRectInset(self.bounds, kInset, kInset);
	_displayCount = MIN((_displayRect.size.width + kThumbDefaultPadding) / (kThumbWidth + kThumbDefaultPadding), _pageCount);
	
	// Fill available space.
	_showEvery = _pageCount / _displayCount;
	_thumbPadding = (_displayRect.size.width - (_displayCount * kThumbWidth)) / _displayCount;
	
	// Horizontally center thumbnails in view.
	_thumbStride = kThumbWidth + _thumbPadding;
	_padToCenter = (_displayRect.size.width - ((_thumbStride * _displayCount) - _thumbPadding)) / 2;
	_selectionStride = _displayRect.size.width  / _pageCount;

	// Add thumbnail views.
	PDFPageView* thumb;
	CGPDFPageRef pageRef;
	NSMutableArray* pageSubviews = [NSMutableArray arrayWithCapacity:_displayCount];
	
	for (int i = 1; i <= _displayCount; i++) {
		pageRef = CGPDFDocumentGetPage(_documentRef, ((i - 1) * _showEvery) + 1);
		thumb = [[PDFPageView alloc] initWithFrame:[self rectForPage:i] doc:_documentRef page:pageRef];
		thumb.userInteractionEnabled = NO;
		thumb.opaque = NO;
		thumb.backgroundColor = [UIColor clearColor];
		[self  addSubview:thumb];
		[pageSubviews addObject:thumb];
		[thumb release];
	}

	_pageSubviews = [pageSubviews retain];
	
	// Position selected page view.
	
	//_selectedPageView = [[PDFPageView alloc] initWithDocument:_documentRef andFrame:[self rectForSelection:_selectedPage]];
	_selectedPageView = [[PDFPageView alloc] initWithFrame:[self rectForSelection:_selectedPage] doc:_documentRef page:[[pageSubviews objectAtIndex:_selectedPage-1] page]];
	_selectedPageView.opaque = NO;
	_selectedPageView.backgroundColor = [UIColor clearColor];
	_selectedPageView.userInteractionEnabled = NO;
	[self addSubview:_selectedPageView];
	
	return self;
}

// Returns the rect for the page at the given display index.
- (CGRect)rectForPage:(int)index {
	return CGRectMake(_displayRect.origin.x + _padToCenter + (_thumbStride * (index - 1)), _displayRect.origin.y, kThumbWidth, kThumbHeight);
}

// Returns the rect for the page at the given selection index.  This may not
// match that of the preview thumbnail, if already visible.  Study iBooks if
// this sounds wrong.
- (CGRect)rectForSelection:(int)index 
{
	int x = (_displayRect.size.width / _pageCount) * index;
	
	
	CGRect pageRect = CGRectMake(x - kInset - _thumbPadding / 2, _displayRect.origin.y, kThumbWidth, kThumbHeight);
	
	//CGRect pageRect = CGRectMake(_displayRect.origin.x + _padToCenter + (_selectionStride * (index - 1)), _displayRect.origin.y, kThumbWidth, kThumbHeight);
	return CGRectInset(pageRect, -kSelectionOutset, -kSelectionOutset);
}

- (int)pageAtPoint:(CGPoint)point {
	if (point.x >= CGRectGetMaxX(_displayRect)) 
	{
		return _pageCount;
	} 
	else if (point.x < CGRectGetMinX(_displayRect) + _padToCenter) 
	{
		return 1;
	} 
	else 
	{
		int page = (point.x + kInset + _thumbPadding / 2) * ((float)_pageCount / _displayRect.size.width);
		return page;
		
		//return ceil((point.x - kInset - _padToCenter) / _selectionStride);
	}
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint point = [touch locationInView:self];
	int page = [self pageAtPoint:point];
	if (page < 1 || page > _pageCount)
		return NO;
	self.selectedPage = page;
	return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint point = [touch locationInView:self];
	int page = [self pageAtPoint:point];
	if (page < 1 || page > _pageCount)
		return NO;
	self.selectedPage = page;
	return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint point = [touch locationInView:self];
	int page = [self pageAtPoint:point];
	if (page >= 1 || page <= _pageCount)
	{
		self.selectedPage = page;
	
		// tell the delegate the page changed. 
		[self.delegate thumbnailPageControl:self pageChanged:self.selectedPage];
	}
	
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
	
}


-(void) setSelectedPage:(int)index animate:(BOOL)animate force:(BOOL)force
{
	if (!force && index == self.selectedPage)
		return;
	
	//	FIXME: decide whether or not to animate tiny transitions.  Maybe do it by pixel distance, not index.
	//	BOOL animate = (abs(self.selectedPage - index) > 1);
	_selectedPage = index;
	if(animate)
		[UIView beginAnimations:@"SetSelected" context:nil];
	
	_selectedPageView.frame = [self rectForSelection:index];
	_selectedPageView.page = CGPDFDocumentGetPage(_documentRef, index);
	[self setNeedsDisplay];
	[_selectedPageView setNeedsDisplay];
	

	if (animate)
		[UIView commitAnimations];
	
	if(!force)
		[self sendActionsForControlEvents:UIControlEventValueChanged];	
}

- (void)setSelectedPage:(int)index {
	[self setSelectedPage:index animate:YES force:NO];
}

-(void) layoutSubviews
{
	_backgroundImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	
	// Calculate page display count and spacing.
	_displayRect = CGRectInset(self.bounds, kInset, kInset);
	_displayCount = MIN((_displayRect.size.width + kThumbDefaultPadding) / (kThumbWidth + kThumbDefaultPadding), _pageCount);
	
	// Fill available space.
	_showEvery = _pageCount / _displayCount;
	_thumbPadding = (_displayRect.size.width - (_displayCount * kThumbWidth)) / _displayCount;
	
	// Horizontally center thumbnails in view.
	_thumbStride = kThumbWidth + _thumbPadding;
	_padToCenter = (_displayRect.size.width - ((_thumbStride * _displayCount) - _thumbPadding)) / 2;
	_selectionStride = _displayRect.size.width  / _pageCount;
	// Add thumbnail views.
	for (int i = 0; i < _pageSubviews.count; i++) 
	{	
		PDFPageView* thumb = [_pageSubviews objectAtIndex:i];
		thumb.frame = [self rectForPage:i+1];
	}
	
	[self setSelectedPage:_selectedPage animate:NO force:YES];
}
@end