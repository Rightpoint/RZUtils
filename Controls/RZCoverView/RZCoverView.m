//
//  RZCoverView.m
//  IssueControl
//
//  Created by Joe Goullaud on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RZCoverView.h"

double const kDefaultMargin = -30.0f;
double const kDefaultGrowAnimationDuration = 0.20;
double const kDefaultVerticalPadding = 20.0;

double const kSmallScaleFactor = 0.85;

// image reflection
static const CGFloat kDefaultReflectionFraction = 0.10;
static const CGFloat kDefaultReflectionOpacity = 0.4;

@interface RZCoverView (Private)

@property (nonatomic, assign) CGSize coverSize;

- (CGSize)calculateCoverSize;
- (CGFloat)calculateCoverWidth;
- (CGFloat)calculateCoverHeight;
- (CGSize)scrollingContentSize;
- (CGPoint)contentOffsetForCoverAtIndexPath:(NSIndexPath*)indexPath;
- (NSArray*)visibleIndecies;
- (NSInteger)determineCurrentIndex;
- (NSInteger)getIndexForPosition:(CGFloat)xPosition;

- (IBAction)advanceLeft;
- (IBAction)advanceRight;

- (void)updateCoverViewCells:(BOOL)animated;
- (void)updateCoverViewCells:(BOOL)animated withDuration:(double)duration;
- (BOOL)updateIndex;
- (BOOL)shouldSnapToCoverAtIndexPath:(NSIndexPath*)indexPath scrollView:(UIScrollView*)scrollView velocity:(double)velocity;

//CoverViewCell Actions
- (IBAction)coverTouched:(RZCoverViewCell*)coverViewCell;
- (IBAction)coverTouchedCancelled:(RZCoverViewCell*)coverViewCell;
- (IBAction)coverTapped:(RZCoverViewCell*)coverViewCell;

//CoverViewCell Animations
- (void)popCoverUp:(RZCoverViewCell*)coverViewCell;
- (void)popCoverDown:(RZCoverViewCell*)coverViewCell;
- (void)popCover:(RZCoverViewCell *)coverViewCell;

@end

@interface RZCoverView (ImageReflections)

- (UIImage *)reflectedImage:(UIImageView *)fromImage withHeight:(NSUInteger)height;
CGImageRef CreateGradientImage(int pixelsWide, int pixelsHigh);
CGContextRef MyCreateBitmapContext(int pixelsWide, int pixelsHigh);

@end


@implementation RZCoverView

@synthesize dataSource = _dataSource;
@synthesize coverViewDelegate = _coverViewDelegate;
@synthesize dimInactiveCovers = _dimInactiveCovers;
@synthesize bottomPadding = _bottomPadding;
@synthesize pulseCoversOnTouch = _pulseCoversOnTouch;
@synthesize currentIndex = _currentIndex;
@synthesize style = _style;


- (id)initWithFrame:(CGRect)frame {
	return [self initWithFrame:frame style:RZCoverViewStyleDefault];
}

