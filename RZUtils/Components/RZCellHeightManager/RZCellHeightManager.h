//
//  RZCellHeightManager.h
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
