//
//  RZMapView.m
//
//  Created by Joe Goullaud on 12/19/11.
//  Copyright (c) 2011 Raizlabs. All rights reserved.
//

#import "RZMapView.h"

@interface RZMapView ()

@property (retain, nonatomic) UIImageView *mapImageView;
@property (retain, nonatomic) NSMutableSet *mapRegionViews;
@property (retain, nonatomic) UITapGestureRecognizer *doubleTapZoomGestureRecognizer;
@property (assign, nonatomic) id<RZMapViewDelegate> mapDelegate;

- (void)doubleTapZoomTriggered:(UITapGestureRecognizer*)gestureRecognizer;
- (void)regionTapped:(UITapGestureRecognizer*)gestureRecognizer;

@end

@implementation RZMapView

@synthesize mapImage = _mapImage;

@synthesize mapImageView = _mapImageView;
@synthesize mapRegionViews = _mapRegionViews;
@synthesize doubleTapZoomGestureRecognizer = _doubleTapZoomGestureRecognizer;
@synthesize mapDelegate = _mapDelegate;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        self.mapRegionViews = [NSMutableSet set];
        
        UITapGestureRecognizer *doubleTapZoomGR = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapZoomTriggered:)] autorelease];
        doubleTapZoomGR.numberOfTapsRequired = 2;
        doubleTapZoomGR.numberOfTouchesRequired = 1;
        doubleTapZoomGR.cancelsTouchesInView = NO;
        [self addGestureRecognizer:doubleTapZoomGR];
        self.doubleTapZoomGestureRecognizer = doubleTapZoomGR;
        
        [super setDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [_mapImage release];
    
    [_mapImageView release];
    [_mapRegionViews release];
    
    [_doubleTapZoomGestureRecognizer release];
    
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)layoutSubviews
{
    CGSize containmentSize = self.bounds.size;
    CGSize mapImageSize = self.mapImage.size;
    
    CGFloat containerRatio = containmentSize.width / containmentSize.height;
    CGFloat mapRatio = mapImageSize.width / mapImageSize.height;
    
    NSLog(@"Ratios - Container: %f Map: %f", containerRatio, mapRatio);
    
    if (containerRatio > 1.0 && mapRatio > 1.0)
    {
        if (mapRatio > containerRatio)
        {
            //vert padding
            CGFloat scaleFactor = containmentSize.width / mapImageSize.width;
            CGFloat vertPadding = (((mapImageSize.width / containerRatio) - mapImageSize.height) * scaleFactor) / 2.0;
            self.contentInset = UIEdgeInsetsMake(vertPadding, 0, vertPadding, 0);
            self.minimumZoomScale = scaleFactor;
        }
        else
        {
            //horiz padding
            CGFloat scaleFactor = containmentSize.height / mapImageSize.height;
            CGFloat horizPadding = (((mapImageSize.height * containerRatio) - mapImageSize.width) * scaleFactor) / 2.0;
            self.contentInset = UIEdgeInsetsMake(0, horizPadding, 0, horizPadding);
            self.minimumZoomScale = scaleFactor;
        }
    }
    else if (containerRatio < 1.0 && mapRatio < 1.0)
    {
        if (mapRatio < containerRatio)
        {
            //vert padding
            CGFloat scaleFactor = containmentSize.width / mapImageSize.width;
            CGFloat vertPadding = (((mapImageSize.width / containerRatio) - mapImageSize.height) * scaleFactor) / 2.0;
            self.contentInset = UIEdgeInsetsMake(vertPadding, 0, vertPadding, 0);
            self.minimumZoomScale = scaleFactor;
        }
        else
        {
            //horiz padding
            CGFloat scaleFactor = containmentSize.height / mapImageSize.height;
            CGFloat horizPadding = (((mapImageSize.height * containerRatio) - mapImageSize.width) * scaleFactor) / 2.0;
            self.contentInset = UIEdgeInsetsMake(0, horizPadding, 0, horizPadding);
            self.minimumZoomScale = scaleFactor;
        }
    }
    else if (mapRatio > containerRatio)
    {
        //vert padding
        CGFloat scaleFactor = containmentSize.width / mapImageSize.width;
        CGFloat vertPadding = (((mapImageSize.width / containerRatio) - mapImageSize.height) * scaleFactor) / 2.0;
        self.contentInset = UIEdgeInsetsMake(vertPadding, 0, vertPadding, 0);
        self.minimumZoomScale = scaleFactor;
    }
    else
    {
        //horiz padding
        CGFloat scaleFactor = containmentSize.height / mapImageSize.height;
        CGFloat horizPadding = (((mapImageSize.height * containerRatio) - mapImageSize.width) * scaleFactor) / 2.0;
        self.contentInset = UIEdgeInsetsMake(0, horizPadding, 0, horizPadding);
        self.minimumZoomScale = scaleFactor;
    }
}