- (id)initWithFrame:(CGRect)frame style:(RZCoverViewStyle)style {
    self = [super initWithFrame:frame];
    if (self) {
        // Custom initialization.
		_dataSource = nil;
		_coverViewDelegate = nil;
		_cachedCoverViewCells = [[NSMutableDictionary alloc] init];
		_dimInactiveCovers = NO;
		_pulseCoversOnTouch = YES;
        _bottomPadding = kDefaultVerticalPadding;
		_margin = kDefaultMargin;
		_viewFrame = frame;
		_style = style;
		_reflection = (RZCoverViewStyleShelfReflected == style);
		_currentIndex = [[NSIndexPath indexPathForRow:0 inSection:0] retain];
		_lastUpdate = nil;
		
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.alwaysBounceVertical = NO;
		self.directionalLockEnabled = YES;
		self.scrollsToTop = NO;
		self.backgroundColor = [UIColor blackColor];
		self.multipleTouchEnabled = NO;
		
		self.delegate = self;
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | 
								UIViewAutoresizingFlexibleHeight | 
								UIViewAutoresizingFlexibleTopMargin | 
								UIViewAutoresizingFlexibleBottomMargin | 
								UIViewAutoresizingFlexibleLeftMargin | 
								UIViewAutoresizingFlexibleRightMargin;
		
		self.contentMode = UIViewContentModeScaleToFill;
		
		[self addObserver:self forKeyPath:@"currentIndex" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"currentIndex"];
	
	_dataSource = nil;
    _coverViewDelegate = nil;
    [_currentIndex release];
    [_cachedCoverViewCells release];
    [_scrollingToIndex release];
    [_lastUpdate release];
	
    [super dealloc];
}

- (void)layoutSubviews
{
	//TODO smartly trigger reloadData from here on things like rotate?
}

//Overridden to stop delegate callbacks for scrolling when the frame is changed
- (void)setFrame:(CGRect)frame
{
	if (self.delegate == self)
	{
		self.delegate = nil;
		[super setFrame:frame];
		self.delegate = self;
	}
	else
	{
		[super setFrame:frame];
	}
}

- (RZCoverViewCell*)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
	return [[[RZCoverViewCell alloc] initWithStyle:RZCoverViewCellStyleDefault reuseIdentifier:(NSString*)identifier] autorelease];
}

