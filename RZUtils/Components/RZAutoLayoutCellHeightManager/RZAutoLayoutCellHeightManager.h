//
//  RZAutoLayoutCellHeightManager.h
//  Raizlabs
//
//  Created by Alex Rouse on 12/11/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RZAutoLayoutCellHeightManagerBlock)(id cell, id object);

/**
 *  This is currently only been tested/Created for A UICollectionViewCell that is created from a nib.
 *  There is no reason why we couldn't expand it to work with UITableViewCells and more.
 **/

@interface RZAutoLayoutCellHeightManager : NSObject


// Assumes that the cell comes from a nib and has the same name as the class
- (id)initWithCellClassName:(NSString *)cellClass configurationBlock:(RZAutoLayoutCellHeightManagerBlock)configurationBlock;

- (id)initWithCellClassName:(NSString *)cellClass cellNibName:(NSString *)cellNib configurationBlock:(RZAutoLayoutCellHeightManagerBlock)configurationBlock;

// Clears the cached heights.
- (void)invalidateCellHeightCache;
- (void)invalidateCellHeightAtIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateCellHeightsAtIndexPaths:(NSArray *)indexPaths;

// Returns the height for the cell given an object and an index.
- (CGFloat)cellHeightForObject:(id)object indexPath:(NSIndexPath *)indexPath;

@end
