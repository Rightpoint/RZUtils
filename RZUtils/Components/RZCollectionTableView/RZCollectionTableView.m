//
//  RZCollectionTableView.m
//
//  Created by Nick Donaldson on 9/13/13.

//  Copyright (c) 2013 RaizLabs. 
//

#import "RZCollectionTableView.h"
#import "RZCollectionTableView_Private.h"

#define RZCVTL_HEADER_ITEM 0
#define RZCVTL_FOOTER_ITEM 1

@interface RZCollectionTableView ()

@property (nonatomic, assign) BOOL inEditingConfirmationState;
    
@end

@implementation RZCollectionTableView

- (void)reloadData
{
    [super reloadData];
    self.panGestureRecognizer.enabled = YES;
}

#pragma mark - Editing State Management

- (void)_rz_editingStateChangedForCell:(RZCollectionTableViewCell *)cell
{
    if ( cell != nil && [self.visibleCells containsObject:cell] ) {
        if ( cell.rzEditing ) {
            [self enterConfirmationStateForCell:cell];
        }
    }
}

- (void)_rz_editingButtonPressed:(NSUInteger)buttonIdx forCell:(RZCollectionTableViewCell *)cell
{
    if ( cell != nil && [self.visibleCells containsObject:cell] ) {
        [self endConfirmationState];

        if ( [self.collectionViewLayout isKindOfClass:[RZCollectionTableViewLayout class]] ) {
            [(RZCollectionTableViewLayout *)self.collectionViewLayout _rz_editingButtonPressed:buttonIdx
                                                                             forRowAtIndexPath:[self indexPathForCell:cell]];
        }
    }
}

#pragma mark - Private

- (void)enterConfirmationStateForCell:(RZCollectionTableViewCell *)cell
{
    // Stop other cells from showing delete
    [self.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        if ( [obj isKindOfClass:[RZCollectionTableViewCell class]] && obj != cell ) {
            [(RZCollectionTableViewCell *)obj setRzEditing:NO animated:YES];
        }

    }];

    // disable pan gesture on collection view
    self.panGestureRecognizer.enabled = NO;
    self.inEditingConfirmationState   = YES;
}

- (void)endConfirmationState
{
    [self.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        if ( [obj isKindOfClass:[RZCollectionTableViewCell class]] ) {
            [(RZCollectionTableViewCell *)obj setRzEditing:NO animated:YES];
        }

    }];

    self.panGestureRecognizer.enabled = YES;
    self.inEditingConfirmationState   = NO;
}

#pragma mark - Touch swallowing

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( self.inEditingConfirmationState ) {
        // Any touch immediately kills the editing state
        // Designed to work just like a UITableView
        [self endConfirmationState];
    }
    else {
        [super touchesBegan:touches withEvent:event];
    }
}

@end

// -----------------


NSString *const RZCollectionTableViewLayoutHeaderView = @"RZCollectionTableViewLayoutHeaderView";
NSString *const RZCollectionTableViewLayoutFooterView = @"RZCollectionTableViewLayoutFooterView";

@interface RZCollectionTableViewLayout ()

// ===== Caches =====

// Computed value caches
@property (nonatomic, assign) CGSize              cachedContentSize;
@property (nonatomic, assign) CGRect              lastRequestedRect;
@property (nonatomic, strong) NSMutableDictionary *rowHeightCache;
@property (nonatomic, strong) NSMutableDictionary *sectionHeightCache;
@property (nonatomic, strong) NSMutableDictionary *headerHeightCache;
@property (nonatomic, strong) NSMutableDictionary *footerHeightCache;

// Attribute caches
@property (nonatomic, strong) NSArray             *lastAttributesForRect;
@property (nonatomic, strong) NSMutableDictionary *itemAttributesCache;
@property (nonatomic, strong) NSMutableDictionary *supplementaryAttributesCache; // key: type value: dictionary by index path


// ===== Helpers ======

@property (nonatomic, readonly) NSInteger                               totalRows;
@property (nonatomic, readonly) id<RZCollectionTableViewLayoutDelegate> layoutDelegate;

@end

@implementation RZCollectionTableViewLayout

+ (Class)layoutAttributesClass
{
    return [RZCollectionTableViewCellAttributes class];
}

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if ( self ) {
        _sectionInsets = UIEdgeInsetsZero;
        _rowSpacing    = 0.f;
        _rowHeight     = 44.f;
        [self clearCaches];
    }
    return self;
}