- (NSSet*)mapRegions
{
    return self.mapRegionViews;
}

- (void)setDelegate:(id<RZMapViewDelegate>)delegate
{
    if ([delegate isEqual:self])
    {
        [super setDelegate:delegate];
    }
    else
    {
        self.mapDelegate = delegate;
    }
}

- (void)setMapImage:(UIImage *)mapImage
{
    if (mapImage == _mapImage)
    {
        return;
    }
    
    [_mapImage release];
    _mapImage = [mapImage retain];
    
    
    
    [self.mapImageView removeFromSuperview];
    self.mapImageView = [[[UIImageView alloc] initWithImage:_mapImage] autorelease];
    self.mapImageView.userInteractionEnabled = YES;
    self.contentSize = self.mapImage.size;
    [self addSubview:self.mapImageView];
    
    [self.mapRegionViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (UIView *view in self.mapRegionViews)
    {
        [self addSubview:view];
    }
    
    NSLog(@"Image Attrs - ImageScale: %f ImageViewContentScale: %f ScrollViewContentScale: %f", _mapImage.scale, self.mapImageView.contentScaleFactor, self.contentScaleFactor);
    
    CGSize containmentSize = self.bounds.size;
    CGSize mapImageSize = self.mapImage.size;
    
    CGFloat containerRatio = containmentSize.width / containmentSize.height;
    CGFloat mapRatio = mapImageSize.width / mapImageSize.height;
    
    NSLog(@"Ratios - Container: %f Map: %f", containerRatio, mapRatio);
    
    if (containerRatio > 1.0 && mapRatio > 1.0)
    {
        if (mapRatio > containerRatio)
        {
            //vert padding
            CGFloat scaleFactor = containmentSize.width / mapImageSize.width;
            CGFloat vertPadding = (((mapImageSize.width / containerRatio) - mapImageSize.height) * scaleFactor) / 2.0;
            self.contentInset = UIEdgeInsetsMake(vertPadding, 0, vertPadding, 0);
            self.minimumZoomScale = scaleFactor;
        }
        else
        {
            //horiz padding
            CGFloat scaleFactor = containmentSize.height / mapImageSize.height;
            CGFloat horizPadding = (((mapImageSize.height * containerRatio) - mapImageSize.width) * scaleFactor) / 2.0;
            self.contentInset = UIEdgeInsetsMake(0, horizPadding, 0, horizPadding);
            self.minimumZoomScale = scaleFactor;
        }
    }
    else if (containerRatio < 1.0 && mapRatio < 1.0)
    {
        if (mapRatio < containerRatio)
        {
            //vert padding
            CGFloat scaleFactor = containmentSize.width / mapImageSize.width;
            CGFloat vertPadding = (((mapImageSize.width / containerRatio) - mapImageSize.height) * scaleFactor) / 2.0;
            self.contentInset = UIEdgeInsetsMake(vertPadding, 0, vertPadding, 0);
            self.minimumZoomScale = scaleFactor;
        }
        else
        {
            //horiz padding
            CGFloat scaleFactor = containmentSize.height / mapImageSize.height;
            CGFloat horizPadding = (((mapImageSize.height * containerRatio) - mapImageSize.width) * scaleFactor) / 2.0;
            self.contentInset = UIEdgeInsetsMake(0, horizPadding, 0, horizPadding);
            self.minimumZoomScale = scaleFactor;
        }
    }
    else if (mapRatio > containerRatio)
    {
        //vert padding
        CGFloat scaleFactor = containmentSize.width / mapImageSize.width;
        CGFloat vertPadding = (((mapImageSize.width / containerRatio) - mapImageSize.height) * scaleFactor) / 2.0;
        self.contentInset = UIEdgeInsetsMake(vertPadding, 0, vertPadding, 0);
        self.minimumZoomScale = scaleFactor;
    }
    else
    {
        //horiz padding
        CGFloat scaleFactor = containmentSize.height / mapImageSize.height;
        CGFloat horizPadding = (((mapImageSize.height * containerRatio) - mapImageSize.width) * scaleFactor) / 2.0;
        self.contentInset = UIEdgeInsetsMake(0, horizPadding, 0, horizPadding);
        self.minimumZoomScale = scaleFactor;
    }
    
    self.zoomScale = self.minimumZoomScale;
    self.maximumZoomScale = self.mapImage.scale / [[UIScreen mainScreen] scale];
}

- (void)addMapRegions:(NSSet*)objects
{
    for (RZMapViewLocation *region in objects)
    {
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(regionTapped:)];
        tapGR.numberOfTapsRequired = 1;
        tapGR.numberOfTouchesRequired = 1;
        tapGR.cancelsTouchesInView = NO;
        [tapGR requireGestureRecognizerToFail:self.doubleTapZoomGestureRecognizer];
        [region addGestureRecognizer:tapGR];
        [tapGR release];
        [self.mapImageView addSubview:region];
    }
    
    [self.mapRegionViews unionSet:objects];
}

