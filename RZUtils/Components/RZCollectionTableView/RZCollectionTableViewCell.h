//
//  RZCollectionTableViewCell.h
//
//  Created by Nick Donaldson on 9/13/13.

//  Copyright (c) 2013 RaizLabs. 
//

#import <UIKit/UIKit.h>

@class RZCollectionTableViewCellEditingItem;

//! UICollectionViewCell subclass intended to be used with RZCollectionTableView.
/*!
    Adds basic iOS7-style swipe-to-edit functionality for collection view cell
 */
@interface RZCollectionTableViewCell : UICollectionViewCell

//! Container view for adding subviews that will be swiped over when swiping to edit
/*!
    If loaded from a XIB, all subviews in the XIB will be moved to this view by default.
    If building in code, you must add subviews here, NOT to the normal contentView.
 */
@property (nonatomic, readonly, weak) UIView *swipeableContentHostView;

// NOTE: Using "rz" prefix for the editing interface to avoid potential future conflict with apple interface (if they ever add one).
// If "editing" interface is added in future for UICollectionViewCell, this will be changed so simply overload that interface.

// Set editing items that will be revealed when panning to the left
- (void)setRzEditingItems:(NSArray *)editingItems;

// Set whether editing enabled. Can be overridden by RZCollectionTableViewLayoutDelegate.
// Must have at least one editing item for this to succeed.
@property (nonatomic, assign) BOOL rzEditingEnabled;

// Defaults to NO
@property (nonatomic, assign, getter = tvcIsEditing) BOOL rzEditing;
- (void)setRzEditing:(BOOL)editing animated:(BOOL)animated;

@end


@interface RZCollectionTableViewCellEditingItem : NSObject

// For now, you get either text or an icon, but not both.
// In the future might extend this to allow both.
+ (RZCollectionTableViewCellEditingItem *)itemWithTitle:(NSString *)title
                                                   font:(UIFont *)font
                                             titleColor:(UIColor *)titleColor
                                  highlightedTitlecolor:(UIColor *)highlightedTitleColor
                                        backgroundColor:(UIColor *)backgroundColor;

+ (RZCollectionTableViewCellEditingItem *)itemWithIcon:(UIImage *)icon
                                       highlightedIcon:(UIImage *)highlightedIcon
                                       backgroundColor:(UIColor *)backgroundColor;

@end
