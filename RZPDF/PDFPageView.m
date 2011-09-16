//
//  PDFView.m
//  pdf2
//
//  Created by Craig Spitzkoff on 9/19/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import "PDFPageView.h"
#import "PDFTiledLayer.h"
#import "TappableScrollView.h"

@implementation PDFPageView
@synthesize url = _url;
@synthesize pdfDelegate = _pdfDelegate;
@synthesize page = _page;
@synthesize scrollView = _scrollView;

- (id)initWithFrame:(CGRect)frame url:(NSURL*) url
{
	// get the page and initialize. 
	CGPDFDocumentRef doc = CGPDFDocumentCreateWithURL((CFURLRef)url);
	CGPDFPageRef page = CGPDFDocumentGetPage(doc, 1);
	
	if(self = [self initWithFrame:frame doc:doc page:page])
	{
		_url = [url retain];
	}
	
	CGPDFDocumentRelease(doc);
	
	return self;
}

-(CGRect) activityIndicatorFrame
{
	
	CGRect activityIndicatorRect = CGRectMake((self.bounds.size.width - _activityIndicator.frame.size.width) / 2,
											  (self.bounds.size.height - _activityIndicator.frame.size.height) / 2,
											  _activityIndicator.frame.size.height,
											  _activityIndicator.frame.size.width);
	
	return activityIndicatorRect;
}

- (id)initWithFrame:(CGRect)frame doc:(CGPDFDocumentRef)doc page:(CGPDFPageRef) page
{
    if ((self = [super initWithFrame:frame])) 
	{
		_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[_activityIndicator hidesWhenStopped];
		[_activityIndicator startAnimating];
		_activityIndicator.frame = [self activityIndicatorFrame];
		
		_scrollView = [[TappableScrollView alloc] initWithFrame:self.bounds];
		
							  
		_scrollView.minimumZoomScale = 1.0;
		_scrollView.maximumZoomScale = 5.0;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
		_scrollView.delegate = self;
		[self addSubview:_scrollView];
		[self addSubview:_activityIndicator];
		
		_doc = CGPDFDocumentRetain(doc);
		_page = CGPDFPageRetain(page);
		
		_tiledLayer = [[PDFTiledLayer alloc] initWithDoc:_doc Page:_page];
		_tiledLayer.tileSize = CGSizeMake(1024.0, 1024.0);
		_tiledLayer.levelsOfDetail = 1000;
		_tiledLayer.levelsOfDetailBias = 1000;
		
		CGRect embeddedRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
		
		// get the page box. 
		CGRect pageBox = [_tiledLayer pageBox];
		
		float heightRatio = pageBox.size.height / embeddedRect.size.height;
		float widthRatio = pageBox.size.width / embeddedRect.size.width;
		
		// scale the page box by the best fit ratio
		float ratio = heightRatio > widthRatio ? heightRatio : widthRatio;
		pageBox = CGRectMake(0, 0, pageBox.size.width / ratio, pageBox.size.height / ratio);
		pageBox.origin.y = (embeddedRect.size.height -  pageBox.size.height) / 2;
		pageBox.origin.x = pageBox.origin.x + (embeddedRect.size.width - pageBox.size.width) / 2;			
		
		CGRect layerFrame =  CGRectMake(0, 0, pageBox.size.width, pageBox.size.height);
		float verticalInset = (embeddedRect.size.height - pageBox.size.height) / 2;
		float horizontalInset = (embeddedRect.size.width - pageBox.size.width) / 2;
		
		self.scrollView.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
		
		_tiledLayer.frame = layerFrame;
		_tiledLayer.tiledLayerDelegate = self;
				
		_pdfContentView = [[UIView alloc] initWithFrame:layerFrame];
		_pdfContentView.opaque = NO;
		_pdfContentView.backgroundColor = [UIColor clearColor];
		
//		CGAffineTransform rescale = CGPDFPageGetDrawingTransform(_page, kCGPDFCropBox, _tiledLayer.bounds, 0, true);
//		CGRect scaledRect = CGRectApplyAffineTransform(_tiledLayer.bounds, rescale);
//		_backgroundView = [[UIView alloc] initWithFrame:scaledRect];
//		_backgroundView.backgroundColor = [UIColor whiteColor];
//		[_pdfContentView.layer addSublayer:_backgroundView.layer];

		[_pdfContentView.layer addSublayer:_tiledLayer];
		[self.scrollView addSubview:_pdfContentView];
	}
    
	return self;
}