#pragma mark - Invalidation and Updates

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return !CGSizeEqualToSize(self.collectionView.bounds.size, newBounds.size);
}

- (void)invalidateLayout
{
    [super invalidateLayout];
    [self clearCaches];
}

- (void)prepareLayout
{
    [super prepareLayout];

    // Anything to do here? maybe not...
}

#pragma mark - Size and Attributes

- (CGSize)collectionViewContentSize
{
    CGSize contentSize = CGSizeMake(self.collectionView.bounds.size.width, 0);

    for ( NSInteger s = 0; s < [self.collectionView numberOfSections]; s++ ) {
        contentSize.height += [self heightForSection:s estimated:YES];
    }

    return contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributes = nil;
    if ( !CGRectEqualToRect(rect, self.lastRequestedRect) ) {
        self.lastRequestedRect = rect;

        BOOL           outOfBounds        = NO;
        NSMutableArray *newAttributes     = [NSMutableArray array];
        NSIndexPath    *firstRowIndexPath = [self indexPathOfFirstRowInRect:rect];
        if ( firstRowIndexPath != nil ) {
            NSInteger       startRowIndex = firstRowIndexPath.item;
            for ( NSInteger s             = firstRowIndexPath.section; s < [self.collectionView numberOfSections] && !outOfBounds; s++ ) {
                for ( NSInteger i = startRowIndex; i < [self.collectionView numberOfItemsInSection:s] && !outOfBounds; i++ ) {
                    RZCollectionTableViewCellAttributes *rowAttributes = (RZCollectionTableViewCellAttributes *)[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:s]];
                    outOfBounds = !CGRectIntersectsRect(rowAttributes.frame, rect);
                    if ( !outOfBounds ) {
                        [newAttributes addObject:rowAttributes];
                    }
                }
                startRowIndex     = 0;
            }
        }

        // --- Header/Footer views ----
        // Reverse-enumerate from first visible section to see if header/footer is visible.
        // Some sections may not have rows, but still have header/footer views
        if ( firstRowIndexPath != nil ) {
            outOfBounds = NO;
            for ( NSInteger s = firstRowIndexPath.section; s >= 0 && !outOfBounds; s-- ) {
                if ( CGRectIntersectsRect([self rectForSection:s estimated:YES], rect) ) {
                    // Header
                    BOOL   headerVisible = NO;
                    CGRect headerFrame   = [self rectForHeaderInSection:s estimated:YES];
                    if ( !CGRectEqualToRect(headerFrame, CGRectZero) ) {
                        if ( CGRectIntersectsRect(headerFrame, rect) ) {
                            headerVisible = YES;
                            [newAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:RZCollectionTableViewLayoutHeaderView
                                                                                          atIndexPath:[NSIndexPath indexPathForItem:RZCVTL_HEADER_ITEM inSection:s]]];
                        }
                    }

                    // Footer
                    BOOL   footerVisible = NO;
                    CGRect footerFrame   = [self rectForFooterInSection:s estimated:YES];
                    if ( !CGRectEqualToRect(footerFrame, CGRectZero) ) {
                        if ( CGRectIntersectsRect(footerFrame, rect) ) {
                            footerVisible = YES;
                            [newAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:RZCollectionTableViewLayoutFooterView
                                                                                          atIndexPath:[NSIndexPath indexPathForItem:RZCVTL_FOOTER_ITEM inSection:s]]];
                        }
                    }

                    outOfBounds = !( headerVisible || footerVisible );

                }
                else {
                    outOfBounds = YES;
                }
            }

            // Forward enumerate and do the same thing
            outOfBounds = NO;
            for ( NSInteger s = firstRowIndexPath.section + 1; s < [self.collectionView numberOfSections] && !outOfBounds; s++ ) {
                if ( CGRectIntersectsRect([self rectForSection:s estimated:YES], rect) ) {
                    // Header
                    BOOL   headerVisible = NO;
                    CGRect headerFrame   = [self rectForHeaderInSection:s estimated:YES];
                    if ( !CGRectEqualToRect(headerFrame, CGRectZero) ) {
                        if ( CGRectIntersectsRect(headerFrame, rect) ) {
                            headerVisible = YES;
                            [newAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:RZCollectionTableViewLayoutHeaderView
                                                                                          atIndexPath:[NSIndexPath indexPathForItem:RZCVTL_HEADER_ITEM inSection:s]]];
                        }
                    }

                    // Footer
                    BOOL   footerVisible = NO;
                    CGRect footerFrame   = [self rectForFooterInSection:s estimated:YES];
                    if ( !CGRectEqualToRect(footerFrame, CGRectZero) ) {
                        if ( CGRectIntersectsRect(footerFrame, rect) ) {
                            footerVisible = YES;
                            [newAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:RZCollectionTableViewLayoutFooterView
                                                                                          atIndexPath:[NSIndexPath indexPathForItem:RZCVTL_FOOTER_ITEM inSection:s]]];
                        }
                    }

                    outOfBounds = !( headerVisible || footerVisible );

                }
                else {
                    outOfBounds = YES;
                }
            }
        }

        self.lastAttributesForRect = newAttributes;
        attributes = newAttributes;
    }
    else {
        attributes = self.lastAttributesForRect;
    }

    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RZCollectionTableViewCellAttributes *rowAttributes = [self.itemAttributesCache objectForKey:indexPath];
    if ( rowAttributes == nil ) {
        rowAttributes = [RZCollectionTableViewCellAttributes layoutAttributesForCellWithIndexPath:indexPath];

        rowAttributes.frame = [self rectForRowAtIndexPath:indexPath];

        [self.itemAttributesCache setObject:rowAttributes forKey:indexPath];
    }

    // Update row position

    NSInteger rowsInSection = [self.collectionView numberOfItemsInSection:indexPath.section];

    if ( rowsInSection == 1 ) {
        rowAttributes.rowPosition = RZCollectionTableViewCellRowPositionSolo;
    }
    else if ( indexPath.row == 0 ) {
        rowAttributes.rowPosition = RZCollectionTableViewCellRowPositionTop;
    }
    else if ( indexPath.row == rowsInSection - 1 ) {
        rowAttributes.rowPosition = RZCollectionTableViewCellRowPositionBottom;
    }
    else {
        rowAttributes.rowPosition = RZCollectionTableViewCellRowPositionMiddle;
    }

    // Update editing style
    if ( [self.layoutDelegate respondsToSelector:@selector(collectionView:rzTableLayout:editingEnabledForRowAtIndexPath:)] ) {
        rowAttributes.rzEditingEnabled = [self.layoutDelegate collectionView:self.collectionView
                                                               rzTableLayout:self
                                             editingEnabledForRowAtIndexPath:indexPath];
    }

    if ( [self.collectionView isKindOfClass:[RZCollectionTableView class]] ) {
        rowAttributes._rz_parentCollectionTableView = (RZCollectionTableView *)self.collectionView;
    }

    return [rowAttributes copy];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *supplementaryKindCache = [self.supplementaryAttributesCache objectForKey:kind];
    if ( supplementaryKindCache == nil ) {
        supplementaryKindCache = [NSMutableDictionary dictionary];
        [self.supplementaryAttributesCache setObject:supplementaryKindCache forKey:kind];
    }

    UICollectionViewLayoutAttributes *attributes = [supplementaryKindCache objectForKey:indexPath];
    if ( attributes == nil ) {
        attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
        [supplementaryKindCache setObject:attributes forKey:indexPath];

        if ( [kind isEqualToString:RZCollectionTableViewLayoutHeaderView] ) {
            attributes.frame = [self rectForHeaderInSection:indexPath.section];
        }
        else if ( [kind isEqualToString:RZCollectionTableViewLayoutFooterView] ) {
            attributes.frame = [self rectForFooterInSection:indexPath.section];
        }
    }

    return [attributes copy];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind
                                                                  atIndexPath:(NSIndexPath *)indexPath
{
    // Intentionally return nil for now - decoration views not supported yet
    return nil;
}

