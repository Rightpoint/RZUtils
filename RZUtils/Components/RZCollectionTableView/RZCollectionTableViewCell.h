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
    Adds basic swipe-to-delete functionality for collection view cell
 */
@interface RZCollectionTableViewCell : UICollectionViewCell

// NOTE: Using "tvc" prefix for the editing interface to avoid potential future conflict with apple interface (if they ever add one).
// If "editing" interface is added in future for UICollectionViewCell, this will be changed so simply overload that interface.

// Editing style. Can be overridden by RZCollectionTableViewLayoutDelegate.
@property (nonatomic, assign) RZCollectionTableViewCellEditingStyle tvcEditingStyle;

// Defaults to NO
@property (nonatomic, assign, getter = tvcIsEditing) BOOL tvcEditing;

// Override in subclass to update appearance according to editingStyle
// Must call super implementation.
// TODO: Ability to customize a "default" delete button
// TODO: Separate concept of "editing" vs "ready to confirm edit" (e.g. delete button or deletion control on left)
- (void)setTvcEditing:(BOOL)editing animated:(BOOL)animated;

// Call this from within subclass to notify layout delegate of committed editing state.
- (void)commitTvcEdits;

@end
