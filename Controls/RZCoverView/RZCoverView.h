//
//  RZCoverView.h
//  IssueControl
//
//  Created by Joe Goullaud on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZCoverViewCell.h"

@protocol RZCoverViewDataSource;
@protocol RZCoverViewDelegate;

typedef enum {
	RZCoverViewStyleDefault,
	RZCoverViewStyleShelf,
	RZCoverViewStyleShelfReflected
} RZCoverViewStyle;

@interface RZCoverView : UIScrollView<UIScrollViewDelegate> {
	
	id<RZCoverViewDataSource, NSObject> _dataSource;
	
	id<RZCoverViewDelegate, NSObject> _coverViewDelegate;
	
	BOOL _dimInactiveCovers;
	
	BOOL _pulseCoversOnTouch;
	
	NSIndexPath* _currentIndex;
	
	NSDictionary* _cachedCoverViewCells;
	
	int _numberOfCoversToCache;
	
	float _margin;
	
	RZCoverViewStyle _style;
	
	CGRect _viewFrame;
	
	CGSize _coverSize;
	
	NSNumber* _scrollingToIndex;
	
	BOOL _reloadingData;
	
	BOOL _reflection;
	
	NSDate* _lastUpdate;
	CGFloat _lastXPos;
	CGFloat _lastVelocity;
}

@property (nonatomic, assign) id<RZCoverViewDataSource> dataSource;
@property (nonatomic, assign) id<RZCoverViewDelegate> coverViewDelegate;
@property (nonatomic, assign) BOOL dimInactiveCovers;
@property (nonatomic, assign) BOOL pulseCoversOnTouch;
@property (nonatomic, retain) NSIndexPath* currentIndex;
@property (readonly) RZCoverViewStyle style;

- (id)initWithFrame:(CGRect)frame style:(RZCoverViewStyle)style;

- (RZCoverViewCell*)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (void)reloadData;

- (IBAction)scrollToCoverViewCell:(RZCoverViewCell*)coverViewCell;
- (void)scrollToCoverViewCell:(RZCoverViewCell*)coverViewCell animated:(BOOL)animated;
- (void)scrollToCoverAtIndexPath:(NSIndexPath*)indexPath;
- (void)scrollToCoverAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;

- (RZCoverViewCell*)cellForCoverAtIndexPath:(NSIndexPath*)indexPath;

- (void)setDimInactiveCovers:(BOOL)dimCovers animated:(BOOL)animated;
- (void)setCurrentIndexAnimated:(NSIndexPath*)indexPath;

@end


@protocol RZCoverViewDelegate<NSObject>

@optional
- (CGFloat)coverView:(RZCoverView*)coverView widthForCoverAtIndexPath:(NSIndexPath*)indexPath;
- (void)coverView:(RZCoverView*)coverView activeCoverChangedToCoverAtIndexPath:(NSIndexPath*)indexPath;

- (void)coverView:(RZCoverView*)coverView willSelectCoverAtIndexPath:(NSIndexPath*)indexPath;
- (void)coverView:(RZCoverView*)coverView didSelectCoverAtIndexPath:(NSIndexPath*)indexPath;
- (void)coverView:(RZCoverView*)coverView willDeselectCoverAtIndexPath:(NSIndexPath*)indexPath;
- (void)coverView:(RZCoverView*)coverView didDeselectCoverAtIndexPath:(NSIndexPath*)indexPath;

@end


@protocol RZCoverViewDataSource<NSObject>

- (RZCoverViewCell*)coverView:(RZCoverView*)coverView cellForCoverAtIndexPath:(NSIndexPath*)indexPath;
- (NSInteger)coverView:(RZCoverView*)coverView numberOfCoversInSection:(NSInteger)section;

@optional

@end