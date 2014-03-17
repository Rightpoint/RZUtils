//
//  NSUndoManager+RZBlockUndo.m
//  Raizlabs
//
//  Created by Nick Donaldson on 3/14/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "NSUndoManager+RZBlockUndo.h"

@interface RZUndoRedoBlockAction : NSObject

@property (nonatomic, copy) void (^undoBlock)();
@property (nonatomic, copy) void (^redoBlock)();

- (instancetype)invertedAction;

@end

@implementation RZUndoRedoBlockAction

- (instancetype)invertedAction
{
    // Must have a redo block to return an inverted action
    if ( self.redoBlock == nil ) {
        return nil;
    }
    
    RZUndoRedoBlockAction *invertedAction = [[RZUndoRedoBlockAction alloc] init];
    invertedAction.undoBlock = self.redoBlock;
    invertedAction.redoBlock = self.undoBlock;
    return invertedAction;
}

@end

@implementation NSUndoManager (RZBlockUndo)

- (void)rz_performUndoAction:(RZUndoRedoBlockAction *)action
{
    if ( action.undoBlock ) {
        action.undoBlock();
    }
    
    RZUndoRedoBlockAction *redoAction = [action invertedAction];
    
    if ( redoAction != nil ) {
        [self registerUndoWithTarget:self selector:@selector(rz_performUndoAction:) object:redoAction];
    }
}

- (void)rz_registerUndoWithBlock:(void (^)())undoBlock redoBlock:(void (^)())redoBlock
{
    NSParameterAssert(undoBlock);

    RZUndoRedoBlockAction *undoRedoAction    = [[RZUndoRedoBlockAction alloc] init];
    undoRedoAction.undoBlock                 = undoBlock;
    undoRedoAction.redoBlock                 = redoBlock;
    
    [self registerUndoWithTarget:self selector:@selector(rz_performUndoAction:) object:undoRedoAction];
}

@end
