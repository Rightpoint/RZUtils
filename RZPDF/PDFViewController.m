//
//  PDFViewController.m
//  PDF
//
//  Created by Craig Spitzkoff on 9/17/10.
//  Copyright Raizlabs 2010. All rights reserved.
//

#import "PDFViewController.h"
#import "PDFGalleryScrollView.h"
#import "ThumbnailPageControl.h"

#define kOverlap 30
#define kPageControlHeight 30

@interface PDFViewController()

-(void) showPDFDetail:(NSURL*) url;

@end

@implementation PDFViewController
@synthesize pdfGallery = _pdfGallery;
@synthesize pageControl = _pageControl;
@synthesize pdfDetailGallery = _pdfDetailGallery;
@synthesize urls = _urls;
@synthesize url = _url;
@synthesize detailToolbarItems = _detailToolbarItems;
@synthesize detailPageControl = _detailPageControl;
@synthesize requiredOrientation = _requiredOrientation;

- (id)initWithNibName:nibNameOrNil bundle:nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		_requiredOrientation = -1; // Invalid by default.
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pdf_browser_background.png"]]; 
	
	//CGRect rect = CGRectInset(self.view.bounds, kOverlap, 0);
	CGRect rect = CGRectMake(kOverlap, 0, self.view.bounds.size.width - kOverlap * 2, self.view.bounds.size.height - kPageControlHeight);
	
	self.pdfGallery = [[[PDFGalleryScrollView alloc] initWithFrame:rect] autorelease];
	self.pdfGallery.minimumZoomScale = 1.0;
	self.pdfGallery.maximumZoomScale = 1.0;
	self.pdfGallery.pdfMaxZoom = 1.0;
	self.pdfGallery.pdfMinZoom = 1.0;
	
	self.pdfGallery.galleryDelegate = self;
	[self.view addSubview:self.pdfGallery];
	/*
	 
	 NSString* filePath = [[NSBundle mainBundle] pathForResource:@"Files" ofType:@"plist"];
	 
	 // resolve the files into their paths. 
	 NSMutableArray* urls = [NSMutableArray arrayWithContentsOfFile:filePath];
	 for (int idx = 0; idx < urls.count; idx++)
	 {
	 NSString* filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[urls objectAtIndex:idx]];
	 NSURL* url = [NSURL fileURLWithPath:filePath];
	 [urls replaceObjectAtIndex:idx withObject:url];
	 }
	 */
	
	if (self.urls)
	{
		self.pdfGallery.urls = self.urls;
		
		[self.pdfGallery rotated];
		[self.pdfGallery setNeedsLayout];
		
		self.pageControl = [[[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - kPageControlHeight, self.view.frame.size.width, kPageControlHeight)] autorelease];
		[self.view addSubview:self.pageControl];
		
		
		self.pageControl.numberOfPages = self.urls.count;
		[self.pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
	}
	else if(self.url)
	{
		[self showPDFDetail:self.url];
	}
	
}

-(void) pageControlValueChanged:(id)sender
{
	if(sender == self.pageControl)
	{
		[self.pdfGallery gotoPage:self.pageControl.currentPage];
	}
	else if(sender == self.detailPageControl)
	{
		[self.pdfDetailGallery gotoPage:self.detailPageControl.currentPage];
	}
}

-(void)detailViewDone:(id) sender
{
	if(nil == self.urls)
	{
		[self dismissModalViewControllerAnimated:YES];
	}
	else 
	{
		/*
		 [_toolBar removeFromSuperview];
		 [_toolBar release];
		 _toolBar = nil;
		 */
		
		[self.pdfDetailGallery removeFromSuperview];
		self.pdfDetailGallery = nil;
		
		self.pdfGallery.hidden = NO;
		self.pageControl.hidden = NO;
		
		[self setToolsVisible:NO];
		
		[self.navigationController setNavigationBarHidden:NO animated:YES];
		
	}

}

