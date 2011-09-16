//
//  ThumbnailPageControl.h
//  RZUtils
//
//  Created by jkaufman on 9/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class PDFPageView;
@class ThumbnailPageControl;

@protocol ThumbnailPageControlDelegate<NSObject>

-(void) thumbnailPageControl:(ThumbnailPageControl*)control pageChanged:(int)pageNumber;

@end

@interface ThumbnailPageControl : UIControl {
	CGPDFDocumentRef _documentRef;
	int _pageCount;
	int _selectedPage;
	int _selectionStride;
	int _thumbPadding;
	int _padToCenter;
	int _thumbStride;
	int _showEvery;
	int _displayCount;	
	CGRect _displayRect;
	PDFPageView* _selectedPageView;
	
	// just the page thumbnail subviews.
	NSArray* _pageSubviews;
	
	// background Image view
	UIImageView* _backgroundImageView;
	
	id<ThumbnailPageControlDelegate> _delegate;
}

@property (assign) int selectedPage;
@property (assign) id<ThumbnailPageControlDelegate> delegate;

- (id)initWithFrame:(CGRect)aFrame document:(CGPDFDocumentRef)document;

@end