#pragma mark - Helpers

- (NSInteger)totalRows
{
    NSInteger       rows = 0;
    for ( NSInteger s    = 0; s < [self.collectionView numberOfSections]; s++ ) {
        rows += [self.collectionView numberOfItemsInSection:s];
    }
    return rows;
}

- (id<RZCollectionTableViewLayoutDelegate>)layoutDelegate
{
    // If the delegate conforms to our protocol, return it, otherwise nil
    return ( [self.collectionView.delegate conformsToProtocol:@protocol(RZCollectionTableViewLayoutDelegate)] ) ? (id<RZCollectionTableViewLayoutDelegate>)self.collectionView.delegate : nil;
}

- (BOOL)sectionHasHeader:(NSInteger)section
{
    return [self headerHeightForSection:section] != 0.f;
}

- (BOOL)sectionHasFooter:(NSInteger)section
{
    return [self footerHeightForSection:section] != 0.f;
}

- (void)clearCaches
{
    self.rowHeightCache               = [NSMutableDictionary dictionary];
    self.sectionHeightCache           = [NSMutableDictionary dictionary];
    self.headerHeightCache            = [NSMutableDictionary dictionary];
    self.footerHeightCache            = [NSMutableDictionary dictionary];
    self.itemAttributesCache          = [NSMutableDictionary dictionary];
    self.supplementaryAttributesCache = [NSMutableDictionary dictionary];
    self.cachedContentSize            = CGSizeZero;
    self.lastRequestedRect            = CGRectZero;
}