- (void)reloadData
{
	NSLog(@"Begin Reload");
	_reloadingData = YES;
	BOOL animations = [UIView areAnimationsEnabled];
	
	[UIView setAnimationsEnabled:NO];
	
	for (UIView* view in self.subviews)
	{
		[view removeFromSuperview];
	}
	
	double horizontalPadding = (self.bounds.size.width / 2.0) - ([self calculateCoverWidth] / 2.0);
	double bottomPadding = self.bottomPadding;
	
	if(_reflection)
	{
		bottomPadding += (self.bounds.size.height - bottomPadding - kDefaultVerticalPadding)  * (kDefaultReflectionFraction + 0.05);
	}
	
	self.contentInset = UIEdgeInsetsMake(kDefaultVerticalPadding, horizontalPadding, bottomPadding, horizontalPadding);
	
	self.coverSize = [self calculateCoverSize];
	_margin = 0;//(self.coverSize.width / 10.0);
	
	self.contentSize = [self scrollingContentSize];
	
	
	int covers = [self.dataSource coverView:self numberOfCoversInSection:0];
	
	for (int i = 0; i < covers; ++i) {
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
		
		RZCoverViewCell* cell = [self.dataSource coverView:self cellForCoverAtIndexPath:indexPath];
		cell.frame = (CGRect){[self contentOffsetForCoverAtIndexPath:indexPath],[self coverSize]};
		cell.backgroundColor = [UIColor clearColor];
		cell.clipsToBounds = YES;
		cell.opaque = NO;
        [cell updateImage:cell.image animated:NO];
		/*
		UIImageView* cover = [[UIImageView alloc] initWithImage:cell.image];
		UIImageView* reflectionView = nil;
		
		if (_reflection) {
			
			NSUInteger reflectionHeight = cover.frame.size.height;// * kDefaultReflectionFraction;
			
			// create the reflection image and assign it to the UIImageView
			reflectionView = [[UIImageView alloc] initWithImage:[self reflectedImage:cover withHeight:reflectionHeight]];
			reflectionView.alpha = kDefaultReflectionOpacity;
			reflectionView.clipsToBounds = YES;
			
			
		}
		
		//cover.contentMode = UIViewContentModeScaleAspectFit;
		//cover.autoresizingMask = UIViewAutoresizingFlexibleWidth || UIViewAutoresizingFlexibleHeight || UIViewAutoresizingFlexibleLeftMargin || UIViewAutoresizingFlexibleRightMargin;
		
		//if (RZCoverViewStyleShelf == _style || RZCoverViewStyleShelfReflected == _style)
		//{
		//	cover.autoresizingMask = cover.autoresizingMask || UIViewAutoresizingFlexibleTopMargin;
		//}
		
		//CGRect coverFrame = cover.frame;
		//coverFrame.size.width = cell.frame.size.width;
		//coverFrame.size.height = cell.frame.size.height;
		//cover.frame = coverFrame;
		
        CGRect coverFrame = [RZCoverView scaleRect:cover.frame toFitInsideFrame:cell.frame];
        
        if (RZCoverViewStyleShelf == _style || RZCoverViewStyleShelfReflected == _style)
        {
            coverFrame.origin.y = cell.frame.size.height - coverFrame.size.height;
        }
        
        cover.frame = coverFrame;
        
		cover.tag = 1;
		
//		NSLog(@"Cell Height: %f Cover Height: %f", cell.frame.size.height, cover.bounds.size.height);
		
		if (_reflection)
		{
			cell.clipsToBounds = NO;
			
			reflectionView.contentMode = UIViewContentModeScaleAspectFit;
			reflectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
			
			if (RZCoverViewStyleShelf == _style || RZCoverViewStyleShelfReflected == _style)
			{
				reflectionView.autoresizingMask = reflectionView.autoresizingMask | UIViewAutoresizingFlexibleTopMargin;
			}
			
			CGRect reflectFrame = reflectionView.frame;
			reflectFrame.size.width = cell.imageView.frame.size.width;
			reflectFrame.size.height = cell.imageView.frame.size.height;// * kDefaultReflectionFraction;
			reflectionView.frame = reflectFrame;
			
			reflectionView.tag = 2;
			
			reflectionView.center = CGPointMake(cover.center.x, (cover.frame.size.height * 1.5) + 4.0);//(1 + (kDefaultReflectionFraction / 2.0))) + 4.0 );
			
			[cell addSubview:reflectionView];
			[reflectionView release];
		}
		*/
		[cell addTarget:self action:@selector(coverTapped:) forControlEvents:UIControlEventTouchUpInside];
		[cell addTarget:self action:@selector(coverTouched:) forControlEvents:UIControlEventTouchDown];
		[cell addTarget:self action:@selector(coverTouchedCancelled:) forControlEvents:UIControlEventTouchCancel | UIControlEventTouchUpOutside];
		//[cell addSubview:cover];
		//[cover release];
		
		
		[cell setTag:i];
		[self addSubview:cell];
		
//		NSLog(@"Cover Frame: %f, %f, %f, %f", cover.frame.origin.x, cover.frame.origin.y, cover.frame.size.width, cover.frame.size.height);
//		NSLog(@"Cell Frame: %f, %f, %f, %f", cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
//		NSLog(@"Cell: %@", cell);
	}
	
	[self updateCoverViewCells:NO];
	
	[self scrollToCoverAtIndexPath:self.currentIndex animated:NO];
	
	[self.coverViewDelegate coverView:self activeCoverChangedToCoverAtIndexPath:self.currentIndex];
	
	[UIView setAnimationsEnabled:animations];
	_reloadingData = NO;
	NSLog(@"End Reload");
}

- (IBAction)scrollToCoverViewCell:(RZCoverViewCell*)coverViewCell
{
	[self scrollToCoverViewCell:coverViewCell animated:YES];
}