-(void) setPage:(CGPDFPageRef)page
{
	if(nil != _page)
		CGPDFPageRelease(_page);
		
	_page = page;
	if(nil != _page)
		CGPDFPageRetain(_page);
	
	_tiledLayer.page = _page;
}

- (void)dealloc 
{
	[_scrollView release];
	[_tiledLayer setTiledLayerDelegate:nil];
	[_tiledLayer removeFromSuperlayer];
	[_tiledLayer release];
	[_pdfContentView release];
	[_activityIndicator release];
	
	CGPDFPageRelease(_page);
	
	if(nil != _doc)
		CGPDFDocumentRelease(_doc);
	
    [super dealloc];
}

-(void) rotated
{
	_rotateRefresh = YES;
	self.scrollView.zoomScale = 1.0;
}

-(void) setNeedsDisplay
{
	[super setNeedsDisplay];
	[_activityIndicator startAnimating];
	
	_tiledLayer.contents = nil;
	[_tiledLayer setNeedsDisplay];
}

-(void) layoutSubviews
{
	
	CGRect embeddedRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
	self.scrollView.frame = embeddedRect;
	_activityIndicator.frame = [self activityIndicatorFrame];

	if(_rotateRefresh)
	{
		
		// get the page box. 
		CGRect pageBox = [_tiledLayer pageBox];
		
		float heightRatio = pageBox.size.height / embeddedRect.size.height;
		float widthRatio = pageBox.size.width / embeddedRect.size.width;
		
		// scale the page box by the best fit ratio
		float ratio = heightRatio > widthRatio ? heightRatio : widthRatio;
		pageBox = CGRectMake(0, 0, pageBox.size.width / ratio, pageBox.size.height / ratio);
		pageBox.origin.y = (embeddedRect.size.height -  pageBox.size.height) / 2;
		pageBox.origin.x = pageBox.origin.x + (embeddedRect.size.width - pageBox.size.width) / 2;

		CGRect layerFrame =  CGRectMake(0, 0, pageBox.size.width, pageBox.size.height);
		
		_pdfContentView.frame = layerFrame;
		_tiledLayer.frame = layerFrame;		
		self.scrollView.contentOffset = CGPointMake(0, 0);
		
		// force redraw on the tiled layer
		[_activityIndicator startAnimating];
		_tiledLayer.contents = nil;
		[_tiledLayer setNeedsDisplay];

		float verticalInset = (embeddedRect.size.height - pageBox.size.height) / 2;
		float horizontalInset = (embeddedRect.size.width - pageBox.size.width) / 2;
		
		self.scrollView.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
		
		
		self.scrollView.zoomScale = 1.0;
		
		_rotateRefresh = NO;
	}
	

}

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event 
{	
	// If not dragging, send event to next responder
	if (!self.scrollView.dragging) 
	{
		[_pdfDelegate pdfViewTapped:self];
	}
	else
		[super touchesEnded: touches withEvent: event];
}

#pragma mark -
#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return _pdfContentView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[_pdfDelegate pdfViewMoved:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_pdfDelegate pdfViewMoved:self];
}

#pragma mark PDFTiledLayerDelegate
-(void) rendered
{
	if([NSThread currentThread] != [NSThread mainThread])
	{
		[self performSelectorOnMainThread:@selector(rendered) withObject:nil waitUntilDone:YES];
		return;
	}
	
	[_activityIndicator stopAnimating];
}

-(void) startingRender
{
	if([NSThread currentThread] != [NSThread mainThread])
	{
		[self performSelectorOnMainThread:@selector(startingRender) withObject:nil waitUntilDone:YES];
		return;
	}
	
	[_activityIndicator startAnimating];
}

@end
