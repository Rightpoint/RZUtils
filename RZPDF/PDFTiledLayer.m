//
//  PDFTiledLayer.m
//  SimpleTiledScrollExample
//
//  Created by Craig Spitzkoff on 9/6/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import "PDFTiledLayer.h"


@implementation PDFTiledLayer
@synthesize page = _pageRef;
@synthesize thumbnail = _thumbnail; 
@synthesize tiledLayerDelegate = _tiledLayerDelegate;

-(id) initWithDoc:(CGPDFDocumentRef)doc Page:(CGPDFPageRef)page
{
	if(self = [super init])
	{
		_pageRef = CGPDFPageRetain(page);
		_docRef = CGPDFDocumentRetain(doc);
		
		self.delegate = self;
	}
	
	return self;
}
-(void) dealloc
{
	_tiledLayerDelegate = nil;
	
	CGPDFPageRelease(_pageRef);
	_pageRef = nil;
	
	CGPDFDocumentRelease(_docRef);
	_docRef = nil;
	
	[super dealloc];
}

-(void) setPage:(CGPDFPageRef)page
{
	CGPDFPageRelease(_pageRef);
	_pageRef = CGPDFPageRetain(page);
}

- (void)setNeedsDisplay
{
	[super setNeedsDisplay];
	[_tiledLayerDelegate startingRender];
}
- (void)setNeedsDisplayInRect:(CGRect)r
{
	[super setNeedsDisplayInRect:r];
	[_tiledLayerDelegate startingRender];
}


-(void) createThumb
{
	CGRect pageRect =  CGPDFPageGetBoxRect(_pageRef, kCGPDFCropBox);
	
	// Create a low res image representation of the PDF page to display before the TiledPDFView
	// renders its content.
	UIGraphicsBeginImageContext(pageRect.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// First fill the background with white.
	CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
	CGContextFillRect(context,pageRect);
	
	CGContextSaveGState(context);
	// Flip the context so that the PDF page is rendered
	// right side up.
	CGContextTranslateCTM(context, 0.0, pageRect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextDrawPDFPage(context, _pageRef);
	CGContextRestoreGState(context);
	
	self.thumbnail = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
}
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
	if(nil == self.thumbnail)
	{
		
	}
	
	[_tiledLayerDelegate startingRender];
	
    CGContextTranslateCTM(ctx, 0.0, layer.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextConcatCTM(ctx, CGPDFPageGetDrawingTransform(_pageRef, kCGPDFCropBox, layer.bounds, 0, true));
	
	CGRect box =  CGPDFPageGetBoxRect(_pageRef, kCGPDFCropBox);
	
	CGContextClipToRect(ctx, box);
	
	CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(ctx, box);
	
    CGContextDrawPDFPage(ctx, _pageRef);
	
	[_tiledLayerDelegate rendered];
}

-(CGRect) pageBox
{
	CGRect box =  CGPDFPageGetBoxRect(_pageRef, kCGPDFCropBox);
	return box;
}
/*
+(CFTimeInterval)fadeDuration {
	return 0.0;
}
 */
@end