#pragma mark Hiding and Showing Toolbars
-(void) setToolsVisible:(BOOL) visible
{
	_toolsVisible = visible;
	
	_toolBar.hidden = NO;
	//_thumbnailPageControl.hidden = NO;
	self.detailPageControl.hidden = NO;
	[UIView beginAnimations:@"tools" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	
	_toolBar.alpha = _toolsVisible ? 1.0 : 0.0;
	//_thumbnailPageControl.alpha = _toolsVisible ? 1.0 : 0.0;
	self.detailPageControl.alpha = _toolsVisible ? 1.0 : 0.0;
	[UIView commitAnimations];
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if([animationID isEqualToString:@"tools"])
	{
		[_toolBar setHidden:!_toolsVisible];
		
		if(self.pdfDetailGallery == nil)
		{
			[_toolBar removeFromSuperview];
			[_toolBar release];
			_toolBar = nil;
			
			[self.detailPageControl removeFromSuperview];
			self.detailPageControl = nil;
			
			//[_thumbnailPageControl removeFromSuperview];
			//[_thumbnailPageControl release];
			//_thumbnailPageControl = nil;
			
		}
	}
}

#pragma mark -
#pragma mark Rotation

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	switch (self.requiredOrientation) {
		case PDFViewControllerOrientationPortrait:
			return UIInterfaceOrientationIsPortrait(interfaceOrientation);
			break;
		case PDFViewControllerOrientationLandscape:
			return 	UIInterfaceOrientationIsLandscape(interfaceOrientation);
			break;
		default:
			return YES;
			break;
	}
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	PDFPageView* pageView = nil;
	
	// HACK: until we can do the animation correctly.
	if(self.pdfDetailGallery)
	{
		pageView = [self.pdfDetailGallery currentPageView];
		self.pdfDetailGallery.hidden = YES;
	}
	else
	{
		pageView = [self.pdfGallery currentPageView];		
		self.pdfGallery.hidden = YES;
	}

/*
	UIGraphicsBeginImageContext(pageView.bounds.size);
	[pageView.layer renderInContext:UIGraphicsGetCurrentContext()];
	viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	UIImageView* viewImageView = [[[UIImageView alloc] initWithImage:viewImage] autorelease];
	viewImageView.contentMode = UIViewContentModeCenter;
	viewImageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
	viewImageView.backgroundColor = [UIColor redColor];
	
	[self.view addSubview:viewImageView];
*/	
	/*
	 if(_performedFirstRotation)
	 {
	 // get the selected page. 
	 PDFPageView* page = self.pdfGallery.currentPageView;
	 [page removeFromSuperview];
	 
	 self.pdfGallery.rotatingPageView = page;
	 
	 [self.view addSubview:page];
	 
	 CGRect rect = CGRectMake((self.view.bounds.size.width - page.bounds.size.width) / 2,
	 (self.view.bounds.size.height - page.bounds.size.height) / 2,
	 page.bounds.size.width, page.bounds.size.height);
	 
	 // center the page
	 NSLog(@"Old page rect: %lf %lf %lf %lf", page.frame.origin.x, page.frame.origin.y, page.frame.size.width, page.frame.size.height);
	 NSLog(@"New page rect: %lf %lf %lf %lf", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
	 
	 page.frame = rect;		
	 self.pdfGallery.hidden = YES;
	 }
	 */
}

// called within an animation block
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	
	// center the page
	/*
	 self.pdfGallery.rotatingPageView.frame = CGRectMake((self.view.bounds.size.width - self.pdfGallery.rotatingPageView.bounds.size.width) / 2,
	 (self.view.bounds.size.height - self.pdfGallery.rotatingPageView.bounds.size.height) / 2,
	 self.pdfGallery.rotatingPageView.bounds.size.width, self.pdfGallery.rotatingPageView.bounds.size.height);
	 */	
	
	
	//CGRect rect = CGRectInset(self.view.bounds, kOverlap, 0);
	CGRect rect = CGRectMake(kOverlap, 0, self.view.bounds.size.width - kOverlap * 2, self.view.bounds.size.height - kPageControlHeight);
	self.pdfGallery.frame = rect;
	[self.pdfGallery rotated];
	
	self.pageControl.frame = CGRectMake(0, self.view.bounds.size.height - kPageControlHeight, self.view.bounds.size.width, kPageControlHeight);
	self.detailPageControl.frame = CGRectMake(0, self.view.bounds.size.height - kPageControlHeight, self.view.bounds.size.width, kPageControlHeight);
	
	rect = CGRectMake(-kMargin, 0, self.view.bounds.size.width + kMargin * 2, self.view.bounds.size.height);
	self.pdfDetailGallery.frame = rect;
	[self.pdfDetailGallery rotated];
	
	if(_toolBar)
	{
		_toolBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44);
	}
	
	/*
	if(_thumbnailPageControl)
	{
		_thumbnailPageControl.frame = CGRectMake(0, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44);
	}
	 */
	
	//UIImageView* viewImageView = [self.view.subviews objectAtIndex:self.view.subviews.count - 1];
	//viewImageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
	
	//[self.pdfGallery setNeedsLayout];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	
	[self.pdfGallery gotoPage:self.pageControl.currentPage animated:NO];
	[self.pdfDetailGallery gotoPage:self.detailPageControl.currentPage animated:NO];	
	//[self.pdfDetailGallery gotoPage:_thumbnailPageControl.selectedPage-1 animated:NO];

	if(self.pdfDetailGallery)
	{
		self.pdfDetailGallery.hidden = NO;
	}
	else
	{
		self.pdfGallery.hidden = NO;
	}
	
	//UIImageView* rotatableView = [self.view.subviews objectAtIndex:self.view.subviews.count - 1];
	//[rotatableView removeFromSuperview];
}

