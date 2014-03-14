//
//  NSUndoManager+RZBlockUndo.h
//  Raizlabs
//
//  Created by Nick Donaldson on 3/14/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Block-based interface for NSUndoManager
 */
@interface NSUndoManager (RZBlockUndo)

/**
 *  Register an undo action with a block and a redo block.
 *  @warning undoBlock must not be nil. Neither block should contain a strong reference to anything that is unsafe to retain.
 *  @param undoBlock A block that will be invoked when the undo stack reaches this action.
 *  @param redoBlock An optional block that will be invoked for a redo after an undo of this action.
 */
- (void)rz_registerUndoWithBlock:(void(^)())undoBlock redoBlock:(void(^)())redoBlock;

@end
