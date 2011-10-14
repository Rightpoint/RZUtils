//
//  RZGridView.m
//  RZGridView
//
//  Created by Joe Goullaud on 10/3/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "RZGridView.h"


@interface RZGridView ()

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) NSMutableArray *sectionRanges;
@property (nonatomic, retain) NSMutableArray *rowRangesBySection;

@property (nonatomic, assign) NSUInteger totalItems;
@property (nonatomic, assign) NSUInteger totalRows;
@property (nonatomic, assign) NSUInteger totalSections;

@property (nonatomic, assign) CGPoint reorderTouchOffset;
@property (nonatomic, retain) NSIndexPath *selectedLastPath;
@property (nonatomic, retain) NSIndexPath *selectedStartPath;

@property (assign, getter = isScrolling) BOOL scrolling;

- (void)loadData;
- (void)configureScrollView;

- (void)tileCells;
- (void)tileCellsAnimated:(BOOL)animated;

- (void)handleCellPress:(UILongPressGestureRecognizer*)gestureRecognizer;
- (void)moveItemAtIndexPath:(NSIndexPath*)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath;

- (NSUInteger)indexForIndexPath:(NSIndexPath*)indexPath;
- (NSRange)rangeForSection:(NSUInteger)section;
- (NSRange)rangeForRow:(NSUInteger)row inSection:(NSUInteger)section;

- (void)updateSelectedCellIndex;
- (void)scrollIfNeededUsingDelta:(CGPoint)delta;

@end

@implementation RZGridView

@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize rowHeight = _rowHeight;

@synthesize visibileCells = _visibleCells;
@synthesize selectedCell = _selectedCell;

@synthesize scrollView = _scrollView;
@synthesize sectionRanges = _sectionRanges;
@synthesize rowRangesBySection = _rowRangesBySection;

@synthesize totalItems = _totalItems;
@synthesize totalRows = _totalRows;
@synthesize totalSections = _totalSections;

@synthesize reorderTouchOffset = _reorderTouchOffset;
@synthesize selectedLastPath = _selectedLastPath;
@synthesize selectedStartPath = _selectedStartPath;

@synthesize scrolling = _scrolling;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.rowHeight = 200.0;
        self.totalSections = 1;
        self.totalRows = 0;
        self.totalItems = 0;
        self.scrolling = NO;
        
        self.scrollView = [[[UIScrollView alloc] initWithFrame:self.bounds] autorelease];
        self.scrollView.multipleTouchEnabled = NO;
        self.scrollView.delegate = self;
        //self.scrollView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        
        [self loadData];
        [self configureScrollView];
        [self tileCells];
        
        [self addSubview:self.scrollView];
    }
    return self;
}


- (void)dealloc
{
    [_visibleCells release];
    [_selectedCell release];
    
    [_scrollView release];
    [_sectionRanges release];
    [_rowRangesBySection release];
    
    [_selectedLastPath release];
    [_selectedStartPath release];
    
    [super dealloc];
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//    [self tileCells];
//}

- (void)setDataSource:(id<RZGridViewDataSource>)dataSource
{
    if (dataSource == _dataSource)
    {
        return;
    }
    
    _dataSource = dataSource;
    
    [self reloadData];
}

- (void)reloadData
{
    [self loadData];
    [self configureScrollView];
    [self tileCells];

}

- (NSInteger)numberOfSections
{
    return self.totalSections;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return [[self.rowRangesBySection objectAtIndex:section] count];
}

- (CGRect)rectForSection:(NSInteger)section
{
    CGFloat yOffset = 0;
    
    for (int sectionIndex = 0; sectionIndex < section; ++sectionIndex)
    {
        yOffset += [self rectForHeaderInSection:sectionIndex].size.height;
        yOffset += [self.dataSource gridView:self numberOfRowsInSection:sectionIndex] * self.rowHeight;
        yOffset += [self rectForFooterInSection:sectionIndex].size.height;
    }
    
    CGFloat height = 0;
    
    height += [self rectForHeaderInSection:section].size.height;
    height += [self.dataSource gridView:self numberOfRowsInSection:section] * self.rowHeight;
    height += [self rectForFooterInSection:section].size.height;
    
    return CGRectMake(0, yOffset, self.scrollView.contentSize.width, height);
}

- (CGRect)rectForHeaderInSection:(NSInteger)section
{
    return CGRectZero;
}

- (CGRect)rectForFooterInSection:(NSInteger)section
{
    return CGRectZero;
}

- (CGRect)rectForRow:(NSInteger)row inSection:(NSInteger)section
{
    CGRect sectionRect = [self rectForSection:section];
    CGRect headerRect = [self rectForHeaderInSection:section];
    
    CGRect rowRect = CGRectMake(sectionRect.origin.x, sectionRect.origin.y + headerRect.size.height + (row * self.rowHeight), sectionRect.size.width, self.rowHeight);
    
    return rowRect;
}

- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect rowRect = [self rectForRow:indexPath.gridRow inSection:indexPath.gridSection];
    
    NSInteger columnsInCurrentRow = [self.dataSource gridView:self numberOfColumnsInRow:indexPath.gridRow inSection:indexPath.gridSection];
    
    CGFloat columnWidth = rowRect.size.width / (CGFloat)columnsInCurrentRow;
    
    CGRect itemRect = CGRectMake((CGFloat)indexPath.gridColumn * columnWidth, rowRect.origin.y, columnWidth, rowRect.size.height);
    
    return itemRect;
}

