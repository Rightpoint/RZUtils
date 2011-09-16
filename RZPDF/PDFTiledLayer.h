//
//  PDFTiledLayer.h
//  SimpleTiledScrollExample
//
//  Created by Craig Spitzkoff on 9/6/10.
//  Copyright 2010 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol PDFTiledLayerDelegate<NSObject>

-(void) rendered;
-(void) startingRender;

@end

@interface PDFTiledLayer : CATiledLayer
{
    CGPDFPageRef _pageRef;	
	CGPDFDocumentRef _docRef;
	
	UIImage* _thumbnail;
	
	id<PDFTiledLayerDelegate> _tiledLayerDelegate;
}

@property (nonatomic, assign) CGPDFPageRef page;
@property (nonatomic, retain) UIImage* thumbnail;
@property (nonatomic, assign) id<PDFTiledLayerDelegate> tiledLayerDelegate;

-(id) initWithDoc:(CGPDFDocumentRef)doc Page:(CGPDFPageRef)page;

-(CGRect) pageBox;


@end
