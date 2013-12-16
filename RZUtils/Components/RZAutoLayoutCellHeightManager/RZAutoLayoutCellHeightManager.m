//
//  RZAutoLayoutCellHeightManager.m
//  Raizlabs
//
//  Created by Alex Rouse on 12/11/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "RZAutoLayoutCellHeightManager.h"

#import "RZViewFactory.h"


/**
 * UICollectionViewCell (AutoLayout)
 *
 * Helper methods for a UICollectionViewCell
 **/

@interface UICollectionViewCell (AutoLayout)

- (void)moveConstraintsToContentView;

@end


@implementation UICollectionViewCell (AutoLayout)

// Taken from : http://stackoverflow.com/questions/18746929/using-auto-layout-in-uitableview-for-dynamic-cell-layouts-heights
// Note that there may be performance issues with this in some cases.  Should only call in on Awake from nib and not on reuse.
- (void)moveConstraintsToContentView
{
    for(NSLayoutConstraint *cellConstraint in self.constraints){
        [self removeConstraint:cellConstraint];
        id firstItem = cellConstraint.firstItem == self ? self.contentView : cellConstraint.firstItem;
        id seccondItem = cellConstraint.secondItem == self ? self.contentView : cellConstraint.secondItem;
        NSLayoutConstraint* contentViewConstraint =
        [NSLayoutConstraint constraintWithItem:firstItem
                                     attribute:cellConstraint.firstAttribute
                                     relatedBy:cellConstraint.relation
                                        toItem:seccondItem
                                     attribute:cellConstraint.secondAttribute
                                    multiplier:cellConstraint.multiplier
                                      constant:cellConstraint.constant];
        [self.contentView addConstraint:contentViewConstraint];
    }
}

@end


/**
 * RZAutoLayoutCellHeightManager
 **/

@interface RZAutoLayoutCellHeightManager ()
@property (nonatomic, strong) id offScreenCell;
@property (nonatomic, strong) NSString* cellClassName;
@property (nonatomic, strong) NSString* cellNibName;
@property (nonatomic, strong) NSCache* cellHeightCache;

@property (nonatomic, copy) RZAutoLayoutCellHeightManagerBlock configurationBlock;
@end

@implementation RZAutoLayoutCellHeightManager

- (id)initWithCellClassName:(NSString *)cellClass configurationBlock:(RZAutoLayoutCellHeightManagerBlock)configurationBlock
{
    return [self initWithCellClassName:cellClass cellNibName:cellClass configurationBlock:configurationBlock];
}
- (id)initWithCellClassName:(NSString *)cellClass cellNibName:(NSString *)cellNib configurationBlock:(RZAutoLayoutCellHeightManagerBlock)configurationBlock
{
    self = [super init];
    if (self)
    {
        self.configurationBlock = configurationBlock;
        self.cellClassName = cellClass;
        self.cellNibName = cellNib;
        self.cellHeightCache = [[NSCache alloc] init];
        [self configureOffScreenCell];
    }
    return self;
}


- (void)configureOffScreenCell
{
    if (self.cellNibName)
    {
        self.offScreenCell = [UIView rz_loadFromNibNamed:self.cellNibName];
        [self.offScreenCell moveConstraintsToContentView];
    }
    else
    {
        self.offScreenCell = [[NSClassFromString(self.cellClassName) alloc] init];
    }
}

#pragma mark - Public Methods

- (void)invalidateCellHeightCache
{
    [self.cellHeightCache removeAllObjects];
}

- (void)invalidateCellHeightAtIndexPath:(NSIndexPath *)indexPath
{
    [self.cellHeightCache removeObjectForKey:indexPath];
}

- (void)invalidateCellHeightsAtIndexPaths:(NSArray *)indexPaths
{
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath* obj, NSUInteger idx, BOOL *stop) {
        [self.cellHeightCache removeObjectForKey:obj];
    }];
}

- (CGFloat)cellHeightForObject:(id)object indexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [[self.cellHeightCache objectForKey:indexPath] floatValue];
    if (height == 0)
    {
        if (self.configurationBlock)
        {
            self.configurationBlock(self.offScreenCell, object);
        }
        UIView* contentView = [self.offScreenCell contentView];
//        [contentView setNeedsLayout];
//        [contentView layoutIfNeeded];
        height = [contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        [self.cellHeightCache setObject:@(height) forKey:indexPath];
    }
    return height;
}

@end



