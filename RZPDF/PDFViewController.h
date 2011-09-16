//
//  PDFViewController.h
//  PDF
//
//  Created by Craig Spitzkoff on 9/17/10.
//  Copyright Raizlabs 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFGalleryScrollView.h"
#import "ThumbnailPageControl.h"

typedef enum {
	PDFViewControllerOrientationPortrait,
	PDFViewControllerOrientationLandscape
} PDFViewControllerOrientation;

@class PDFGalleryScrollView;

@interface PDFViewController : UIViewController <PDFGalleryScrollViewDelegate, ThumbnailPageControlDelegate>
{

	PDFGalleryScrollView* _pdfGallery;
	PDFGalleryScrollView* _pdfDetailGallery;
	
	UIPageControl* _pageController;
	
	UIToolbar* _toolBar;
	
	UIPageControl* _detailPageController;
	
	BOOL _toolsVisible;
	
	NSArray* _urls;
	NSURL* _url;
	
	NSArray* _detailToolbarItems;

	PDFViewControllerOrientation _requiredOrientation;	
}

@property (nonatomic, retain) PDFGalleryScrollView* pdfGallery;
@property (nonatomic, retain) PDFGalleryScrollView* pdfDetailGallery;
@property (nonatomic, retain) NSArray* urls;
@property (nonatomic, retain) NSURL* url;
@property (nonatomic, retain) NSArray* detailToolbarItems;
@property (nonatomic, retain) UIPageControl* pageControl;
@property (nonatomic, retain) UIPageControl* detailPageControl;
@property (nonatomic, assign) PDFViewControllerOrientation requiredOrientation;

-(void) setToolsVisible:(BOOL) visible;

@end