- (NSIndexPath*)indexPathForItemAtPoint:(CGPoint)point
{
    // Bin Search Sections
    NSInteger min = 0;
    NSInteger max = self.totalSections - 1;
    NSInteger section = -1;
    BOOL pointInSection = NO;
    do {
        section = (min + max) / 2;
        
        CGRect sectionRect = [self rectForSection:section];
        
        if (CGRectContainsPoint(sectionRect, point))
        {
            pointInSection = YES;
            break;
        }
        
        if (point.y > CGRectGetMinY(sectionRect))
        {
            min = section + 1;
        }
        else
        {
            max = section - 1;
        }
        
    } while (min <= max);
    
    if (!pointInSection)
    {
        return nil;
    }
    
    // Bin Search Rows
    min = 0;
    max = [self numberOfRowsInSection:section] - 1;
    NSInteger row = -1;
    BOOL pointInRow = NO;
    do {
        row = (min + max) / 2;
        
        CGRect rowRect = [self rectForRow:row inSection:section];
        
        if (CGRectContainsPoint(rowRect, point))
        {
            pointInRow = YES;
            break;
        }
        
        if (point.y > CGRectGetMinY(rowRect))
        {
            min = row + 1;
        }
        else
        {
            max = row - 1;
        }
        
    } while (min <= max);
    
    if (!pointInRow)
    {
        return nil;
    }
    
    // Find Col
    min = 0;
    max = [self.dataSource gridView:self numberOfColumnsInRow:row inSection:section] - 1;
    NSInteger col = -1;
    do {
        col = (min + max) / 2;
        NSIndexPath *itemIndexPath = [NSIndexPath indexPathForColumn:col andRow:row inSection:section];
        
        CGRect itemRect = [self rectForItemAtIndexPath:itemIndexPath];
        
        if (CGRectContainsPoint(itemRect, point))
        {
            return itemIndexPath;
        }
        
        if (point.x > CGRectGetMaxX(itemRect))
        {
            min = col + 1;
        }
        else
        {
            max = col - 1;
        }
        
    } while (min <= max);
    
    return nil;
}

- (NSIndexPath*)indexPathForCell:(RZGridViewCell*)cell
{
    NSUInteger index = [self.visibileCells indexOfObject:cell];
    
    NSInteger section = -1;
    
    for (int sectionIndex = 0; sectionIndex < [self.sectionRanges count]; ++sectionIndex)
    {
        NSValue *value = [self.sectionRanges objectAtIndex:sectionIndex];
        NSRange sectionRange = [value rangeValue];
        if (NSLocationInRange(index, sectionRange))
        {
            section = sectionIndex;
            break;
        }
    }
    
    if (section < 0 || section >= [self.rowRangesBySection count])
    {
        return nil;
    }
    
    NSArray *sectionRowRanges = [self.rowRangesBySection objectAtIndex:section];
    
    for (int row = 0; row < [sectionRowRanges count]; ++row)
    {
        NSValue *value = [sectionRowRanges objectAtIndex:row];
        NSRange rowRange = [value rangeValue];
        if (NSLocationInRange(index, rowRange))
        {
            NSInteger column = index - rowRange.location;
            
            return [NSIndexPath indexPathForColumn:column andRow:row inSection:section];
        }
    }
    
    return nil;
}