//TODO Clean up so currOffset calc is consistent between both animated and non-animated
- (void)scrollToCoverViewCell:(RZCoverViewCell*)coverViewCell animated:(BOOL)animated
{
//	NSLog(@"ScrollingValue: %d", [_scrollingToIndex boolValue]);
	if (![_scrollingToIndex boolValue])
	{
		_scrollingToIndex = [NSNumber numberWithBool:YES];
		
		CGFloat x = coverViewCell.center.x - ([self coverSize].width / 2.0);
		
		CGRect rect = CGRectMake( (x <= 0)? 0 : x , 0, [self coverSize].width, [self coverSize].height);
		
		CGFloat currOffset = self.contentOffset.x + self.contentInset.left;
		
		if (fabs(currOffset - rect.origin.x) > 1.0)
		{
//			NSLog(@"scrollRectVisibleAnimated: %d", animated);
			if (animated) {
				[self scrollRectToVisible:rect animated:animated];
			} else {
				CGPoint newOffset = CGPointMake([self contentOffsetForCoverAtIndexPath:[NSIndexPath indexPathForRow:coverViewCell.tag inSection:0]].x - self.contentInset.left, -self.contentInset.top);
				[self setContentOffset:newOffset];
				_scrollingToIndex = nil;
				[self updateIndex];
			}
		}
		else
		{
//			NSLog(@"No Scroll!");
			_scrollingToIndex = nil;
			self.userInteractionEnabled = YES;
		}
	}
}

- (void)scrollToCoverAtIndexPath:(NSIndexPath *)indexPath
{
	[self scrollToCoverAtIndexPath:indexPath animated:YES];
}

- (void)scrollToCoverAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated
{
	RZCoverViewCell* cell = nil;
	
	for (RZCoverViewCell* cover in [self subviews]) {
		if (cover.tag == indexPath.row) {
			cell = cover;
			break;
		}
	}
	
	[self scrollToCoverViewCell:cell animated:animated];
}

- (RZCoverViewCell*)cellForCoverAtIndexPath:(NSIndexPath*)indexPath
{
	RZCoverViewCell* cell = nil;
	
	for (UIView* subview in self.subviews)
	{
		if (subview.tag == indexPath.row)
		{
			cell = (RZCoverViewCell*)subview;
			break;
		}
	}
	
	return cell;
}

- (void)setDimInactiveCovers:(BOOL)dimCovers
{
	[self setDimInactiveCovers:dimCovers animated:NO];
}

- (void)setDimInactiveCovers:(BOOL)dimCovers animated:(BOOL)animated
{
	_dimInactiveCovers = dimCovers;
	[self updateCoverViewCells:animated];
}

- (void)setCurrentIndexAnimated:(NSIndexPath *)indexPath
{
	if (!indexPath) {
		indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	}
	
	
	if (0 != [indexPath compare:_currentIndex]) {
		[self scrollToCoverAtIndexPath:indexPath];
	}
}

#pragma mark -
#pragma mark RZCoverView (Private)

- (CGSize)coverSize
{
	return _coverSize;
}

- (void)setCoverSize:(CGSize)coverSize
{
	_coverSize = coverSize;
}

- (CGSize)calculateCoverSize
{
	return CGSizeMake([self calculateCoverWidth], [self calculateCoverHeight]);
}

- (CGFloat)calculateCoverWidth
{
	CGFloat width = self.bounds.size.width * 0.5;
	
	if ([self.coverViewDelegate respondsToSelector:@selector(coverView:widthForCoverAtIndexPath:)]) {
		width = [self.coverViewDelegate coverView:self widthForCoverAtIndexPath:nil];
	}
	
	return width;
}

- (CGFloat)calculateCoverHeight
{
	CGFloat vertPadding = self.contentInset.top + self.contentInset.bottom;
	
	return self.bounds.size.height - vertPadding;
}

- (CGSize)scrollingContentSize
{
	CGFloat width = (self.coverSize.width + _margin) * [self.dataSource coverView:self numberOfCoversInSection:0] - _margin;
	
	return CGSizeMake(width, self.coverSize.height); //(self.bounds.size.height - self.contentInset.top - self.contentInset.bottom)); 
}

- (CGPoint)contentOffsetForCoverAtIndexPath:(NSIndexPath*)indexPath
{
	return CGPointMake((self.coverSize.width + _margin) * indexPath.row, 0);
}

- (NSArray*)visibleIndecies
{
	NSMutableArray* indecies = [NSMutableArray array];
	
	//TODO calculate visible Indecies
	
	return indecies;
}

- (NSInteger)determineCurrentIndex
{
	return [self getIndexForPosition:self.contentOffset.x];
}