- (UIEdgeInsets)insetsForSection:(NSInteger)section
{
    UIEdgeInsets insets = self.sectionInsets;
    if ( [self.layoutDelegate respondsToSelector:@selector(collectionView:rzTableLayout:insetForSectionAtIndex:)] ) {
        insets = [self.layoutDelegate collectionView:self.collectionView
                                       rzTableLayout:self
                              insetForSectionAtIndex:section];
    }
    return insets;
}

- (CGFloat)rowSpacingForSection:(NSInteger)section
{
    CGFloat spacing = self.rowSpacing;
    if ( [self.layoutDelegate respondsToSelector:@selector(collectionView:rzTableLayout:rowSpacingForSection:)] ) {
        spacing = [self.layoutDelegate collectionView:self.collectionView
                                        rzTableLayout:self
                                 rowSpacingForSection:section];
    }
    return spacing;
}

- (CGFloat)headerHeightForSection:(NSInteger)section
{
    CGFloat height = 0.f;
    if ( [self.layoutDelegate respondsToSelector:@selector(collectionView:rzTableLayout:heightForHeaderInSection:)] ) {
        NSNumber *cachedHeight = [self.headerHeightCache objectForKey:@(section)];
        if ( cachedHeight != nil ) {
            height = [cachedHeight floatValue];
        }
        else {
            height = [self.layoutDelegate collectionView:self.collectionView
                                           rzTableLayout:self
                                heightForHeaderInSection:section];
            [self.headerHeightCache setObject:@(height) forKey:@(section)];
        }
    }
    return height;
}

- (CGFloat)footerHeightForSection:(NSInteger)section
{
    CGFloat height = 0.f;
    if ( [self.layoutDelegate respondsToSelector:@selector(collectionView:rzTableLayout:heightForFooterInSection:)] ) {
        NSNumber *cachedHeight = [self.footerHeightCache objectForKey:@(section)];
        if ( cachedHeight != nil ) {
            height = [cachedHeight floatValue];
        }
        else {
            height = [self.layoutDelegate collectionView:self.collectionView
                                           rzTableLayout:self
                                heightForFooterInSection:section];
            [self.footerHeightCache setObject:@(height) forKey:@(section)];
        }
    }
    return height;
}

- (CGFloat)heightForSection:(NSInteger)section
{
    return [self heightForSection:section estimated:NO];
}

- (CGFloat)heightForSection:(NSInteger)section estimated:(BOOL)estimated
{
    CGFloat height = 0;

    NSNumber *cachedHeight = [self.sectionHeightCache objectForKey:@(section)];
    if ( cachedHeight != nil ) {
        height = [cachedHeight floatValue];
    }
    else {
        NSInteger rowsInSection = [self.collectionView numberOfItemsInSection:section];

        for ( NSInteger i = 0; i < rowsInSection; i++ ) {
            height += [self heightForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:section] estimated:estimated];
        }

        if ( rowsInSection > 1 ) {
            height += [self rowSpacingForSection:section] * ( rowsInSection - 1 );
        }

        // header and footer - will be zero if not set/implemented in delegate
        height += [self headerHeightForSection:section];
        height += [self footerHeightForSection:section];

        // Insets
        UIEdgeInsets insets = [self insetsForSection:section];
        height += insets.top + insets.bottom;

        if ( !estimated ) {
            [self.sectionHeightCache setObject:@(height) forKey:@(section)];
        }
    }

    return height;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForRowAtIndexPath:indexPath estimated:NO];
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath estimated:(BOOL)estimated
{
    CGFloat height = self.rowHeight;

    if ( [self.collectionView.delegate respondsToSelector:@selector(collectionView:rzTableLayout:heightForRowAtIndexPath:)] ) {
        NSNumber *cachedHeight = [self.rowHeightCache objectForKey:indexPath];
        if ( cachedHeight != nil ) {
            height = [cachedHeight floatValue];
        }
        else {
            BOOL isEstimate = estimated && [self.layoutDelegate respondsToSelector:@selector(collectionView:rzTableLayout:estimatedHeightForRowAtIndexPath:)];

            if ( isEstimate ) {
                height = [self.layoutDelegate collectionView:self.collectionView
                                               rzTableLayout:self
                            estimatedHeightForRowAtIndexPath:indexPath];
            }
            else {
                height = [self.layoutDelegate collectionView:self.collectionView
                                               rzTableLayout:self
                                     heightForRowAtIndexPath:indexPath];

                [self.rowHeightCache setObject:@(height) forKey:indexPath];
            }

        }

    }

    return height;
}