- (void)loadData
{
    NSInteger totalItems = 0;
    NSInteger totalRows = 0;
    NSInteger numSections = 1;
    
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInGridView:)])
    {
        numSections = [self.dataSource numberOfSectionsInGridView:self];
    }
    
    self.visibileCells = [NSMutableArray array];
    self.sectionRanges = [NSMutableArray arrayWithCapacity:numSections];
    self.rowRangesBySection = [NSMutableArray arrayWithCapacity:numSections];
    
    for (NSInteger section = 0; section < numSections; ++section)
    {
        NSInteger sectionOffset = totalItems;
        NSInteger itemsInSection = 0;
        NSInteger numRows = [self.dataSource gridView:self numberOfRowsInSection:section];
        totalRows += numRows;
        
        [self.rowRangesBySection addObject:[NSMutableArray arrayWithCapacity:numRows]];
        
        for (NSInteger row = 0; row < numRows; ++row)
        {
            NSInteger rowOffset = totalItems;
            NSInteger itemsInRow = 0;
            NSInteger numColumns = [self.dataSource gridView:self numberOfColumnsInRow:row inSection:section];
            
            for (NSInteger column = 0; column < numColumns; ++column)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForColumn:column andRow:row inSection:section];
                
                RZGridViewCell *cell = [self.dataSource gridView:self cellForItemAtIndexPath:indexPath];
                
                if (cell)
                {
                    cell.indexPath = indexPath;
                    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleCellPress:)];
                    longPress.minimumPressDuration = 0.5;
                    longPress.delegate = self;
                    [cell addGestureRecognizer:longPress];
                    [longPress release];
                    
                    cell.userInteractionEnabled = YES;
                    
                    [self.visibileCells addObject:cell];
                    ++itemsInRow;
                    ++itemsInSection;
                    ++totalItems;
                }
                else
                {
                    break;
                }
            }
            
            [[self.rowRangesBySection objectAtIndex:section] addObject:[NSValue valueWithRange:NSMakeRange(rowOffset, itemsInRow)]];
        }
        
        [self.sectionRanges addObject:[NSValue valueWithRange:NSMakeRange(sectionOffset, itemsInSection)]];
    }
    
    self.totalItems = totalItems;
    self.totalRows = totalRows;
    self.totalSections = numSections;
}

- (void)configureScrollView
{
    CGSize contentSize = CGSizeMake(self.bounds.size.width, self.totalRows * self.rowHeight);
    
    self.scrollView.contentSize = contentSize;
}

- (void)tileCellsAnimated:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.25 
                              delay:0 
                            options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionAllowUserInteraction)
                         animations:^(void) {
                             [self tileCells];
                         } 
                         completion:^(BOOL finished) {
                             
                         }
         ];
    }
    else
    {
        [self tileCells];
    }
}

- (void)tileCells
{
    for (RZGridViewCell *cell in self.visibileCells)
    {
        if (cell != self.selectedCell)
        {
            NSIndexPath *cellPath = [self indexPathForCell:cell];
            
            CGRect cellFrame = [self rectForItemAtIndexPath:cellPath];
            
            cell.frame = cellFrame;
        }
        [self.scrollView addSubview:cell];
    }
    
    [self.scrollView bringSubviewToFront:self.selectedCell];
    
    [self setNeedsDisplay];
}

- (void)handleCellPress:(UILongPressGestureRecognizer*)gestureRecognizer
{
    NSIndexPath *currentIndexPath = nil;
    CGPoint oldCenter;
    
    switch ([gestureRecognizer state]) {
        case UIGestureRecognizerStateBegan:
            self.selectedCell = (RZGridViewCell*)gestureRecognizer.view;
            self.selectedStartPath = [self indexPathForCell:(RZGridViewCell *)gestureRecognizer.view];
            self.selectedLastPath = self.selectedStartPath;
            self.reorderTouchOffset = CGPointMake(gestureRecognizer.view.center.x - [gestureRecognizer locationInView:self.scrollView].x, 
                                                  gestureRecognizer.view.center.y - [gestureRecognizer locationInView:self.scrollView].y);
            [self.scrollView bringSubviewToFront:gestureRecognizer.view];
            [UIView animateWithDuration:0.2 animations:^(void) {
                gestureRecognizer.view.transform = CGAffineTransformMakeScale(1.25, 1.25);
                gestureRecognizer.view.alpha = 0.75;
            }];
            break;
            
        case UIGestureRecognizerStateChanged:
            oldCenter = self.selectedCell.center;
            
            self.selectedCell.center = CGPointApplyAffineTransform([gestureRecognizer locationInView:self.scrollView], CGAffineTransformMakeTranslation(self.reorderTouchOffset.x, self.reorderTouchOffset.y));
            
            CGPoint delta = CGPointMake(self.selectedCell.center.x - oldCenter.x, self.selectedCell.center.y - oldCenter.y);
            
            [self updateSelectedCellIndex];
            
            [self scrollIfNeededUsingDelta:delta];
            
            break;
        
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            
            currentIndexPath = [self indexPathForItemAtPoint:self.selectedCell.center];
            
            if (!currentIndexPath)
            {
                currentIndexPath = self.selectedLastPath;
            }
            
            CGRect endRect = [self rectForItemAtIndexPath:currentIndexPath];
            
            [UIView animateWithDuration:0.2 animations:^(void) {
                gestureRecognizer.view.center = CGPointMake(CGRectGetMidX(endRect), CGRectGetMidY(endRect));
                
                gestureRecognizer.view.transform = CGAffineTransformIdentity;
                gestureRecognizer.view.alpha = 1.0;
            }];
            
            if ([self.dataSource respondsToSelector:@selector(gridView:moveItemAtIndexPath:toIndexPath:)])
            {
                [self.dataSource gridView:self moveItemAtIndexPath:self.selectedStartPath toIndexPath:currentIndexPath];
            }
            
            self.selectedCell = nil;
            self.selectedStartPath = nil;
            self.selectedLastPath = nil;
            break;
            
        default:
            break;
    }
}