- (NSInteger)getIndexForPosition:(CGFloat)xPosition
{
	NSInteger covers = [self.dataSource coverView:self numberOfCoversInSection:0];
	
	NSInteger index = round(((xPosition + self.contentInset.left + 0.5) / (self.coverSize.width + _margin)) );
	
	if (index < 0) {
		index = 0;
	} else if (index >= covers) {
		index = covers - 1;
	}
	
	return index;
}

- (void)advanceLeft
{
	NSLog(@"Advance Left");
	NSInteger index = self.currentIndex.row;
	[self scrollToCoverAtIndexPath:[NSIndexPath indexPathForRow:((index > 0)? index - 1 : 0) inSection:0]];
}

- (void)advanceRight
{
	NSLog(@"Advance Right");
	NSInteger index = self.currentIndex.row;
	NSInteger rows = [self.dataSource coverView:self numberOfCoversInSection:0];
	[self scrollToCoverAtIndexPath:[NSIndexPath indexPathForRow:((index < rows - 1)? index + 1 : rows - 1) inSection:0]];
}

- (void)updateCoverViewCells:(BOOL)animated
{
	[self updateCoverViewCells:animated withDuration:kDefaultGrowAnimationDuration];
}

- (void)updateCoverViewCells:(BOOL)animated withDuration:(double)duration
{
	if (animated)
	{
		[UIView beginAnimations:@"ShrinkGrow" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:duration];
	} 
	
	for (UIView* cover in [self subviews]) 
	{
//		NSLog(@"Cover Tag: %d", [cover tag]);
		
		CGPoint center = cover.center;
		
		if ([cover tag] == self.currentIndex.row) {
			cover.transform = CGAffineTransformIdentity;
			cover.alpha = 1.0;
			
			if (RZCoverViewStyleShelf == _style || RZCoverViewStyleShelfReflected == _style) {
				center.y = [self coverSize].height / 2.0;
			}
			
			[self bringSubviewToFront:cover];
		} else {
			cover.transform = CGAffineTransformScale(CGAffineTransformIdentity, kSmallScaleFactor, kSmallScaleFactor);
			cover.alpha = _dimInactiveCovers ? 0.5 : 1.0;
			
			if (RZCoverViewStyleShelf == _style || RZCoverViewStyleShelfReflected == _style) {
				center.y = [self coverSize].height - (cover.frame.size.height / 2.0);
			}
		}
		
		cover.center = center;
	}
	
	if (animated)
	{
		[UIView commitAnimations];
	} 
	
}

- (BOOL)updateIndex
{
	NSInteger currIndex = [self determineCurrentIndex];
	if (self.currentIndex.row != currIndex) {
//		NSLog(@"CurrIndex: %d DeterminedIndex: %d", self.currentIndex.row, currIndex);
		self.currentIndex = [NSIndexPath indexPathForRow:currIndex inSection:0];
		return YES;
	}
	return NO;
}

- (BOOL)shouldSnapToCoverAtIndexPath:(NSIndexPath*)indexPath scrollView:(UIScrollView*)scrollView velocity:(double)velocity
{
	double speed = fabs(velocity);
	double upperLimit = [self contentOffsetForCoverAtIndexPath:[NSIndexPath indexPathForRow:([self.dataSource coverView:self numberOfCoversInSection:0] - 1) inSection:0]].x;
	
	CGFloat currXPos = scrollView.contentOffset.x + scrollView.contentInset.left;
	
	if (scrollView.decelerating && speed < 15.0 && currXPos <= upperLimit && currXPos >= 0)	//Is coasting and slowing down and is not past the ends
	{
		double currIndexPos = [self contentOffsetForCoverAtIndexPath:indexPath].x;
		double proximity = currXPos - currIndexPos;
		double proxVelCorrelation = proximity * velocity;
		double absProximity = fabs(proximity);
		double outerLimit = self.coverSize.width;
		double innerLimit = (speed * 6.0);
		
//		NSLog(@"CurrIdxPos: %f CurrXPos: %f proximity: %f proxVelCorrelation: %f velocity: %f upperLimit: %f", currIndexPos, currXPos, proximity, proxVelCorrelation, velocity, upperLimit);
	
		return ((proxVelCorrelation > 0 && (absProximity < outerLimit && absProximity > innerLimit)) ||		//Has travelled past the center position AND it is in between the inner and outer limits
				(speed < 3.0 && proxVelCorrelation <= 0 && absProximity < outerLimit) ||					//Is going quite slow AND approaching the center position AND is inside the outer limit
				(speed < 1.0));																				//Is going very slow
	}
	
	return NO;
}

