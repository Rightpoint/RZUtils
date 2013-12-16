//
//  RZCellHeightManager.h
//  Raizlabs
//
//  Created by Alex Rouse on 12/11/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RZAutoLayoutCellHeightManagerConfigBlock)(id cell, id object);
typedef CGFloat (^RZAutoLayoutCellHeightManagerHeightBlock)(id cell, id object);

/**
 *  This is currently only been tested/Created for A UICollectionViewCell that is created from a nib.
 *  There is no reason why we couldn't expand it to work with UITableViewCells and more.
 **/

@interface RZCellHeightManager : NSObject


// Assumes that the cell comes from a nib and has the same name as the class
- (instancetype)initWithCellClassName:(NSString *)cellClass configurationBlock:(RZAutoLayoutCellHeightManagerConfigBlock)configurationBlock;
- (instancetype)initWithCellClassName:(NSString *)cellClass cellNibName:(NSString *)cellNib configurationBlock:(RZAutoLayoutCellHeightManagerConfigBlock)configurationBlock;

// This version still caches heights, but instead of autolayout uses the response from the provided block instead.
// Useful for when height is only dependent on one particular view and performance may be an issue.
- (instancetype)initWithCellClassName:(NSString *)cellClass heightBlock:(RZAutoLayoutCellHeightManagerHeightBlock)heightBlock;
- (instancetype)initWithCellClassName:(NSString *)cellClass cellNibName:(NSString *)cellNib heightBlock:(RZAutoLayoutCellHeightManagerHeightBlock)heightBlock;

// Clears the cached heights.
- (void)invalidateCellHeightCache;
- (void)invalidateCellHeightAtIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateCellHeightsAtIndexPaths:(NSArray *)indexPaths;

// Returns the height for the cell given an object and an index.
- (CGFloat)cellHeightForObject:(id)object indexPath:(NSIndexPath *)indexPath;

@end