- (CGRect)rectForSection:(NSInteger)section
{
    return [self rectForSection:section estimated:NO];
}

- (CGRect)rectForSection:(NSInteger)section estimated:(BOOL)estimated
{
    CGPoint origin = CGPointZero;
    CGSize  size   = CGSizeMake(self.collectionView.bounds.size.width, [self heightForSection:section estimated:estimated]);

    for ( NSInteger s = 0; s < section; s++ ) {
        origin.y += [self heightForSection:s estimated:estimated];
    }

    return (CGRect){ origin, size };
}

- (CGRect)rectForHeaderInSection:(NSInteger)section
{
    return [self rectForHeaderInSection:section estimated:NO];
}

- (CGRect)rectForHeaderInSection:(NSInteger)section estimated:(BOOL)estimated
{
    CGRect rect = CGRectZero;
    if ( [self sectionHasHeader:section] ) {
        CGPoint origin = CGPointZero;
        CGSize  size   = CGSizeMake(self.collectionView.bounds.size.width, [self headerHeightForSection:section]);

        for ( NSInteger s = 0; s < section; s++ ) {
            origin.y += [self heightForSection:s estimated:estimated];
        }

        origin.y += [self insetsForSection:section].top;

        rect = (CGRect){ origin, size };
    }
    return rect;
}

- (CGRect)rectForFooterInSection:(NSInteger)section
{
    return [self rectForFooterInSection:section estimated:NO];
}

- (CGRect)rectForFooterInSection:(NSInteger)section estimated:(BOOL)estimated
{
    CGRect rect = CGRectZero;
    if ( [self sectionHasFooter:section] ) {
        CGFloat footerHeight = [self footerHeightForSection:section];
        CGPoint origin       = CGPointZero;
        CGSize  size         = CGSizeMake(self.collectionView.bounds.size.width, footerHeight);

        // Include this section
        for ( NSInteger s = 0; s <= section; s++ ) {
            origin.y += [self heightForSection:s estimated:estimated];
        }

        // Back up by the footer height and the inset height
        origin.y -= ( footerHeight + [self insetsForSection:section].bottom );

        rect = (CGRect){ origin, size };
    }
    return rect;
}

- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self rectForRowAtIndexPath:indexPath estimated:NO];
}

- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath estimated:(BOOL)estimated
{
    UIEdgeInsets insets  = [self insetsForSection:indexPath.section];
    CGFloat      spacing = [self rowSpacingForSection:indexPath.section];

    CGPoint origin = CGPointMake(insets.left, insets.top);
    CGSize  size   = CGSizeMake(self.collectionView.bounds.size.width - insets.left - insets.right, [self heightForRowAtIndexPath:indexPath estimated:estimated]);

    // Add offset from previous sections
    for ( NSInteger s = 0; s < indexPath.section; s++ ) {
        origin.y += [self heightForSection:s estimated:estimated];
    }

    // Add offset for header
    origin.y += [self headerHeightForSection:indexPath.section];

    // Add offset from previous rows
    for ( NSInteger r = 0; r < indexPath.item; r++ ) {
        origin.y += [self heightForRowAtIndexPath:[NSIndexPath indexPathForItem:r inSection:indexPath.section] estimated:estimated] + spacing;
    }

    return (CGRect){ origin, size };
}

