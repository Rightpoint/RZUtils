//
//  RZCollectionTableViewCell.h
//
//  Created by Nick Donaldson on 9/13/13.
//  Copyright (c) 2013 RaizLabs. All rights reserved.
//

#import <UIKit/UIKit.h>


OBJC_EXTERN NSString * const RZCollectionTableViewCellEditingStateChanged;
OBJC_EXTERN NSString * const RZCollectionTableViewCellEditingCommitted;

typedef NS_ENUM(NSUInteger, RZCollectionTableViewCellEditingStyle)
{
    RZCollectionTableViewCellEditingStyleNone,
    RZCollectionTableViewCellEditingStyleDelete
    // TODO: More states?
};

@class RZCollectionTableViewCell;

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

// Editing style. Can be overridden by RZCollectionTableViewLayoutDelegate.
@property (nonatomic, assign) RZCollectionTableViewCellEditingStyle rzEditingStyle;

// Defaults to NO
@property (nonatomic, assign, getter = tvcIsEditing) BOOL rzEditing;

// Override in subclass to update appearance according to editingStyle
// Must call super implementation.
- (void)setRzEditing:(BOOL)editing animated:(BOOL)animated;

@end
