//
//  RZCellHeightManager.m
//  Raizlabs
//
//  Created by Alex Rouse on 12/11/13.
// Copyright 2014 Raizlabs and other contributors
// http://raizlabs.com/
// 
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "RZCellHeightManager.h"

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
 * RZCellHeightManager
 **/

@interface RZCellHeightManager ()
@property (nonatomic, strong) id offScreenCell;
@property (nonatomic, strong) NSString* cellClassName;
@property (nonatomic, strong) NSString* cellNibName;
@property (nonatomic, strong) NSCache* cellHeightCache;

@property (nonatomic, copy) RZAutoLayoutCellHeightManagerConfigBlock configurationBlock;
@property (nonatomic, copy) RZAutoLayoutCellHeightManagerHeightBlock heightBlock;

@end

@implementation RZCellHeightManager

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