#pragma mark -
#pragma mark ThumbnailPageControlDelegate
-(void) thumbnailPageControl:(ThumbnailPageControl*)control pageChanged:(int)pageNumber
{
	[self.pdfDetailGallery gotoPage:pageNumber - 1];
}

#pragma mark -
#pragma mark PDFGalleryScrollViewDelegate
-(void) pdfGallery:(PDFGalleryScrollView*) gallery pageChanged:(int)page
{
	if (gallery == self.pdfGallery)
	{
		self.pageControl.currentPage = page;
	}
	else if(gallery == self.pdfDetailGallery)
	{
		self.detailPageControl.currentPage = page;
		//[_thumbnailPageControl setSelectedPage:page+1];
	}
	
	[self setToolsVisible:NO];
}

-(void) showPDFDetail:(NSURL*) url
{
	CGRect rect = CGRectMake(-kMargin, 0, self.view.bounds.size.width + kMargin * 2, self.view.bounds.size.height);
	
	self.pdfDetailGallery = [[[PDFGalleryScrollView alloc] initWithFrame:rect] autorelease];
	self.pdfDetailGallery.pdfMaxZoom = 5.0;
	self.pdfDetailGallery.pdfMinZoom = 1.0;
	self.pdfDetailGallery.galleryDelegate = self;
	[self.view addSubview:self.pdfDetailGallery];
	
	self.pdfDetailGallery.url = url;
	
	[self.pdfDetailGallery rotated];
	[self.pdfDetailGallery setNeedsLayout];
	
	_toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
	_toolBar.items = self.detailToolbarItems;
	_toolBar.barStyle = UIBarStyleBlack;
	_toolBar.translucent = YES;
	_toolBar.alpha = 0;
	_toolBar.hidden = YES;
	[self setToolsVisible:YES];
	
	[self.view addSubview:_toolBar];
	// Add a done button if there is a gallery to which we can return.
	if (self.urls) {
		UIBarButtonItem* button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(detailViewDone:)] autorelease];
		UIBarButtonItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
		_toolBar.items = [[NSArray arrayWithObjects:button, space, nil] arrayByAddingObjectsFromArray:_toolBar.items];
	}

	self.detailPageControl = [[[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - kPageControlHeight, self.view.bounds.size.width, kPageControlHeight)] autorelease];
	
	self.detailPageControl.numberOfPages = self.pdfDetailGallery.numberOfPages;
	[self.detailPageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
	self.detailPageControl.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
	[self.view addSubview:self.detailPageControl];

}

-(void) pdfGallery:(PDFGalleryScrollView*) gallery	pdfViewSelected:(PDFPageView*)pdfPageView
{
	[self setToolsVisible:!_toolsVisible];
	
	if(gallery == self.pdfGallery)
	{
		NSLog(@"PDFView selected");
		
		self.pdfGallery.hidden = YES;
		self.pageControl.hidden = YES;
		
		//CGRect rect = CGRectInset(self.view.bounds, kOverlap, 0);
		[self.navigationController setNavigationBarHidden:YES animated:YES];
		
		[self showPDFDetail:pdfPageView.url];
		
	}
	
}

-(void) pdfGallery:(PDFGalleryScrollView*) gallery pdfViewMoved:(PDFPageView*)pdfPageView
{
	if(gallery == self.pdfDetailGallery)
	{
		[self setToolsVisible:NO];
	}
}

#pragma mark -
#pragma mark Unload
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
	self.pageControl = nil;
	self.detailPageControl = nil;
	
	self.pdfGallery = nil;
	self.pdfDetailGallery = nil;
	self.urls = nil;
	self.url = nil;
	
    [super dealloc];
}

@end
