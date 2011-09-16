//
//  PDFView.h
//  pdf2
//
//  Created by Craig Spitzkoff on 9/19/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PDFTiledLayer.h"

@class PDFPageView;

@protocol PDFPageViewDelegate<NSObject>

-(void) pdfViewTapped:(PDFPageView *)pdfView;
-(void) pdfViewMoved:(PDFPageView *)pdfView;

@end

@interface PDFPageView : UIControl <UIScrollViewDelegate, PDFTiledLayerDelegate>
{
	UIScrollView* _scrollView;
	UIActivityIndicatorView* _activityIndicator;
	
	CGPDFPageRef _page;
	CGPDFDocumentRef _doc;
	
	PDFTiledLayer* _tiledLayer;
	
	UIView* _pdfContentView;
	UIView* _backgroundView;
	
	// a rotate refresh needs to occur. 
	BOOL _rotateRefresh;
	
	NSURL* _url;
	
	//UISCrollView* _scrollView;
	id<PDFPageViewDelegate> _pdfDelegate;
	
//	UIImageView* _backgroundImageView;
	
}

@property (readonly) UIScrollView* scrollView;
@property (nonatomic, readonly) NSURL* url;
@property (nonatomic, assign) id<PDFPageViewDelegate> pdfDelegate;

@property (nonatomic, assign) CGPDFPageRef page; // this will actually be retained. 
//@property (nonatomic, readonly) UIScrollView* scrollView;

- (id)initWithFrame:(CGRect)frame doc:(CGPDFDocumentRef)doc page:(CGPDFPageRef) page;
- (id)initWithFrame:(CGRect)frame url:(NSURL*) url;

	
// perform items that need to happen to support refresh on rotate. 
-(void) rotated;

@end