+ (CGRect)scaleRect:(CGRect)rect toFitInsideFrame:(CGRect)frame
{
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    CGFloat maxWidth = frame.size.width;
    CGFloat maxHeight = frame.size.height;
    
    CGFloat widthScale = maxWidth/width;
    
    CGFloat scaledWidth = maxWidth;
    CGFloat scaledHeight = height * widthScale;
    
    if (scaledHeight > maxHeight)
    {
        CGFloat heightScale = maxHeight/height;
        
        scaledHeight = maxHeight;
        scaledWidth = width * heightScale;
        
    }
    
    return CGRectMake(floor(fabs(maxWidth - scaledWidth) / 2.0), floor(fabs(maxHeight - scaledHeight) / 2.0), scaledWidth, scaledHeight);
}

#pragma mark RZCoverViewCell Actions
- (IBAction)coverTouched:(RZCoverViewCell*)coverViewCell
{
	if (self.pulseCoversOnTouch)
	{
		[self popCoverUp:coverViewCell];
	}
}

- (IBAction)coverTouchedCancelled:(RZCoverViewCell*)coverViewCell
{
	if (self.pulseCoversOnTouch)
	{
		[self popCoverDown:coverViewCell];
	}
}

- (IBAction)coverTapped:(RZCoverViewCell*)coverViewCell
{
	CGFloat currentX = self.contentOffset.x + self.contentInset.left;
	CGFloat x = coverViewCell.center.x - ([self coverSize].width / 2.0);
	
	if (x < 0) {
		x = 0;
	}
	
//	NSLog(@"RZCoverViewCell: %f Current: %f", x, currentX);
	
	if (fabs(x - currentX) > 5.0)
	{
		[self scrollToCoverViewCell:coverViewCell];
	}
	else
	{
		if (self.pulseCoversOnTouch)
		{
			[self popCover:coverViewCell];
		}
		
		if (_coverViewDelegate && [_coverViewDelegate respondsToSelector:@selector(coverView:didSelectCoverAtIndexPath:)]) {
			[_coverViewDelegate coverView:self didSelectCoverAtIndexPath:self.currentIndex];
		}
	}
}

#pragma mark RZCoverViewCell Animations
- (void)popCoverUp:(RZCoverViewCell*)coverViewCell
{
	
	[UIView beginAnimations:@"PulseUp" context:coverViewCell];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.125];
	[UIView setAnimationDelegate:self];
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	
	if (coverViewCell != [self cellForCoverAtIndexPath:self.currentIndex])
	{
		transform = CGAffineTransformScale(transform, kSmallScaleFactor, kSmallScaleFactor);
	}
	
	coverViewCell.transform = CGAffineTransformScale(transform, 1.05, 1.05);
	
	[UIView commitAnimations];
}

- (void)popCoverDown:(RZCoverViewCell*)coverViewCell
{
	[UIView beginAnimations:@"PulseDown" context:coverViewCell];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.125];
	[UIView setAnimationDelegate:self];
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	
	if (coverViewCell != [self cellForCoverAtIndexPath:self.currentIndex])
	{
		transform = CGAffineTransformScale(transform, kSmallScaleFactor, kSmallScaleFactor);
	}
	
	coverViewCell.transform = transform;
	
	[UIView commitAnimations];
}