- (void)moveItemAtIndexPath:(NSIndexPath*)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath
{
    NSUInteger sourceIndex = [self indexForIndexPath:sourceIndexPath];
    NSUInteger destinationIndex = [self indexForIndexPath:destinationIndexPath];
    NSUInteger length = llabs((long long)destinationIndex - (long long)sourceIndex);
    
    NSRange movingRange = NSMakeRange(0, 0);
    NSUInteger insertIndex = NSUIntegerMax;
    NSMutableArray *reorderedCells = nil;
    
    if (sourceIndex < destinationIndex) {
        movingRange = NSMakeRange(sourceIndex+1, length);
        insertIndex = sourceIndex;
        
        reorderedCells = [NSMutableArray arrayWithArray:[self.visibileCells subarrayWithRange:movingRange]];
        [reorderedCells addObject:[self.visibileCells objectAtIndex:sourceIndex]];
    }
    else
    {
        movingRange = NSMakeRange(destinationIndex, length);
        insertIndex = destinationIndex;
        
        reorderedCells = [NSMutableArray arrayWithArray:[self.visibileCells subarrayWithRange:movingRange]];
        [reorderedCells insertObject:[self.visibileCells objectAtIndex:sourceIndex] atIndex:0];
    }
    
    NSRange replacementRange = NSMakeRange(insertIndex, length + 1);
    
    [self.visibileCells replaceObjectsInRange:replacementRange withObjectsFromArray:reorderedCells];
    
    [self tileCellsAnimated:YES];
}

- (NSUInteger)indexForIndexPath:(NSIndexPath*)indexPath
{
    NSInteger offset = NSUIntegerMax;
    
    NSRange rowRange = [self rangeForRow:indexPath.gridRow inSection:indexPath.gridSection];
    
    if (rowRange.length > 0)
    {
        offset = rowRange.location + indexPath.gridColumn;
    }
    
    return offset;
}

- (NSRange)rangeForSection:(NSUInteger)section
{
    if (section < self.totalSections)
    {
        NSValue *sectionValue = [self.sectionRanges objectAtIndex:section];
        
        if (sectionValue)
        {
            return [sectionValue rangeValue];
        }
    }
    
    return NSMakeRange(0, 0);
}

- (NSRange)rangeForRow:(NSUInteger)row inSection:(NSUInteger)section
{
    if (section < self.totalSections && row < [self numberOfRowsInSection:section])
    {
        NSArray *rowRanges = [self.rowRangesBySection objectAtIndex:section];
        
        if (rowRanges)
        {
            NSValue *rowValue = [rowRanges objectAtIndex:row];
            
            if (rowValue)
            {
                return [rowValue rangeValue];
            }
        }
    }
    
    return NSMakeRange(0, 0);
}

- (void)updateSelectedCellIndex
{
    NSIndexPath *currentIndexPath = [self indexPathForItemAtPoint:self.selectedCell.center];
    //            NSLog(@"Gesture X:%f Y:%f", self.selectedCell.center.x, self.selectedCell.center.y);
    //            NSLog(@"Index Path for Gesture View's Center: %@", currentIndexPath);
    //            NSLog(@"Last Index Path: %@", self.selectedLastPath);
    
    if (currentIndexPath && ![self.selectedLastPath isEqual:currentIndexPath])
    {
        [self moveItemAtIndexPath:self.selectedLastPath toIndexPath:currentIndexPath];
        self.selectedLastPath = currentIndexPath;
    }
}

