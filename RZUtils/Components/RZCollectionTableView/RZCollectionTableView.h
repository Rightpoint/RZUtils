//
//  RZCollectionTableView.h
//
//  Created by Nick Donaldson on 9/13/13.

//  Copyright (c) 2013 RaizLabs. 
//

/**
 *   Is it a collection view or is it a table view??
 *   The world may never know.
 *
 *   RZCollectionTableView is a collection view with an accompanying layout
 *   designed to look and feel like a UITableView, in terms of visual appearance,
 *   touch interaction, and programming infterface. There are a few additional
 *   useful capabilities thrown in for good measure, such as per-section insets
 *   and row spacing, and collection view attributes which indicate row position 
 *   (solo, top middle, bottom) for easier styling.
 *  
 *   Requires iOS 6.0+
 *
 */

#import <Foundation/Foundation.h>
#import "RZCollectionTableViewCell.h"


//! A UICollection view subclass designed to look and feel like a UITableView
/*!
    RZCollectionTableView enables editing features similar to a UITableView.
    RZCollectionTableViewLayout can be used with a normal UICollectionView (and vice-versa),
    but swipe-to-delete and other future cell editing interactions won't work unless both are used together.
 */
NS_CLASS_AVAILABLE_IOS(6_0) @interface RZCollectionTableView : UICollectionView

@end

// ----------------

// These are the supplementary view types that will be requested for header/footer views.
OBJC_EXTERN NSString * const RZCollectionTableViewLayoutHeaderView;
OBJC_EXTERN NSString * const RZCollectionTableViewLayoutFooterView;

@protocol RZCollectionTableViewLayoutDelegate;

// The layout can be used with a normal UICollectionView, but editing states will not work correctly.

NS_CLASS_AVAILABLE_IOS(6_0) @interface RZCollectionTableViewLayout : UICollectionViewLayout

// Insets around each section. Defaults to UIEdgeInsetsZero.
// Can be overridden per-section by delegate.
@property (nonatomic, assign) UIEdgeInsets sectionInsets;

// Spacing between rows. Defaults to zero. Can be overriden per-section by delegate.
// But wait, can this be negative?? You bet your sweet tookus it can.
@property (nonatomic, assign) CGFloat rowSpacing;

// Row height. Defaults to 44. Can be overridden per-section by delegate.
@property (nonatomic, assign) CGFloat rowHeight;

// Defaults to zero. Can be overridden per-section by delegate.
// If zero, no header will be requested.
@property (nonatomic, assign) CGFloat headerHeight;

// Defaults to zero. Can be overridden per-section by delegate.
// If zero, no header will be requested.
@property (nonatomic, assign) CGFloat footerHeight;

- (CGRect)rectForSection:(NSInteger)section;
- (CGRect)rectForHeaderInSection:(NSInteger)section;
- (CGRect)rectForFooterInSection:(NSInteger)section;
- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

// ------------------

NS_CLASS_AVAILABLE_IOS(6_0) @protocol RZCollectionTableViewLayoutDelegate <UICollectionViewDelegate>

@optional

- (CGFloat)collectionView:(UICollectionView *)collectionView rzTableLayout:(RZCollectionTableViewLayout *)layout heightForRowAtIndexPath:(NSIndexPath*)indexPath;
- (CGFloat)collectionView:(UICollectionView *)collectionView rzTableLayout:(RZCollectionTableViewLayout *)layout rowSpacingForSection:(NSInteger)section;

// implement this to speed up load times
- (CGFloat)collectionView:(UICollectionView *)collectionView rzTableLayout:(RZCollectionTableViewLayout *)layout estimatedHeightForRowAtIndexPath:(NSIndexPath*)indexPath;

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView rzTableLayout:(RZCollectionTableViewLayout *)layout insetForSectionAtIndex:(NSInteger)section; // same signature as UICollectionViewDelegateFlowLayout

// If either of these return zero, no header will be requested for that section.
- (CGFloat)collectionView:(UICollectionView *)collectionView rzTableLayout:(RZCollectionTableViewLayout *)layout heightForHeaderInSection:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView rzTableLayout:(RZCollectionTableViewLayout *)layout heightForFooterInSection:(NSInteger)section;

- (BOOL)collectionView:(UICollectionView *)collectionView rzTableLayout:(RZCollectionTableViewLayout *)layout editingEnabledForRowAtIndexPath:(NSIndexPath*)indexPath;
- (void)collectionView:(UICollectionView *)collectionView rzTableLayout:(RZCollectionTableViewLayout *)layout editingButtonPressedForIndex:(NSUInteger)buttonIndex forRowAtIndexPath:(NSIndexPath*)indexPath;

@end

// ------------------

typedef NS_ENUM(NSUInteger, RZCollectionTableViewCellRowPosition)
{
    RZCollectionTableViewCellRowPositionSolo,
    RZCollectionTableViewCellRowPositionTop,
    RZCollectionTableViewCellRowPositionMiddle,
    RZCollectionTableViewCellRowPositionBottom
};

NS_CLASS_AVAILABLE_IOS(6_0) @interface RZCollectionTableViewCellAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, assign) RZCollectionTableViewCellRowPosition rowPosition;
@property (nonatomic, assign) BOOL rzEditingEnabled;

@end
