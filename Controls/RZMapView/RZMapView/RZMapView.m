//
//  RZMapView.m
//
//  Created by Joe Goullaud on 12/19/11.
//  Copyright (c) 2011 Raizlabs. All rights reserved.
//

#import "RZMapView.h"
#import <QuartzCore/QuartzCore.h>

#define kBounceHeight   30
#define kBounceSeconds 0.25f

@interface RZMapView ()

@property (retain, nonatomic) UIImageView *mapImageView;
@property (retain, nonatomic) NSMutableSet *mapRegionViews;
@property (retain, nonatomic) NSMutableSet *mapPinViews;
@property (retain, nonatomic) UITapGestureRecognizer *doubleTapZoomGestureRecognizer;
@property (retain, nonatomic) UITapGestureRecognizer *idleTapGestureRecognizer;
@property (assign, nonatomic) id<RZMapViewDelegate> mapDelegate;

- (void)doubleTapZoomTriggered:(UITapGestureRecognizer*)gestureRecognizer;
- (void)idleTapTriggered:(UITapGestureRecognizer*)gestureRecognizer;
- (void)regionTapped:(UITapGestureRecognizer*)gestureRecognizer;
- (void)pinTapped:(UITapGestureRecognizer*)gestureRecognizer;

@end

@implementation RZMapView

@synthesize mapImage = _mapImage;
@synthesize activePin = _activePin;
@synthesize pinAddAnimationSimultaneous = _pinAddAnimationSimultaneous;

