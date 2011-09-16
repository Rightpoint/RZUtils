//
//  PDFGalleryScrollView.m
//  PDF
//
//  Created by Craig Spitzkoff on 9/17/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import "PDFGalleryScrollView.h"
#import "TappableScrollView.h"



@implementation PDFGalleryScrollView
@synthesize urls = _urls;
@synthesize url = _url;
@synthesize pdfMaxZoom = _pdfMaxZoom;
@synthesize pdfMinZoom = _pdfMinZoom;

@synthesize pdfViews = _pdfViews;
@synthesize galleryDelegate = _galleryDelegate;
@synthesize doc = _doc;
//@synthesize rotatingPageView = _rotatingPageView;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) 
	{
		self.pdfMaxZoom = 1.0;
		
		self.pagingEnabled = YES;
		self.clipsToBounds = NO;

		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
		
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		self.delegate = self;
	
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc 
{
	
	//self.rotatingPageView = nil;
	
	self.urls = nil;
	self.url = nil;
	
	CGPDFDocumentRelease(_doc);
	
    [super dealloc];
}

/*
- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event 
{	
	// If not dragging, send event to next responder
	if (!self.dragging) 
		[self.nextResponder touchesEnded: touches withEvent:event]; 
	else
		[super touchesEnded: touches withEvent: event];
}
*/

-(void) setUrls:(NSArray *)urls
{
	[_urls release];
	_urls = [urls retain];

	self.pdfViews = [NSMutableArray arrayWithCapacity:self.urls.count];
	
	// add subviews
	for (NSURL* url in self.urls)
	{
		PDFPageView* pdfView = [[[PDFPageView alloc] initWithFrame:self.frame url:url] autorelease];
		pdfView.scrollView.maximumZoomScale = self.pdfMaxZoom;
		pdfView.scrollView.minimumZoomScale = self.pdfMinZoom;
		[self addSubview:pdfView];
		
		[self.pdfViews addObject:pdfView];
		pdfView.pdfDelegate = self;
		//[pdfView addTarget:self action:@selector(thumbnailTapped:) forControlEvents:UIControlEventTouchUpInside];
		//break;
	}
	
	[self setNeedsLayout];
}


-(void) setUrl:(NSURL*)url
{
	[_url release];
	_url = [url retain];
	
	if (nil != _url)
	{
		// open the pdf
		_doc = CGPDFDocumentCreateWithURL((CFURLRef)_url);
		int numberOfPages = CGPDFDocumentGetNumberOfPages(_doc);

		self.pdfViews = [NSMutableArray arrayWithCapacity:self.urls.count];
		
		// add subviews
		for (int idx = 1; idx <= numberOfPages; idx++)
		{
			// Get the PDF Page that we will be drawing
			CGPDFPageRef page = CGPDFDocumentGetPage(self.doc, idx);
			PDFPageView* pdfView = [[[PDFPageView alloc] initWithFrame:self.frame doc:self.doc page:page] autorelease];
			pdfView.scrollView.maximumZoomScale = self.pdfMaxZoom;
			pdfView.scrollView.minimumZoomScale = self.pdfMinZoom;
			[self addSubview:pdfView];
			
			[self.pdfViews addObject:pdfView];
			pdfView.pdfDelegate = self;
		}
		
		[self layoutSubviews];
	}

	
}

-(int) numberOfPages
{
	return  self.pdfViews.count;
}

-(void) resetZooms
{
	for (int idx = 0; idx < self.pdfViews.count; idx++)
	{
		PDFPageView* pdfView = [self.pdfViews objectAtIndex:idx];
		pdfView.scrollView.zoomScale = 1.0;
	}
	
}

-(void) layoutSubviews
{
	int x = 0;
	for (int idx = 0; idx < self.pdfViews.count; idx++)
	{
		x += kMargin;
		PDFPageView* pdfView = [self.pdfViews objectAtIndex:idx];
		
		CGRect pdfViewFrame = CGRectMake(x, 0, self.bounds.size.width - (kMargin * 2), self.bounds.size.height);
		pdfView.frame = pdfViewFrame;
			/*
		if(self.rotatingPageView != pdfView)
		{
			pdfView.frame = pdfViewFrame;
		}
		*/
		
		x = pdfViewFrame.origin.x + pdfViewFrame.size.width + kMargin;
		
		//break;
	}
	
	self.contentSize = CGSizeMake(x, self.frame.size.height);
}

-(void) rotated
{
	for (int idx = 0; idx < self.pdfViews.count; idx++)
	{
		PDFPageView* pdfView = [self.pdfViews objectAtIndex:idx];
		[pdfView rotated];
		//break;
	}
}

-(void) determineCurrentPage
{
	NSLog(@"Current Offset: X: %lf Y: %lf", self.contentOffset.x, self.contentOffset.y);

	int page = self.contentOffset.x / self.bounds.size.width;
	
	if (_currentPage != page) 
	{
		[self resetZooms];
	}
	
	_currentPage = page;
	
	NSLog(@"Current Page: %d", _currentPage);
	
	[_galleryDelegate pdfGallery:self pageChanged:_currentPage];
		
}

-(PDFPageView*) currentPageView
{
	return [self.pdfViews objectAtIndex:_currentPage];
}

-(void) gotoPage:(int)page
{
	[self gotoPage:page animated:YES];
}

-(void) gotoPage:(int)page animated:(BOOL)animated
{
	_currentPage = page;
	
	[self resetZooms];
	
	int x = page * self.frame.size.width;
	CGRect rect = CGRectMake(x, 0, self.frame.size.width, self.frame.size.height);
	[self scrollRectToVisible:rect animated:animated];
}

#pragma mark -
#pragma mark PDFViewDelegate
-(void) pdfViewTapped:(PDFPageView *)pdfView
{
	//NSLog(@"PDFView tapped: %@", pdfView.url);
	[self.galleryDelegate pdfGallery:self pdfViewSelected:pdfView];
}

-(void) pdfViewMoved:(PDFPageView *)pdfView
{
	[self.galleryDelegate pdfGallery:self pdfViewMoved:pdfView];
}

#pragma mark -
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (!decelerate) 
	{
		[self determineCurrentPage];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self determineCurrentPage];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self determineCurrentPage];
}

@end