- (void)addMapRegion:(RZMapViewLocation*)region
{
    [self addMapRegions:[NSSet setWithObject:region]];
}

- (void)removeMapRegions:(NSSet*)objects
{
    [objects makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self.mapRegionViews minusSet:objects];
}

- (void)removeMapRegion:(RZMapViewLocation*)region
{
    [self removeMapRegions:[NSSet setWithObject:region]];
}


#pragma mark = UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.mapDelegate respondsToSelector:@selector(scrollViewDidScroll:)])
    {
        [self.mapDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if ([self.mapDelegate respondsToSelector:@selector(scrollViewDidZoom:)])
    {
        [self.mapDelegate scrollViewDidZoom:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.mapDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
    {
        [self.mapDelegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([self.mapDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)])
    {
        [self.mapDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.mapDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
    {
        [self.mapDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([self.mapDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)])
    {
        [self.mapDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.mapDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
    {
        [self.mapDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([self.mapDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)])
    {
        [self.mapDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.mapImageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    if ([self.mapDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)])
    {
        [self.mapDelegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    if ([self.mapDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)])
    {
        [self.mapDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if ([self.mapDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)])
    {
        return [self.mapDelegate scrollViewShouldScrollToTop:scrollView];
    }
    
    return NO;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    if ([self.mapDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)])
    {
        [self.mapDelegate scrollViewDidScrollToTop:scrollView];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (void)doubleTapZoomTriggered:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.doubleTapZoomGestureRecognizer)
    {
        float newZoomScale = (self.zoomScale == self.maximumZoomScale) ? self.minimumZoomScale : self.maximumZoomScale;
        CGRect newRect = CGRectMake([gestureRecognizer locationInView:self.mapImageView].x - (self.bounds.size.width / newZoomScale/ 2.0), 
                                    [gestureRecognizer locationInView:self.mapImageView].y - (self.bounds.size.height / newZoomScale / 2.0),
                                    self.bounds.size.width / newZoomScale,
                                    self.bounds.size.height / newZoomScale);
        [self zoomToRect:newRect animated:YES];
    }
}

- (void)regionTapped:(UITapGestureRecognizer*)gestureRecognizer
{
    if ([gestureRecognizer.view.backgroundColor isEqual:[UIColor yellowColor]])
    {
        gestureRecognizer.view.backgroundColor = [UIColor clearColor];
        gestureRecognizer.view.alpha = 1.0;
    }
    else
    {
        gestureRecognizer.view.backgroundColor = [UIColor yellowColor];
        gestureRecognizer.view.alpha = 0.5;
    }
    
    if ([self.mapDelegate respondsToSelector:@selector(mapView:regionTapped:)])
    {
        [self.mapDelegate mapView:self regionTapped:(RZMapViewLocation*)gestureRecognizer.view];
    }
}

@end