- (void)popCover:(RZCoverViewCell *)coverViewCell
{
	[UIView beginAnimations:@"PulseCover" context:coverViewCell];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.125];
	[UIView setAnimationDelegate:self];
	
	//Must change transform a little so it will trigger animation - CHACK!
	coverViewCell.transform = CGAffineTransformScale(coverViewCell.transform, 1.001, 1.001);
	
	[UIView commitAnimations];
}


#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
	//NSLog(@"DidScroll");
	
	static int mod = 0;
	
	++mod;
	
	if (!_reloadingData)
	{
		
		double duration = kDefaultGrowAnimationDuration;
		
		BOOL indexUpdated = [self updateIndex];
		
		if (scrollView.dragging || scrollView.decelerating) {
			
			CGFloat currXPos = scrollView.contentOffset.x;
			
			if (mod % 3 == 0)
			{
				
				NSDate* now = [NSDate date];				
				
				NSTimeInterval delta_time = [now timeIntervalSinceDate:_lastUpdate];
				CGFloat delta_pos = currXPos - _lastXPos;
				
				double velocity = (delta_pos / delta_time) / 100.0;
				double speed = fabs(velocity);
				
//				NSLog(@"Delta Time: %f Delta Pos: %f Velocity: %f", delta_time, delta_pos, velocity);
				
				if (speed > 600.0 || delta_time < 0.005)
				{
					//Bad data, GTFO
					duration = 0.05 + (((kDefaultGrowAnimationDuration - 0.05) * 10.0) / (fabs(_lastVelocity) / 2.0));
				}
				else
				{
					if ([self shouldSnapToCoverAtIndexPath:self.currentIndex scrollView:scrollView velocity:velocity])
					{
						[self scrollToCoverAtIndexPath:self.currentIndex];
					}
					
					[_lastUpdate release];
					_lastUpdate = [now retain];
					_lastXPos = currXPos;
					_lastVelocity = velocity;
				}
				
			}
			else
			{
				if ([self shouldSnapToCoverAtIndexPath:self.currentIndex scrollView:scrollView velocity:_lastVelocity])
				{
					[self scrollToCoverAtIndexPath:self.currentIndex];
				}
			}
		}
		else {
//			NSLog(@"Auto Scrolling");
		}
		 
		
		if (indexUpdated) {
//			NSLog(@"Animate Index Change! Duration: %f", duration);
			[self updateCoverViewCells:YES withDuration:duration];
		}
		
	}
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	_scrollingToIndex = [NSNumber numberWithBool:YES];
	
	if (!scrollView.decelerating)
	{
		_lastXPos = scrollView.contentOffset.x;
		[_lastUpdate release];
		_lastUpdate = [[NSDate date] retain];
		_lastVelocity = 0.0;
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	_scrollingToIndex = nil;
	
//	NSLog(@"DidEndDragging: %d speed: %f", decelerate, speed);
	if (!decelerate) {
//		NSLog(@"EndDragging ScrollToCover");
		[self scrollToCoverAtIndexPath:self.currentIndex];
	}

}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
//	NSLog(@"Begin Decel");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{	
//	NSLog(@"DidEndDecelerating: %f", scrollView.decelerationRate);
	
	[self scrollToCoverAtIndexPath:self.currentIndex];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	
//	NSLog(@"DidEndScrollingAnimation");
	
	[self scrollToCoverAtIndexPath:self.currentIndex];
	_scrollingToIndex = nil;
}


#pragma mark -
#pragma mark UIViewAnimationDelegate

- (void)animationDidStop:(NSString*)animation finished:(BOOL)finished context:(void *)context
{
	
	if ([animation isEqualToString:@"PulseCover"]) {
		RZCoverViewCell* coverViewCell = (RZCoverViewCell*)context;
		
		[UIView beginAnimations:@"PulseDown" context:coverViewCell];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.125];
		[UIView setAnimationDelegate:self];
		
		coverViewCell.transform = CGAffineTransformIdentity;
		
		[UIView commitAnimations];
	}
	
}

