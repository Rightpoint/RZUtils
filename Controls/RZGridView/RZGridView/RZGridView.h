//
//  RZGridView.h
//  RZGridView
//
//  Created by Joe Goullaud on 10/3/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RZGridViewCell.h"

@protocol RZGridViewDelegate;
@protocol RZGridViewDataSource;

@interface RZGridView : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    @private
    id<RZGridViewDataSource> _dataSource;
    id<RZGridViewDelegate> _delegate;
    CGFloat _rowHeight;
    
    NSMutableArray *_visibleCells;
    
    UIScrollView *_scrollView;
    NSMutableArray *_sectionRanges;
    NSMutableArray *_rowRangesBySection;
    
    NSUInteger _totalItems;
    NSUInteger _totalRows;
    NSUInteger _totalSections;
}

@property (nonatomic, assign) id<RZGridViewDataSource> dataSource;
@property (nonatomic, assign) id<RZGridViewDelegate> delegate;
@property (nonatomic, assign) CGFloat rowHeight;

@property (nonatomic, retain) NSMutableArray *visibileCells;
@property (retain) RZGridViewCell *selectedCell;

- (void)reloadData;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

- (CGRect)rectForSection:(NSInteger)section;                                    // includes header, footer and all rows
- (CGRect)rectForHeaderInSection:(NSInteger)section;
- (CGRect)rectForFooterInSection:(NSInteger)section;
- (CGRect)rectForRow:(NSInteger)row inSection:(NSInteger)section;
- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath*)indexPathForItemAtPoint:(CGPoint)point;                         // Returns nil if outside grid view
- (NSIndexPath*)indexPathForCell:(RZGridViewCell*)cell;                         // Returns nil if cell is not visible

@end

// Grid View Data Source Protocol
@protocol RZGridViewDataSource <NSObject>

@required

- (NSInteger)gridView:(RZGridView*)gridView numberOfRowsInSection:(NSInteger)section;
- (NSInteger)gridView:(RZGridView*)gridView numberOfColumnsInRow:(NSInteger)row inSection:(NSInteger)section;

- (RZGridViewCell*)gridView:(RZGridView*)gridView cellForItemAtIndexPath:(NSIndexPath*)indexPath;

@optional

- (NSInteger)numberOfSectionsInGridView:(RZGridView*)gridView;                  // Default is 1 if not implemented

- (NSString *)gridView:(RZGridView*)gridView titleForHeaderInSection:(NSInteger)section;    
- (NSString *)gridView:(RZGridView*)gridView titleForFooterInSection:(NSInteger)section;

// Data manipulation - reorder / moving support

- (void)gridView:(RZGridView*)gridView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

@end


// Grid View Delegate Protocol
@protocol RZGridViewDelegate <NSObject>

@optional

- (void)gridView:(RZGridView*)gridView didSelectItemAtIndexPath:(NSIndexPath*)indexPath;

@end


// This category provides convenience methods to make it easier to use an NSIndexPath to represent a section, row, and column
@interface NSIndexPath (RZGridView)

+ (NSIndexPath *)indexPathForColumn:(NSUInteger)column andRow:(NSUInteger)row inSection:(NSUInteger)section;

@property(nonatomic,readonly) NSUInteger gridSection;
@property(nonatomic,readonly) NSUInteger gridRow;
@property(nonatomic,readonly) NSUInteger gridColumn;

@end