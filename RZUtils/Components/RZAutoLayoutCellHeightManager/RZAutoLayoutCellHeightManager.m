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

@property (nonatomic, copy) RZAutoLayoutCellHeightManagerConfigBlock configurationBlock;
@property (nonatomic, copy) RZAutoLayoutCellHeightManagerHeightBlock heightBlock;

@end

@implementation RZAutoLayoutCellHeightManager

- (instancetype)initWithCellClassName:(NSString *)cellClass configurationBlock:(RZAutoLayoutCellHeightManagerConfigBlock)configurationBlock
{
    return [self initWithCellClassName:cellClass cellNibName:cellClass configurationBlock:configurationBlock];
}
- (instancetype)initWithCellClassName:(NSString *)cellClass cellNibName:(NSString *)cellNib configurationBlock:(RZAutoLayoutCellHeightManagerConfigBlock)configurationBlock
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

- (instancetype)initWithCellClassName:(NSString *)cellClass heightBlock:(RZAutoLayoutCellHeightManagerHeightBlock)heightBlock
{
    return [self initWithCellClassName:cellClass cellNibName:cellClass heightBlock:heightBlock];
}

- (instancetype)initWithCellClassName:(NSString *)cellClass cellNibName:(NSString *)cellNib heightBlock:(RZAutoLayoutCellHeightManagerHeightBlock)heightBlock
{
    self = [super init];
    if (self)
    {
        self.heightBlock = heightBlock;
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
    NSNumber * height = [self.cellHeightCache objectForKey:indexPath];
    if (height == nil)
    {
        if (self.configurationBlock)
        {
            self.configurationBlock(self.offScreenCell, object);
            UIView* contentView = [self.offScreenCell contentView];
            height = @([contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
        }
        else if (self.heightBlock)
        {
            height = @(self.heightBlock(self.offScreenCell, object));
        }
        
        if (height)
        {
            [self.cellHeightCache setObject:height forKey:indexPath];
        }
    }
    return [height floatValue];
}

@end



