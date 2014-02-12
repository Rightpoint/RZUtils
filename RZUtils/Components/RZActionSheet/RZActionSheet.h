//
//  RZActionSheet.h
//  OvulinePregnancy
//
//  Created by Nicholas Bonatsakis on 8/26/13.
//  Copyright (c) 2013 RaizLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RZActionSheetCompletion)(void);

/**
 *  A handy block-based sub-class of UIActionSheet
 *
 *  Create an insstance using the "initWithTitle" method and then use
 *  the various "add"/"set" methods to configure buttons and handlers.
 */
@interface RZActionSheet : UIActionSheet

- (id)initWithTitle:(NSString *)title;
- (void)setCancelButtonTitle:(NSString *)title actionHandler:(RZActionSheetCompletion)handler;
- (void)setDestructiveButtonTitle:(NSString *)title actionHandler:(RZActionSheetCompletion)handler;
- (void)addButtonWithTitle:(NSString *)title actionHandler:(RZActionSheetCompletion)handler;

@end