@synthesize mapImageView = _mapImageView;
@synthesize mapRegionViews = _mapRegionViews;
@synthesize mapPinViews = _mapPinViews;
@synthesize doubleTapZoomGestureRecognizer = _doubleTapZoomGestureRecognizer;
@synthesize idleTapGestureRecognizer = _idleTapGestureRecognizer;
@synthesize mapDelegate = _mapDelegate;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        self.mapRegionViews = [NSMutableSet set];
        self.mapPinViews = [NSMutableSet set];
        
        UITapGestureRecognizer *doubleTapZoomGR = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapZoomTriggered:)] autorelease];
        doubleTapZoomGR.numberOfTapsRequired = 2;
        doubleTapZoomGR.numberOfTouchesRequired = 1;
        doubleTapZoomGR.cancelsTouchesInView = NO;
        [self addGestureRecognizer:doubleTapZoomGR];
        self.doubleTapZoomGestureRecognizer = doubleTapZoomGR;
        
        UITapGestureRecognizer *tapToDismissPinGR = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(idleTapTriggered:)] autorelease];
        tapToDismissPinGR.numberOfTapsRequired = 1;
        tapToDismissPinGR.numberOfTouchesRequired = 1;
        tapToDismissPinGR.cancelsTouchesInView = NO;
        tapToDismissPinGR.delegate = self;
        [tapToDismissPinGR requireGestureRecognizerToFail:doubleTapZoomGR];
        [self addGestureRecognizer:tapToDismissPinGR];
        self.idleTapGestureRecognizer = tapToDismissPinGR;
        
        [super setDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [_mapImage release];
    [_activePin release];
    
    [_mapImageView release];
    [_mapRegionViews release];
    [_mapPinViews release];
    
    [_doubleTapZoomGestureRecognizer release];
    [_idleTapGestureRecognizer release];
    
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

- (NSSet*)mapPins
{
    return self.mapPinViews;
}

- (id<RZMapViewDelegate>)delegate
{
    return self.mapDelegate;
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
    
    // hold on to the old zoom scale so we can reset it after the image is swapped out. 
    float oldZoomScale = self.zoomScale;
    CGPoint oldOffset = self.contentOffset;
    
    // set the zoom scale to 1 so everything is positioned correctly.
    self.zoomScale = 1.0;
    
    [self.mapImageView removeFromSuperview];
    self.mapImageView = [[[UIImageView alloc] initWithImage:_mapImage] autorelease];
    self.mapImageView.userInteractionEnabled = YES;
    self.contentSize = self.mapImage.size;
    [self addSubview:self.mapImageView];
    
    // Re-add the regions to the new image
    [self.mapRegionViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (UIView *view in self.mapRegionViews)
    {
        [self.mapImageView addSubview:view];
    }
    
    // re-add the pins to the new image
    [self.mapPinViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (UIView *view in self.mapPinViews)
    {
        [self.mapImageView addSubview:view];
    }
    
    NSLog(@"Image Attrs - ImageScale: %f ImageViewContentScale: %f ScrollViewContentScale: %f", _mapImage.scale, self.mapImageView.contentScaleFactor, self.contentScaleFactor);
    
    CGSize containmentSize = self.bounds.size;
    CGSize mapImageSize = self.mapImage.size;
    
    CGFloat containerRatio = containmentSize.width / containmentSize.height;
    CGFloat mapRatio = mapImageSize.width / mapImageSize.height;
    
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
    
    self.zoomScale = oldZoomScale;
    self.contentOffset = oldOffset;
    
    self.maximumZoomScale = 1.0;
}

- (void)setActivePin:(RZMapViewPin *)activePin
{
    [self setActivePin:activePin animated:YES];
}

- (void)setActivePin:(RZMapViewPin *)activePin animated:(BOOL)animated
{
    if (activePin != _activePin)
    {
        if (nil != activePin && 
            self.mapDelegate && 
            [self.mapDelegate respondsToSelector:@selector(mapView:popoverViewForPin:)])
        {
            UIView *popoverView = [self.mapDelegate mapView:self popoverViewForPin:activePin];
            if (popoverView)
            {
                activePin.popoverView = popoverView;
            }
        }
        
        [_activePin setActive:NO animated:animated];
        [activePin setActive:YES animated:animated];
        [_activePin release];
        _activePin = [activePin retain];
        
        [self.mapImageView bringSubviewToFront:_activePin];
    }
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

- (void)addMapPins:(NSSet*)objects
{
    [self addMapPins:objects animated:NO];
}

- (void)addMapPins:(NSSet*)objects animated:(BOOL)animated
{
    
    // TODO - Add animations for adding pins
    
    
    CGFloat scale = 1.0/self.zoomScale;
	CGAffineTransform scaleTransform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    
    NSUInteger addCount = [objects count];
    double delay = 0.0;
    
    for (RZMapViewPin *pin in objects)
    {
        pin.delegate = self;
        [self.mapImageView addSubview:pin];
        pin.center = pin.location.center;
        pin.transform = scaleTransform;
        
        
        
        if (animated)
        {
            //figure out the final pin placement
            CGPoint pinCenterFinish = pin.location.center;
            
            if (CGPointEqualToPoint(pinCenterFinish, CGPointZero)) {
                pinCenterFinish = self.center;
            }
            
            //position the pin at the top (just offscreen)
            //CGPoint pinCenterStart = CGPointMake(pinCenterFinish.x, 0);
            CGPoint pinCenterStart = CGPointMake(pinCenterFinish.x, (self.contentOffset.y * scale) - pin.frame.size.height);	//note, just offscreen be height of the pin button
            
            // create the path for the keyframe animation
            CGMutablePathRef thePath = CGPathCreateMutable();
            CGPathMoveToPoint(thePath,NULL,pinCenterStart.x,pinCenterStart.y);
            CGPathAddLineToPoint(thePath, NULL, pinCenterFinish.x, pinCenterFinish.y);
            CGPathAddCurveToPoint(thePath,NULL,
                                  pinCenterFinish.x,pinCenterFinish.y,
                                  pinCenterFinish.x,pinCenterFinish.y - (kBounceHeight * scale),
                                  pinCenterFinish.x,pinCenterFinish.y);
            CGPathAddCurveToPoint(thePath,NULL,
                                  pinCenterFinish.x,pinCenterFinish.y,
                                  pinCenterFinish.x,pinCenterFinish.y - (kBounceHeight * scale * 0.5),
                                  pinCenterFinish.x,pinCenterFinish.y);
            CGPathAddCurveToPoint(thePath,NULL,
                                  pinCenterFinish.x,pinCenterFinish.y,
                                  pinCenterFinish.x,pinCenterFinish.y - (kBounceHeight * scale * 0.25),
                                  pinCenterFinish.x,pinCenterFinish.y);
            
            CAKeyframeAnimation *theAnimation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
            theAnimation.path=thePath;
            
            CAAnimationGroup *theGroup = [CAAnimationGroup animation];
            theGroup.animations=[NSArray arrayWithObject:theAnimation];
            
            // set the timing function for the group and the animation duration
            theGroup.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            
            if (!self.pinAddAnimationSimultaneous && addCount > 1)
            {
                theGroup.duration = 1.8;
                theGroup.beginTime = CACurrentMediaTime()+delay;
                pin.hidden = YES;
            }
            else
            {
                theGroup.duration=2.0;
            }
            theGroup.delegate = self;
            [theGroup setValue:pin forKey:@"RZMapViewPinAnimationKey"];
            // release the path
            CFRelease(thePath);
            
            // add animation to pin layer to trigger animation
            [pin.layer addAnimation:theGroup forKey:@"animatePosition"];
            
            delay += 0.2 / (double)addCount;
        }
    }
    
    [self.mapPinViews unionSet:objects];
}

- (void)addMapPin:(RZMapViewPin*)pin
{
    [self addMapPins:[NSSet setWithObject:pin] animated:NO];
}

- (void)addMapPin:(RZMapViewPin*)pin animated:(BOOL)animated
{
    [self addMapPins:[NSSet setWithObject:pin] animated:animated];
}

- (void)removeMapPins:(NSSet*)objects
{
    [objects makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self.mapPinViews minusSet:objects];
}

- (void)removeMapPin:(RZMapViewPin*)pin
{
    [self removeMapPins:[NSSet setWithObject:pin]];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim
{
    RZMapViewPin *pin = [anim valueForKey:@"RZMapViewPinAnimationKey"];
    pin.hidden = NO;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag)
    {
        RZMapViewPin *pin = [anim valueForKey:@"RZMapViewPinAnimationKey"];
        
        if (pin && self.delegate && [self.delegate respondsToSelector:@selector(mapView:pinAddAnimationDidFinish:)])
        {
            [self.delegate mapView:self pinAddAnimationDidFinish:pin];
        }
    }
}

#pragma mark - RZMapViewPinDelegate

- (void)pinViewTapped:(RZMapViewPin*)pin
{
    if (pin == self.activePin)
    {
        self.activePin = nil;
    }
    else
    {
        self.activePin = pin;
    }
    
    if ([self.mapDelegate respondsToSelector:@selector(mapView:pinTapped:)])
    {
        [self.mapDelegate mapView:self pinTapped:pin];
    }
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
    CGFloat scale = 1.0/ (double)scrollView.zoomScale;
	CGAffineTransform scaleTransform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    
    for (RZMapViewPin *pin in self.mapPinViews)
    {
        CGAffineTransform currentTransform = pin.transform;
        
        pin.transform = CGAffineTransformMake(scaleTransform.a, scaleTransform.b, scaleTransform.c, scaleTransform.d, currentTransform.tx, currentTransform.ty);
        [pin setNeedsLayout];
    }
    
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == self.idleTapGestureRecognizer)
    {
        if (self.activePin && self.activePin.popoverView.superview)
        {
            UIView *popoverView = self.activePin.popoverView;
            CGRect popoverRect = popoverView.frame;
            CGPoint touchInPopover = [touch locationInView:self.activePin];
            BOOL isInPopoverView = CGRectContainsPoint(popoverRect, touchInPopover);
            return !isInPopoverView;
        }
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == self.idleTapGestureRecognizer)
    {
        return NO;
    }
    
    return YES;
}


#pragma mark - UIGestureRecognizer Callbacks
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

- (void)idleTapTriggered:(UITapGestureRecognizer*)gestureRecognizer
{
    [self setActivePin:nil animated:YES];
}

- (void)regionTapped:(UITapGestureRecognizer*)gestureRecognizer
{
    if ([self.mapDelegate respondsToSelector:@selector(mapView:regionTapped:)])
    {
        [self.mapDelegate mapView:self regionTapped:(RZMapViewLocation*)gestureRecognizer.view];
    }
}

@end
