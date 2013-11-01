//
//  RZCollectionTableViewCellm
//
//  Created by Nick Donaldson on 9/13/13.
//  Copyright (c) 2013 RaizLabs. All rights reserved.
//

#import "RZCollectionTableViewCell.h"
#import "RZCollectionTableView.h"
#import "RZCollectionTableView_Private.h"

NSString * const RZCollectionTableViewCellEditingStateChanged = @"RZCollectionTableViewCellEditingStateChanged";
NSString * const RZCollectionTableViewCellEditingCommitted = @"RZCollectionTableViewCellEditingCommitted";

@interface RZCollectionTableViewCell ()

@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGesture;

- (void)configureGestures;
- (void)handleSwipeGesture:(UISwipeGestureRecognizer*)swipe;

@end

@implementation RZCollectionTableViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self configureGestures];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self configureGestures];
    }
    return self;
}

- (void)configureGestures
{
    self.swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    self.swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    self.swipeGesture.enabled = NO;
    [self.contentView addGestureRecognizer:self.swipeGesture];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self setTvcEditing:NO animated:NO];
}

- (void)setTvcEditingStyle:(RZCollectionTableViewCellEditingStyle)editingStyle
{
    _tvcEditingStyle = editingStyle;
    self.swipeGesture.enabled = (editingStyle == RZCollectionTableViewCellEditingStyleDelete);
}

- (void)setTvcEditing:(BOOL)editing
{
    [self setTvcEditing:editing animated:NO];
}

- (void)setTvcEditing:(BOOL)editing animated:(BOOL)animated
{
    _tvcEditing = editing;
    
    if (editing)
    {
        self.swipeGesture.enabled = NO;
    }
    else
    {
        self.swipeGesture.enabled = (self.tvcEditingStyle == RZCollectionTableViewCellEditingStyleDelete);
    }
    
    [self._rz_parentCollectionTableView _rz_editingStateChangedForCell:self];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    if ([layoutAttributes isKindOfClass:[RZCollectionTableViewCellAttributes class]])
    {
        RZCollectionTableViewCellAttributes *rzLayoutAttributes = (RZCollectionTableViewCellAttributes*)layoutAttributes;
        self.tvcEditingStyle = rzLayoutAttributes.editingStyle;
        self._rz_parentCollectionTableView = rzLayoutAttributes._rz_parentCollectionTableView;
    }
    else
    {
        self.tvcEditingStyle = RZCollectionTableViewCellEditingStyleNone;
        self._rz_parentCollectionTableView = nil;
    }
}

- (void)commitTvcEdits
{
    [self._rz_parentCollectionTableView _rz_editingCommittedForCell:self];
}

#pragma mark - Gesture handlers

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)swipe
{
    [self setTvcEditing:YES animated:YES];
}

@end