- (NSIndexPath *)indexPathForRawRowIndex:(NSInteger)rowIndex
{
    if ( rowIndex >= self.totalRows ) {
        return nil;
    }

    NSInteger item               = 0;
    NSInteger section            = 0;
    NSInteger cumulativeRowCount = 0;

    // Find the section index
    BOOL found = NO;
    while ( !found ) {
        cumulativeRowCount += [self.collectionView numberOfItemsInSection:section];
        if ( cumulativeRowCount > rowIndex || section > [self.collectionView numberOfSections] ) {
            // found it
            found = YES;
        }
        else {
            section++;
        }
    }

    // Find the item index
    NSInteger previousCumulativeRows = 0; // number of rows in all previous sections
    if ( section > 0 ) {
        previousCumulativeRows = cumulativeRowCount - [self.collectionView numberOfItemsInSection:section];
    }

    item = rowIndex - previousCumulativeRows;

    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (NSIndexPath *)indexPathOfFirstRowInRect:(CGRect)rect
{
    NSIndexPath *resultPath = nil;

    NSInteger numRows  = self.totalRows;
    NSInteger startRow = 0;
    NSInteger endRow   = numRows - 1;

    if ( numRows == 1 ) {
        resultPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    else {
        // binary search - basic strategy is to start at overall "middle" item, binary search up or down until
        // we get inside the rect, then wind back down until we hit the first item in the rect
        BOOL      found         = NO;
        NSInteger currentRowIdx = endRow / 2;
        while ( !found ) {
            NSIndexPath *currentIndexPath = [self indexPathForRawRowIndex:currentRowIdx];
            if ( currentIndexPath == nil ) {
                break;
            }

            // Go ahead and cache the layout attributes while we're doing this
            CGRect rowRect = [self layoutAttributesForItemAtIndexPath:currentIndexPath].frame;
            if ( CGRectIntersectsRect(rowRect, rect) ) {
                if ( currentRowIdx == 0 || rowRect.origin.y - [self rowSpacingForSection:currentIndexPath.section] <= rect.origin.y ) {
                    resultPath = currentIndexPath;
                    found      = YES;
                }
                else {
                    // decrement and continue until we hit the first one
                    currentRowIdx--;
                }
            }
            else {
                if ( CGRectGetMaxY(rowRect) <= rect.origin.y ) {
                    // half of upwards remainder
                    NSInteger remainder = endRow - currentRowIdx;
                    if ( remainder <= 0 ) {
                        // Must be the last row
                        resultPath = [self indexPathForRawRowIndex:endRow];
                        found      = YES;
                    }
                    else if ( remainder == 1 ) {
                        startRow = currentRowIdx;
                        currentRowIdx++;
                    }
                    else {
                        startRow = currentRowIdx;
                        currentRowIdx += ( remainder / 2 );
                    }
                }
                else {
                    // half of downwards remainder
                    NSInteger remainder = currentRowIdx - startRow;
                    if ( remainder <= 0 ) {
                        // Must be the first row
                        resultPath = [NSIndexPath indexPathForItem:0 inSection:0];
                        found      = YES;
                    }
                    else if ( remainder == 1 ) {
                        endRow = currentRowIdx;
                        currentRowIdx--;
                    }
                    else {
                        endRow = currentRowIdx;
                        currentRowIdx -= remainder / 2;
                    }
                }
            }
        }
    }

    return resultPath;
}

#pragma mark - Very Private

- (void)_rz_editingButtonPressed:(NSUInteger)buttonIdx forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [self.layoutDelegate respondsToSelector:@selector(collectionView:rzTableLayout:editingButtonPressedForIndex:forRowAtIndexPath:)] ) {
        [self.layoutDelegate collectionView:self.collectionView
                              rzTableLayout:self
               editingButtonPressedForIndex:buttonIdx
                          forRowAtIndexPath:indexPath];
    }
}

@end

@implementation RZCollectionTableViewCellAttributes

@synthesize _rz_parentCollectionTableView = __rz_parentCollectionTableView;

- (id)copyWithZone:(NSZone *)zone
{
    RZCollectionTableViewCellAttributes *copiedAttributes = [super copyWithZone:zone];
    copiedAttributes.rowPosition                   = self.rowPosition;
    copiedAttributes.rzEditingEnabled              = self.rzEditingEnabled;
    copiedAttributes._rz_parentCollectionTableView = self._rz_parentCollectionTableView;
    return copiedAttributes;
}

@end
