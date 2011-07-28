//
//  StarRatingSlider.m
//  BzzAgent
//
//  Created by Joe Goullaud on 7/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StarRatingSlider.h"

@interface StarRatingSlider ()

@property (nonatomic, retain) NSMutableArray *starImageViews;

@end

@implementation StarRatingSlider

@synthesize filledStarImage = _filledStarImage;
@synthesize emptyStarImage = _emptyStarImage;
@synthesize rating = _rating;
@synthesize maxStars = _maxStars;

@synthesize starImageViews = _starImageViews;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.rating = 1;
        self.maxStars = 5;
        
        self.starImageViews = [[[NSMutableArray alloc] init] autorelease];
    }
    return self;
}

- (void)dealloc
{
    [_filledStarImage release];
    [_emptyStarImage release];
    
    [_starImageViews release];
    
    [super dealloc];
}

- (void)setFilledStarImage:(UIImage *)filledStarImage
{
    if (filledStarImage != _filledStarImage)
    {
        [_filledStarImage release];
        _filledStarImage = [filledStarImage retain];
        
        [self setNeedsLayout];
    }
}

- (void)setEmptyStarImage:(UIImage *)emptyStarImage
{
    if (emptyStarImage != _emptyStarImage)
    {
        [_emptyStarImage release];
        _emptyStarImage = [emptyStarImage retain];
        
        [self setNeedsLayout];
    }
}

- (void)setRating:(NSInteger)rating
{
    if (rating < 1) {
        rating = 1;
    }
    
    if (rating > self.maxStars)
    {
        rating = self.maxStars;
    }
    
    if (rating != _rating)
    {
        _rating = rating;
        
        [self setNeedsLayout];
    }
}

- (void)setMaxStars:(NSInteger)maxStars
{
    if (maxStars > 0)
    {
        _maxStars = maxStars;
        
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    CGRect frame = self.bounds;
    CGRect starFrame = frame;
    starFrame.size.width /= (double)self.maxStars;
    
    for (int i = 0; i < self.maxStars; ++i)
    {
        UIImageView *imageView = nil;
        if (i < [self.starImageViews count])
        {
            imageView = [self.starImageViews objectAtIndex:i];
        }
        
        if (nil == imageView)
        {
            starFrame.origin.x = i * starFrame.size.width;
            imageView = [[[UIImageView alloc] initWithFrame:starFrame] autorelease];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.image = self.filledStarImage;
            [self addSubview:imageView];
            [self.starImageViews addObject:imageView];
        }
        
        if (i < self.rating)
        {
            //imageView.image = self.filledStarImage;
            
            if (imageView.image != self.filledStarImage)
            {
                [UIView transitionWithView:imageView duration:0.175 options:UIViewAnimationOptionTransitionFlipFromRight animations:^(void) {
                    imageView.image = self.filledStarImage;
                } completion:nil];
            }
        }
        else
        {
            //imageView.image = self.emptyStarImage;
            
            if (imageView.image != self.emptyStarImage)
            {
                [UIView transitionWithView:imageView duration:0.175 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^(void) {
                    imageView.image = self.emptyStarImage;
                } completion:nil];
            }
        }
        
    }
    
    NSLog(@"Break --- Current rating: %d", self.rating);
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    
    if (touch.phase == UITouchPhaseBegan)
    {
        CGPoint touchLoc = [touch locationInView:self];
        
        double percentAlongX = touchLoc.x / self.bounds.size.width;
        
        self.rating = ceil(self.maxStars * percentAlongX);
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    
    if (touch.phase == UITouchPhaseMoved)
    {
        CGPoint touchLoc = [touch locationInView:self];
        
        double percentAlongX = touchLoc.x / self.bounds.size.width;
        
        self.rating = ceil(self.maxStars * percentAlongX);
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
