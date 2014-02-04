//
//  RZCollectionTableView_Private.h
//
//  Created by Nick D on 9/15/13.

//  Copyright (c) 2013 RaizLabs. 
//

#import "RZCollectionTableView.h"

// These declarations are NOT intended for public usage or subclassing.

@interface RZCollectionTableView ()

- (void)_rz_editingStateChangedForCell:(RZCollectionTableViewCell*)cell;
- (void)_rz_editingButtonPressed:(NSUInteger)buttonIdx forCell:(RZCollectionTableViewCell *)cell;

// Flag to indicate whether the table view is in the editing confirmation state or not.
@property (nonatomic, readonly) BOOL _rz_inEditingConfirmationState;

@end

@interface RZCollectionTableViewLayout ()

- (void)_rz_editingButtonPressed:(NSUInteger)buttonIdx forRowAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface RZCollectionTableViewCell ()

@property (nonatomic, weak) RZCollectionTableView *_rz_parentCollectionTableView;

@end

@interface RZCollectionTableViewCellAttributes ()

@property (nonatomic, weak) RZCollectionTableView *_rz_parentCollectionTableView;

@end