- (void)scrollIfNeededUsingDelta:(CGPoint)delta
{
    @synchronized(self)
    {
        if (!self.scrolling && self.selectedCell)
        {
            CGPoint locationInBounds = [self.selectedCell.superview convertPoint:self.selectedCell.center toView:self];
            CGFloat xMinBoundry = self.selectedCell.bounds.size.width / 2.0;
            CGFloat xMaxBounrdy = self.bounds.size.width - xMinBoundry;
            CGFloat yMinBoundry = self.selectedCell.bounds.size.height / 2.0;
            CGFloat yMaxBoundry = self.bounds.size.height - yMinBoundry;
            
            CGFloat xOffset = 0.0;
            CGFloat yOffset = 0.0;
            CGFloat speed = 100.0;
            
            if (locationInBounds.x < xMinBoundry && delta.x < 1.0)
            {
                xOffset = -speed * (1.0 - locationInBounds.x/self.bounds.size.width);
            }
            else if (locationInBounds.x > xMaxBounrdy && delta.x > -1.0)
            {
                xOffset = speed * (locationInBounds.x/self.bounds.size.width);
            }
            
            if (locationInBounds.y < yMinBoundry && delta.y < 1.0)
            {
                yOffset = -speed * (1.0 - locationInBounds.y/self.bounds.size.height);
            }
            else if (locationInBounds.y > yMaxBoundry && delta.y > -1.0)
            {
                yOffset = speed * (locationInBounds.y/self.bounds.size.height);
            }
            
            CGPoint scrollOffset = self.scrollView.contentOffset;
            CGFloat maxX = self.scrollView.contentSize.width - self.scrollView.bounds.size.width;
            CGFloat maxY = self.scrollView.contentSize.height - self.scrollView.bounds.size.height;
            
            if (scrollOffset.x + xOffset < 0.0)
            {
                xOffset = 0.0 - scrollOffset.x;
            }
            else if (scrollOffset.x + xOffset > maxX)
            {
                xOffset = maxX - scrollOffset.x;
            }
            
            if (scrollOffset.y + yOffset < 0.0)
            {
                yOffset = 0.0 - scrollOffset.y;
            }
            else if (scrollOffset.y + yOffset > maxY)
            {
                yOffset = maxY - scrollOffset.y;
            }
            
            if (fabs(xOffset) > 1.0 || fabs(yOffset) > 1.0)
            {
                self.scrolling = YES;
                [UIView animateWithDuration:0.1
                                      delay:0
                                    options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction |
                                        UIViewAnimationOptionAllowAnimatedContent) 
                                 animations:^{
                                     CGPoint offset = self.scrollView.contentOffset;
                                     offset.x += xOffset;
                                     offset.y += yOffset;
                                     [self.scrollView setContentOffset:offset animated:NO];
                                     
                                     CGPoint cellCenter = self.selectedCell.center;
                                     cellCenter.x += xOffset;
                                     cellCenter.y += yOffset;
                                     self.selectedCell.center = cellCenter;
                                     
                                     [self updateSelectedCellIndex];
                                 } 
                                 completion:^(BOOL finished) {
                                     self.scrolling = NO;
                                     [self scrollIfNeededUsingDelta:CGPointMake(xOffset, yOffset)];
                                 }
                 ];
            }
        }
    }
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

#pragma mark - UIGestureRecognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    @synchronized(self)
    {
        if (self.selectedCell == nil)
        {
            self.selectedCell = (RZGridViewCell*)gestureRecognizer.view;
            return YES;
        }
        
        return NO;
    }
}

@end


@implementation NSIndexPath (RZGridView)

+ (NSIndexPath *)indexPathForColumn:(NSUInteger)column andRow:(NSUInteger)row inSection:(NSUInteger)section
{
    NSUInteger indexes[3] = {section, row, column};
    
    return [NSIndexPath indexPathWithIndexes:indexes length:3];
}

- (NSUInteger)gridSection
{
    return [self indexAtPosition:0];
}

- (NSUInteger)gridRow
{
    return [self indexAtPosition:1];
}

- (NSUInteger)gridColumn
{
    return [self indexAtPosition:2];
}

@end