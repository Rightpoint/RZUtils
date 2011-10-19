//
//  RZGridViewCell.m
//  RZGridView
//
//  Created by Joe Goullaud on 10/3/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "RZGridViewCell.h"


@interface RZGridViewCell ()

@property (assign, nonatomic) RZGridViewCellStyle style;
@property (copy, readwrite, nonatomic) NSString *reuseIdentifier;

@property (retain, readwrite, nonatomic) UIImageView *imageView;
@property (retain, readwrite, nonatomic) UIView *contentView;

@end

@implementation RZGridViewCell

@synthesize style = _style;
@synthesize reuseIdentifier = _reuseIdentifier;

@synthesize imageView = _imageView;
@synthesize contentView = _contentView;

- (id)initWithStyle:(RZGridViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithFrame:CGRectZero]))
    {
        self.style = style;
        self.reuseIdentifier = reuseIdentifier;
        
        self.contentMode = UIViewContentModeScaleAspectFit;
        
        self.contentView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.contentView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:self.contentView];
        
        self.imageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.imageView];
        
    }
    
    return self;
}

- (void)dealloc
{
    [_reuseIdentifier release];
    
    [_imageView release];
    [_contentView release];
    
    [super dealloc];
}

@end