#pragma mark -
#pragma mark KVO delegate methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"currentIndex"] && [object isEqual:self]) {
		if ([_coverViewDelegate respondsToSelector:@selector(coverView:activeCoverChangedToCoverAtIndexPath:)]) {
			[_coverViewDelegate performSelector:@selector(coverView:activeCoverChangedToCoverAtIndexPath:) withObject:self withObject:[change objectForKey:NSKeyValueChangeNewKey]];
		}
	}
}

@end

//Reflection Code from Apple's example code 
#pragma mark -
@implementation RZCoverView (ImageReflections)
- (UIImage *)reflectedImage:(UIImageView *)fromImage withHeight:(NSUInteger)height
{
    if(height == 0)
        return nil;
    
    // create a bitmap graphics context the size of the image
    CGContextRef mainViewContentContext = MyCreateBitmapContext(fromImage.bounds.size.width, height);
    
    // create a 2 bit CGImage containing a gradient that will be used for masking the 
    // main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
    // function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
    CGImageRef gradientMaskImage = CreateGradientImage(1, height * kDefaultReflectionFraction);
    
    // create an image by masking the bitmap of the mainView content with the gradient view
    // then release the  pre-masked content bitmap and the gradient bitmap
    CGContextClipToMask(mainViewContentContext, CGRectMake(0.0, height - (height * kDefaultReflectionFraction), fromImage.bounds.size.width, height * kDefaultReflectionFraction), gradientMaskImage);
    CGImageRelease(gradientMaskImage);
    
    // In order to grab the part of the image that we want to render, we move the context origin to the
    // height of the image that we want to capture, then we flip the context so that the image draws upside down.
    CGContextTranslateCTM(mainViewContentContext, 0.0, height);
    CGContextScaleCTM(mainViewContentContext, 1.0, -1.0);
    
    // draw the image into the bitmap context
    CGContextDrawImage(mainViewContentContext, fromImage.bounds, fromImage.image.CGImage);
    
    // create CGImageRef of the main view bitmap content, and then release that bitmap context
    CGImageRef reflectionImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    // convert the finished reflection image to a UIImage 
    UIImage *theImage = [UIImage imageWithCGImage:reflectionImage];
    
    // image is retained by the property setting above, so we can release the original
    CGImageRelease(reflectionImage);
    
    return theImage;
}

CGImageRef CreateGradientImage(int pixelsWide, int pixelsHigh)
{
    CGImageRef theCGImage = NULL;
	
    // gradient is always black-white and the mask must be in the gray colorspace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // create the bitmap context
    CGContextRef gradientBitmapContext = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh,
                                                               8, 0, colorSpace, kCGImageAlphaNone);
    
    // define the start and end grayscale values (with the alpha, even though
    // our bitmap context doesn't support alpha the gradient requires it)
    CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
    
    // create the CGGradient and then release the gray color space
    CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
    CGColorSpaceRelease(colorSpace);
    
    // create the start and end points for the gradient vector (straight down)
    CGPoint gradientStartPoint = CGPointZero;
    CGPoint gradientEndPoint = CGPointMake(0, pixelsHigh);
    
    // draw the gradient into the gray bitmap context
    CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
                                gradientEndPoint, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(grayScaleGradient);
    
    // convert the context into a CGImageRef and release the context
    theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
    CGContextRelease(gradientBitmapContext);
    
    // return the imageref containing the gradient
    return theCGImage;
}

CGContextRef MyCreateBitmapContext(int pixelsWide, int pixelsHigh)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create the bitmap context
    CGContextRef bitmapContext = CGBitmapContextCreate (NULL, pixelsWide, pixelsHigh, 8,
                                                        0, colorSpace,
                                                        // this will give us an optimal BGRA format for the device:
                                                        (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
    CGColorSpaceRelease(colorSpace);
	
    return bitmapContext;
}

@end

