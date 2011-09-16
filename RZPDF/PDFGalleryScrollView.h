//
//  PDFGalleryScrollView.h
//  PDF
//
//  Created by Craig Spitzkoff on 9/17/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TappableScrollView.h"
#import "PDFPageView.h"

#define kMargin 10

@class PDFGalleryScrollView;

@protocol PDFGalleryScrollViewDelegate<NSObject>

-(void) pdfGallery:(PDFGalleryScrollView*) gallery	pageChanged:(int)page;

-(void) pdfGallery:(PDFGalleryScrollView*) gallery	pdfViewSelected:(PDFPageView*)pdfPageView;

-(void) pdfGallery:(PDFGalleryScrollView*) gallery pdfViewMoved:(PDFPageView*)pdfPageView;

@end


@interface PDFGalleryScrollView : TappableScrollView <UIScrollViewDelegate, PDFPageViewDelegate>
{
	// if it is a gallery of differernt PDFs initial page, this will be set. 
	NSArray* _urls;
	
	// if it is a gallery of the pages of a single pdf, this will be set. 
	NSURL* _url;
	
	CGPDFDocumentRef _doc;
	
	NSMutableArray* _pdfViews;
	
	int _currentPage;
	
	id<PDFGalleryScrollViewDelegate> _galleryDelegate;
	
	float _pdfMaxZoom;
	float _pdfMinZoom;
	
	//PDFPageView* _rotatingPageView;
}

@property (nonatomic, retain) NSArray* urls;
@property (nonatomic, retain) NSURL* url;

@property (nonatomic, retain) NSMutableArray* pdfViews;
@property (nonatomic, assign) id<PDFGalleryScrollViewDelegate> galleryDelegate;

@property (nonatomic, readonly) CGPDFDocumentRef doc;
//@property (nonatomic, retain) PDFPageView* rotatingPageView;

@property float pdfMaxZoom;
@property float pdfMinZoom;

@property (readonly) int numberOfPages;

-(void) rotated;

-(void) gotoPage:(int)page;
-(void) gotoPage:(int)page animated:(BOOL)animated;

-(PDFPageView*) currentPageView;

@end
